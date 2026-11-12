import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_model.dart';
import '../models/draft_model.dart';
import '../models/invite_model.dart';
import '../models/notification_model.dart';
import '../models/player_model.dart';
import 'firebase_providers.dart';
import 'invite_service.dart';

/// Randevular (§6.3 "Maçı kaydet", "Randevuyu sil").
class AppointmentService {
  AppointmentService(this._db);
  final FirebaseFirestore _db;

  Stream<List<AppointmentModel>> watchMine(String uid) => _db.appointments
      .where('memberIds', arrayContains: uid)
      .snapshots()
      .map((q) => q.docs.map(AppointmentModel.fromDoc).toList());

  Stream<AppointmentModel?> watchOne(String id) => _db.appointments
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? AppointmentModel.fromDoc(d) : null)
      .transform(nullOnDenied());

  /// Maçı kaydet: randevu + bağlanan davetler + üyelere `match_` bildirimi +
  /// taslağı sıfırla (kadro ve saat; diziliş ve konum korunur).
  /// [linkInvites]: kadroda adı geçen, kabul edilmiş ve bağlanmamış davetler.
  Future<String> save({
    required String ownerId,
    required DraftModel draft,
    required List<InviteModel> linkInvites,
    String? id,
    bool notify = true,
    bool resetDraft = true,
  }) async {
    final ref = id == null ? _db.appointments.doc() : _db.appointments.doc(id);
    final members = [ownerId, ...linkInvites.map((v) => v.receiverId)];
    final appt = AppointmentModel(
      id: ref.id,
      ownerId: ownerId,
      memberIds: members,
      formation: draft.formation!,
      city: draft.city!,
      district: draft.district!,
      stadium: draft.stadium!,
      matchTime: draft.matchTime!,
      players: draft.players.values.toList(),
    );
    final b = _db.batch();
    b.set(ref, appt.toMap());
    for (final v in linkInvites) {
      b.update(_db.invites.doc(v.id), {'appointmentId': ref.id});
      if (notify) {
        b.set(_db.notificationsOf(v.receiverId).doc(NotificationModel.matchId(ref.id)), {
          'type': 'matchSaved',
          'relatedId': ref.id,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    if (resetDraft) {
      b.set(_db.drafts.doc(ownerId),
          draft.copyWith(players: const {}, matchTime: null).toMap());
    }
    await b.commit();
    return ref.id;
  }

  /// Sil: randevu + bağlı davetlerde `appointmentId: null`.
  Future<void> delete(AppointmentModel a, List<InviteModel> linked) async {
    final b = _db.batch();
    b.delete(_db.appointments.doc(a.id));
    for (final v in linked) {
      b.update(_db.invites.doc(v.id), {'appointmentId': null});
    }
    await b.commit();
  }

  /// Silmeyi geri al: aynı kimlikle yeniden oluştur ve davetleri yeniden bağla.
  Future<void> restore(AppointmentModel a, List<InviteModel> linked) async {
    final b = _db.batch();
    b.set(_db.appointments.doc(a.id), {
      ...a.toMap(),
      'memberIds': [a.ownerId, ...linked.map((v) => v.receiverId)],
    });
    for (final v in linked) {
      b.update(_db.invites.doc(v.id), {'appointmentId': a.id});
    }
    await b.commit();
  }
}

final appointmentServiceProvider = Provider<AppointmentService>(
    (ref) => AppointmentService(ref.watch(firestoreProvider)));

final myAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(appointmentServiceProvider).watchMine(uid);
});

final appointmentProvider =
    StreamProvider.autoDispose.family<AppointmentModel?, String>(
  (ref, id) => ref.watch(appointmentServiceProvider).watchOne(id),
);

/// Randevularım satırı (§5.5): kendi randevum, davetli olduğum randevu ya da
/// kabul ettiğim ama henüz kaydedilmemiş maç ("Kadro kuruluyor").
class Booking {
  const Booking.own(AppointmentModel a)
      : appointment = a,
        invite = null,
        guest = false;
  const Booking.guest(AppointmentModel a)
      : appointment = a,
        invite = null,
        guest = true;
  const Booking.building(InviteModel v)
      : appointment = null,
        invite = v,
        guest = true;

  final AppointmentModel? appointment;
  final InviteModel? invite;
  final bool guest;

  bool get building => invite != null;
  String get id => appointment?.id ?? invite!.id;
  String get formation => appointment?.formation ?? invite!.formation;
  String get city => appointment?.city ?? invite!.city;
  String get district => appointment?.district ?? invite!.district;
  String get stadium => appointment?.stadium ?? invite!.stadium;
  String get matchTime => appointment?.matchTime ?? invite!.matchTime;
  List<PlayerModel> get players => appointment?.players ?? invite!.players;
  bool get isSample => appointment?.isSample ?? false;

  /// Organizatör (davetliysem).
  String? get hostId => appointment?.ownerId ?? invite?.senderId;
}

/// Kendi randevularım (yeniden eskiye) + katıldıklarım; prototip
/// `appts.concat(joined())` sırası.
final bookingsProvider = Provider<List<Booking>>((ref) {
  final uid = ref.watch(uidProvider);
  final appts = ref.watch(myAppointmentsProvider).value ?? const <AppointmentModel>[];
  final incoming = ref.watch(incomingInvitesProvider).value ?? const <InviteModel>[];
  int byNew(AppointmentModel a, AppointmentModel b) =>
      (b.createdAt ?? DateTime(9999)).compareTo(a.createdAt ?? DateTime(9999));
  final own = appts.where((a) => a.ownerId == uid).toList()..sort(byNew);
  final guest = appts.where((a) => a.ownerId != uid).toList()..sort(byNew);
  return [
    for (final a in own) Booking.own(a),
    for (final a in guest) Booking.guest(a),
    for (final v in incoming)
      if (v.isAccepted && v.appointmentId == null) Booking.building(v),
  ];
});
