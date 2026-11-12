import 'package:cloud_firestore/cloud_firestore.dart';

import 'player_model.dart';

enum InviteStatus { pending, accepted, rejected }

/// `invites/{id}` — maç daveti + mevki teklifi (§6.2, §5.4).
class InviteModel {
  const InviteModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.formation,
    required this.city,
    required this.district,
    required this.stadium,
    required this.matchTime,
    required this.players,
    required this.offeredSlot,
    required this.status,
    this.durationMinutes = 60,
    this.appointmentId,
    this.appliedToDraft = false,
    this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String formation;
  final String city;
  final String district;
  final String stadium;
  final String matchTime;
  final int durationMinutes;
  final List<PlayerModel> players;
  final String offeredSlot;
  final InviteStatus status;
  final String? appointmentId;
  final bool appliedToDraft;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  bool get isPending => status == InviteStatus.pending;
  bool get isAccepted => status == InviteStatus.accepted;
  bool get isRejected => status == InviteStatus.rejected;

  factory InviteModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return InviteModel(
      id: d.id,
      senderId: (m['senderId'] ?? '') as String,
      receiverId: (m['receiverId'] ?? '') as String,
      formation: (m['formation'] ?? '') as String,
      city: (m['city'] ?? '') as String,
      district: (m['district'] ?? '') as String,
      stadium: (m['stadium'] ?? '') as String,
      matchTime: (m['matchTime'] ?? '') as String,
      durationMinutes: (m['durationMinutes'] ?? 60) as int,
      players: PlayerModel.listFrom(m['players']),
      offeredSlot: (m['offeredSlot'] ?? '') as String,
      status: InviteStatus.values.firstWhere(
        (s) => s.name == m['status'],
        orElse: () => InviteStatus.pending,
      ),
      appointmentId: m['appointmentId'] as String?,
      appliedToDraft: (m['appliedToDraft'] ?? false) as bool,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      respondedAt: (m['respondedAt'] as Timestamp?)?.toDate(),
    );
  }
}
