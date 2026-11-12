import 'package:cloud_firestore/cloud_firestore.dart';

/// `chats/{uidA_uidB}` (§6.2). Kimlik iki uid'nin sıralı birleşimidir.
class ChatModel {
  const ChatModel({
    required this.id,
    required this.userIds,
    this.lastText,
    this.lastSenderId,
    this.lastAt,
    this.updatedAt,
  });

  final String id;
  final List<String> userIds;
  final String? lastText;
  final String? lastSenderId;
  final DateTime? lastAt;
  final DateTime? updatedAt;

  static String idFor(String a, String b) {
    final l = [a, b]..sort();
    return '${l[0]}_${l[1]}';
  }

  String otherOf(String me) =>
      userIds.firstWhere((u) => u != me, orElse: () => me);

  factory ChatModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    final last = m['lastMessage'] as Map?;
    return ChatModel(
      id: d.id,
      userIds: List<String>.from(m['userIds'] as List? ?? const []),
      lastText: last?['text'] as String?,
      lastSenderId: last?['senderId'] as String?,
      lastAt: (last?['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
