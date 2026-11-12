import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  invite,
  inviteAccepted,
  inviteRejected,
  matchSaved,
  reminder,
  message,
}

/// `users/{uid}/notifications/{id}` (§6.2). Kimlikler belirlenimcidir:
/// `invite_{inviteId}`, `resp_{inviteId}`, `match_{appointmentId}`,
/// `msg_{chatId}`, `rem_{appointmentId}`.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.relatedId,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String relatedId;
  final bool isRead;
  final DateTime? createdAt;

  static String inviteId(String inviteId) => 'invite_$inviteId';
  static String responseId(String inviteId) => 'resp_$inviteId';
  static String matchId(String appointmentId) => 'match_$appointmentId';
  static String messageId(String chatId) => 'msg_$chatId';

  factory NotificationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return NotificationModel(
      id: d.id,
      type: NotificationType.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => NotificationType.reminder,
      ),
      relatedId: (m['relatedId'] ?? '') as String,
      isRead: (m['isRead'] ?? false) as bool,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
