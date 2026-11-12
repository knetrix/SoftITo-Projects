import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formation.dart';
import '../../core/utils/validators.dart';
import '../../models/draft_model.dart';
import '../../models/invite_model.dart';
import '../../models/player_model.dart';
import '../../services/appointment_service.dart';
import '../../services/draft_service.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/user_service.dart';

/// Takım Kur'da "kaydet denendi" durumu: eksik alanlar kırmızı işaretlenir.
class TeamTried extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final teamTriedProvider = NotifierProvider<TeamTried, bool>(TeamTried.new);

/// Bekleyen davetin tuttuğu (taslakta dolu olmayan) mevkiler.
final reservedSlotsProvider = Provider<Map<String, InviteModel>>((ref) {
  final d = ref.watch(draftProvider);
  final ids = slotsOf(d.formation).map((s) => s.id).toSet();
  return {
    for (final e in ref.watch(pendingBySlotProvider).entries)
      if (ids.contains(e.key) && !d.players.containsKey(e.key)) e.key: e.value,
  };
});

/// Eksik bilgi (§5.3) — ARB anahtarları ve oyuncu eksiği.
List<({String key, int n})> missingOf(DraftModel d) {
  final filled = slotsOf(d.formation).where((s) => d.players.containsKey(s.id)).length;
  return [
    if (d.formation == null)
      (key: 'mFormation', n: 0)
    else if (filled < 7)
      (key: 'mPlayers', n: 7 - filled),
    if (d.city == null) (key: 'mCity', n: 0),
    if (d.district == null) (key: 'mDistrict', n: 0),
    if (d.stadium == null) (key: 'mStadium', n: 0),
    if (d.matchTime == null) (key: 'mTime', n: 0),
  ];
}

/// Takım Kur işlemleri (§5.1–5.3).
class TeamActions {
  TeamActions(this.ref);
  final Ref ref;

  DraftController get _c => ref.read(draftProvider.notifier);
  DraftModel get _d => ref.read(draftProvider);

  /// §5.2-1: diziliş değişimi; taşınanlar listesi döner (ad, yeni mevki).
  List<(String, Slot)> setFormation(String f) {
    final d = _d;
    if (d.formation == f) return const [];
    final users = ref.read(usersByIdProvider);
    final pending = ref.read(reservedSlotsProvider);
    final r = changeFormation<PlayerModel>(
      from: d.formation,
      to: f,
      players: d.players,
      pendingBySlot: pending,
    );
    final players = {for (final e in r.players.entries) e.key: e.value.withSlot(e.key)};
    _c.update(d.copyWith(formation: f, players: players));
    for (final e in r.inviteMoves.entries) {
      ref.read(inviteServiceProvider).moveOffered(pending[e.key]!.id, e.value);
    }
    return [
      for (final (o, slot) in r.moved)
        (o is PlayerModel ? o.firstName : (users[(o as InviteModel).receiverId]?.firstName ?? ''), slot),
    ];
  }

  /// §5.2-2: aynı oyuncu iki mevkide olamaz. Çakışan mevki döner.
  String? clashOf(String slot, String first, String last) {
    for (final s in slotsOf(_d.formation)) {
      final o = _d.players[s.id];
      if (s.id == slot || o == null) continue;
      if (samePlayer(o.firstName, o.lastName, first, last)) return s.id;
    }
    return null;
  }

  void savePlayer(String slot, String first, String last) {
    final d = _d;
    final players = Map<String, PlayerModel>.from(d.players)
      ..[slot] = PlayerModel(slot: slot, firstName: squish(first), lastName: squish(last));
    _c.update(d.copyWith(players: players));
  }

  PlayerModel? removePlayer(String slot) {
    final d = _d;
    final p = d.players[slot];
    if (p == null) return null;
    _c.update(d.copyWith(players: Map.of(d.players)..remove(slot)));
    return p;
  }

  void restorePlayer(PlayerModel p) {
    final d = _d;
    _c.update(d.copyWith(players: Map.of(d.players)..[p.slot] = p));
  }

  /// §5.2-3: il değişince ilçe ve saha sıfırlanır. Önceden seçim varsa `true`.
  bool pickCity(String city) {
    final d = _d;
    if (d.city == city) return false;
    final changed = d.district != null || d.stadium != null;
    _c.update(d.copyWith(city: city, district: null, stadium: null));
    if (changed) ref.read(teamTriedProvider.notifier).set(true);
    return changed;
  }

  void pickDistrict(String v) {
    final d = _d;
    if (d.district == v) return;
    _c.update(d.copyWith(district: v, stadium: null));
  }

  void pickStadium(String v) => _c.update(_d.copyWith(stadium: v));
  void pickTime(String v) => _c.update(_d.copyWith(matchTime: v));

  /// Maçı kaydet (§5.3, §5.4, §6.3). Eksik varsa null.
  Future<String?> save() async {
    final d = _d;
    if (missingOf(d).isNotEmpty) {
      ref.read(teamTriedProvider.notifier).set(true);
      return null;
    }
    await _c.flush();
    final uid = ref.read(uidProvider)!;
    final users = ref.read(usersByIdProvider);
    final names = d.players.values.map((p) => trLower(p.fullName)).toSet();
    final link = [
      for (final v in ref.read(outgoingInvitesProvider).value ?? const <InviteModel>[])
        if (v.isAccepted && v.appointmentId == null &&
            users[v.receiverId] != null &&
            names.contains(trLower(users[v.receiverId]!.fullName)))
          v,
    ];
    final ordered = DraftModel(
      formation: d.formation,
      city: d.city,
      district: d.district,
      stadium: d.stadium,
      matchTime: d.matchTime,
      players: {
        for (final s in slotsOf(d.formation))
          if (d.players[s.id] != null) s.id: d.players[s.id]!,
      },
    );
    final id = await ref.read(appointmentServiceProvider).save(
          ownerId: uid,
          draft: ordered,
          linkInvites: link,
        );
    ref.read(teamTriedProvider.notifier).set(false);
    return id;
  }
}

final teamActionsProvider = Provider<TeamActions>(TeamActions.new);
