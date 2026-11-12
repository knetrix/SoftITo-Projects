import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/formation.dart';
import '../models/draft_model.dart';
import '../models/invite_model.dart';
import '../models/player_model.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';
import 'invite_service.dart';
import 'user_service.dart';

/// `drafts/{uid}` — yalnızca sahibi okur/yazar (§6.4).
class DraftService {
  DraftService(this._db);
  final FirebaseFirestore _db;

  Stream<DraftModel> watch(String uid) =>
      _db.drafts.doc(uid).snapshots().map(DraftModel.fromDoc);

  Future<void> write(String uid, DraftModel d) => _db.drafts.doc(uid).set(d.toMap());

  /// Kabulü taslağa işle (§6.3): göndericinin kendi uygulaması, taslakta
  /// mevki hâlâ varsa ve boşsa alıcının adını yazar; davet işaretlenir.
  Future<void> applyAccepted(String uid, InviteModel v, UserModel receiver) {
    return _db.runTransaction((tx) async {
      final dref = _db.drafts.doc(uid);
      final d = DraftModel.fromDoc(await tx.get(dref));
      final exists = slotsOf(d.formation).any((s) => s.id == v.offeredSlot);
      if (exists && !d.players.containsKey(v.offeredSlot)) {
        final players = Map<String, PlayerModel>.from(d.players)
          ..[v.offeredSlot] = PlayerModel(
            slot: v.offeredSlot,
            firstName: receiver.firstName,
            lastName: receiver.lastName,
          );
        tx.set(dref, d.copyWith(players: players).toMap());
      }
      tx.update(_db.invites.doc(v.id), {'appliedToDraft': true});
    });
  }
}

final draftServiceProvider =
    Provider<DraftService>((ref) => DraftService(ref.watch(firestoreProvider)));

/// Takım Kur taslağı: yerel kopya anında güncellenir, Firestore'a 400 ms
/// gecikmeyle yazılır. Uzak değişiklikler bekleyen yerel yazma yokken alınır.
class DraftController extends Notifier<DraftModel> {
  Timer? _debounce;
  bool _dirty = false;
  bool _loaded = false;
  final Set<String> _applying = {};

  bool get loaded => _loaded;

  @override
  DraftModel build() {
    final uid = ref.watch(uidProvider);
    _debounce?.cancel();
    _dirty = false;
    _loaded = false;
    ref.onDispose(() => _debounce?.cancel());
    if (uid == null) return DraftModel.empty;
    final sub = ref.watch(draftServiceProvider).watch(uid).listen((d) {
      _loaded = true;
      if (!_dirty) state = d;
    });
    ref.onDispose(sub.cancel);

    // Kabul edilen davetleri taslağa işle.
    ref.listen<AsyncValue<List<InviteModel>>>(outgoingInvitesProvider, (_, next) {
      _applyAccepted(uid, next.value ?? const []);
    }, fireImmediately: true);
    ref.listen(usersByIdProvider, (_, _) {
      _applyAccepted(uid, ref.read(outgoingInvitesProvider).value ?? const []);
    });
    return DraftModel.empty;
  }

  void _applyAccepted(String uid, List<InviteModel> list) {
    final users = ref.read(usersByIdProvider);
    for (final v in list.where((v) => v.isAccepted && !v.appliedToDraft)) {
      final u = users[v.receiverId];
      if (u == null || _applying.contains(v.id)) continue;
      _applying.add(v.id);
      flush().then((_) => ref.read(draftServiceProvider).applyAccepted(uid, v, u))
          .whenComplete(() => _applying.remove(v.id));
    }
  }

  /// Yerel değişiklik + gecikmeli kayıt.
  void update(DraftModel d) {
    state = d;
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), flush);
  }

  /// Bekleyen yazmayı hemen gönder.
  Future<void> flush() async {
    _debounce?.cancel();
    final uid = ref.read(uidProvider);
    if (!_dirty || uid == null) return;
    final d = state;
    try {
      await ref.read(draftServiceProvider).write(uid, d);
    } finally {
      if (identical(d, state)) _dirty = false;
    }
  }
}

final draftProvider = NotifierProvider<DraftController, DraftModel>(DraftController.new);
