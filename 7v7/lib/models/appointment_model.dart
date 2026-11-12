import 'package:cloud_firestore/cloud_firestore.dart';

import 'player_model.dart';

/// `appointments/{id}` (§6.2).
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.ownerId,
    required this.memberIds,
    required this.formation,
    required this.city,
    required this.district,
    required this.stadium,
    required this.matchTime,
    required this.players,
    this.durationMinutes = 60,
    this.isSample = false,
    this.imageAsset,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final List<String> memberIds;
  final String formation;
  final String city;
  final String district;
  final String stadium;
  final String matchTime;
  final int durationMinutes;
  final List<PlayerModel> players;
  final bool isSample;
  final String? imageAsset;
  final DateTime? createdAt;

  factory AppointmentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return AppointmentModel(
      id: d.id,
      ownerId: (m['ownerId'] ?? '') as String,
      memberIds: List<String>.from(m['memberIds'] as List? ?? const []),
      formation: (m['formation'] ?? '') as String,
      city: (m['city'] ?? '') as String,
      district: (m['district'] ?? '') as String,
      stadium: (m['stadium'] ?? '') as String,
      matchTime: (m['matchTime'] ?? '') as String,
      durationMinutes: (m['durationMinutes'] ?? 60) as int,
      players: PlayerModel.listFrom(m['players']),
      isSample: (m['isSample'] ?? false) as bool,
      imageAsset: m['imageAsset'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'memberIds': memberIds,
        'formation': formation,
        'city': city,
        'district': district,
        'stadium': stadium,
        'matchTime': matchTime,
        'durationMinutes': durationMinutes,
        'players': [for (final p in players) p.toMap()],
        'isSample': isSample,
        'imageAsset': imageAsset,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
