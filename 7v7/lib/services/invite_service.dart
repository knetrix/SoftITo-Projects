import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/draft_model.dart';
import '../models/invite_model.dart';
import '../models/notification_model.dart';
import '../models/player_model.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';

/// Davet gönderme / geri çekme / yanıt (§5.4, §6.3). Her işlem tek bir
/// batch ya da transaction'dır; güvenlik kuralları §6.4'e göre doğrular.
class InviteService {
  InviteService(this._db);
  final FirebaseFirestore _db;

  static List<InviteModel> _sorted(QuerySnapshot<Map<String, dynamic>> q) {
    final list = q.docs.map(InviteModel.fromDoc).toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(9999))
          .compareTo(a.createdAt ?? DateTime(9999)));
    return list;
  }

  Stream<List<InviteModel>> watchIncoming(String uid) =>
      _db.invites.where('receiverId', isEqualTo: uid).snapshots().map(_sorted);

  Stream<List<InviteModel>> watchOutgoing(String uid) =>
      _db.invites.where('senderId', isEqualTo: uid).snapshots().map(_sorted);

  Stream<InviteModel?> watchOne(String id) => _db.invites
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? InviteModel.fromDoc(d) : null)
      .transform(nullOnDenied());

  /// Davet gönder: davet + kilit + alıcıya `invite_{id}` bildirimi.
  Future<String> send({
    required String senderId,
    required String receiverId,
    required DraftModel draft,
    required String offeredSlot,
  }) async {
    final ref = _db.invites.doc();
    final b = _db.batch();
    b.set(ref, {
      'senderId': senderId,
      'receiverId': receiverId,
      'formation': draft.formation,
      'city': draft.city,
      'district': draft.district,
      'stadium': draft.stadium,
      'matchTime': draft.matchTime,
      'durationMinutes': 60,
      'players': [for (final p in draft.players.values) p.toMap()],
      'offeredSlot': offeredSlot,
      'status': 'pending',
      'appointmentId': null,
      'appliedToDraft': false,
      'createdAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    });
    b.set(_db.inviteLocks.doc('${senderId}_$receiverId'),
        {'inviteId': ref.id, 'state': 'pending'});
    b.set(_db.notificationsOf(receiverId).doc(NotificationModel.inviteId(ref.id)), {
      'type': 'invite',
      'relatedId': ref.id,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await b.commit();
    return ref.id;
  }

  /// Geri çek: bekleyen davet + kilit + alıcının bildirimi silinir.
  Future<void> withdraw(InviteModel v) =>
      withdrawById(v.id, senderId: v.senderId, receiverId: v.receiverId);

  Future<void> withdrawById(
    String id, {
    required String senderId,
    required String receiverId,
  }) async {
    final b = _db.batch();
    b.delete(_db.notificationsOf(receiverId).doc(NotificationModel.inviteId(id)));
    b.delete(_db.inviteLocks.doc('${senderId}_$receiverId'));
    b.delete(_db.invites.doc(id));
    await b.commit();
  }

  /// Diziliş değişince bekleyen davetin mevkisi taşınır (§5.2-1).
  Future<void> moveOffered(String inviteId, String slot) =>
      _db.invites.doc(inviteId).update({'offeredSlot': slot});

  /// Yanıt (alıcı): durum + `respondedAt`; kabulde anlık görüntüye alıcının
  /// adı yazılır, arkadaşlık (yoksa) oluşur; kilit silinir / reddedildi olur;
  /// göndericiye `resp_{id}`.
  Future<void> respond({
    required String inviteId,
    required bool accept,
    required UserModel me,
  }) {
    return _db.runTransaction((tx) async {
      final ref = _db.invites.doc(inviteId);
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('inviteGone');
      final v = InviteModel.fromDoc(snap);
      if (!v.isPending || v.receiverId != me.uid) throw StateError('notPending');
      final fid = pairId(v.senderId, v.receiverId);
      final friendRef = _db.friendships.doc(fid);
      final friend = accept ? await tx.get(friendRef) : null;

      final players = [
        for (final p in v.players)
          if (p.slot != v.offeredSlot) p,
        if (accept)
          PlayerModel(slot: v.offeredSlot, firstName: me.firstName, lastName: me.lastName),
      ];
      tx.update(ref, {
        'status': accept ? 'accepted' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        if (accept) 'players': [for (final p in players) p.toMap()],
      });
      final lock = _db.inviteLocks.doc('${v.senderId}_${v.receiverId}');
      if (accept) {
        tx.delete(lock);
      } else {
        tx.set(lock, {'inviteId': v.id, 'state': 'rejected'});
      }
      if (accept && !(friend?.exists ?? false)) {
        tx.set(friendRef, {
          'userIds': fid.split('_'),
          'inviteId': v.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      tx.set(_db.notificationsOf(v.senderId).doc(NotificationModel.responseId(v.id)), {
        'type': accept ? 'inviteAccepted' : 'inviteRejected',
        'relatedId': v.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Arkadaşlar (uid kümesi).
  Stream<Set<String>> watchFriends(String uid) => _db.friendships
      .where('userIds', arrayContains: uid)
      .snapshots()
      .map((q) => {
            for (final d in q.docs)
              ...List<String>.from(d.data()['userIds'] as List).where((u) => u != uid),
          });
}

final inviteServiceProvider =
    Provider<InviteService>((ref) => InviteService(ref.watch(firestoreProvider)));

final incomingInvitesProvider = StreamProvider<List<InviteModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(inviteServiceProvider).watchIncoming(uid);
});

final outgoingInvitesProvider = StreamProvider<List<InviteModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(inviteServiceProvider).watchOutgoing(uid);
});

final inviteProvider = StreamProvider.autoDispose.family<InviteModel?, String>(
  (ref, id) => ref.watch(inviteServiceProvider).watchOne(id),
);

final friendsProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const {});
  return ref.watch(inviteServiceProvider).watchFriends(uid);
});

/// Göndericinin bekleyen davetleri: mevki → davet.
final pendingBySlotProvider = Provider<Map<String, InviteModel>>((ref) {
  final list = ref.watch(outgoingInvitesProvider).value ?? const [];
  return {for (final v in list.where((v) => v.isPending)) v.offeredSlot: v};
});
