import 'package:cloud_firestore/cloud_firestore.dart';

/// `chats/{id}/messages/{id}` (§6.2).
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;

  factory MessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return MessageModel(
      id: d.id,
      senderId: (m['senderId'] ?? '') as String,
      text: (m['text'] ?? '') as String,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
