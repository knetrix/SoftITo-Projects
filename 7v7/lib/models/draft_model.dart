import 'package:cloud_firestore/cloud_firestore.dart';

import 'player_model.dart';

/// `drafts/{uid}` — Takım Kur taslağı (§6.2).
class DraftModel {
  const DraftModel({
    this.formation,
    this.city,
    this.district,
    this.stadium,
    this.matchTime,
    this.players = const {},
  });

  final String? formation;
  final String? city;
  final String? district;
  final String? stadium;

  /// Başlangıç saati, ör. '21:00'.
  final String? matchTime;

  /// mevki → oyuncu
  final Map<String, PlayerModel> players;

  static const empty = DraftModel();

  DraftModel copyWith({
    Object? formation = _keep,
    Object? city = _keep,
    Object? district = _keep,
    Object? stadium = _keep,
    Object? matchTime = _keep,
    Map<String, PlayerModel>? players,
  }) =>
      DraftModel(
        formation: formation == _keep ? this.formation : formation as String?,
        city: city == _keep ? this.city : city as String?,
        district: district == _keep ? this.district : district as String?,
        stadium: stadium == _keep ? this.stadium : stadium as String?,
        matchTime: matchTime == _keep ? this.matchTime : matchTime as String?,
        players: players ?? this.players,
      );

  factory DraftModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    if (m == null) return empty;
    String? s(String k) {
      final v = m[k];
      return v is String && v.isNotEmpty ? v : null;
    }

    return DraftModel(
      formation: s('formation'),
      city: s('city'),
      district: s('district'),
      stadium: s('stadium'),
      matchTime: s('matchTime'),
      players: PlayerModel.mapFrom(PlayerModel.listFrom(m['players'])),
    );
  }

  Map<String, dynamic> toMap() => {
        'formation': formation,
        'city': city,
        'district': district,
        'stadium': stadium,
        'matchTime': matchTime,
        'players': [for (final p in players.values) p.toMap()],
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

const _keep = Object();
