import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import 'firebase_providers.dart';

/// Sohbetler yalnızca arkadaşlar arasında (§5.6, §6.3 "Mesaj gönder").
class ChatService {
  ChatService(this._db);
  final FirebaseFirestore _db;

  Stream<List<ChatModel>> watchChats(String uid) => _db.chats
      .where('userIds', arrayContains: uid)
      .snapshots()
      .map((q) => q.docs.map(ChatModel.fromDoc).toList()
        ..sort((a, b) => (b.updatedAt ?? DateTime(9999))
            .compareTo(a.updatedAt ?? DateTime(9999))));

  Stream<List<MessageModel>> watchMessages(String chatId) => _db.chats
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((q) => q.docs.map(MessageModel.fromDoc).toList());

  /// Mesaj + sohbet özeti + karşı tarafa `msg_{chatId}` (tek batch).
  Future<void> send({
    required String me,
    required String other,
    required String text,
  }) async {
    final chatId = pairId(me, other);
    final chat = _db.chats.doc(chatId);
    final msg = chat.collection('messages').doc();
    final b = _db.batch();
    b.set(chat, {
      'userIds': chatId.split('_'),
      'lastMessage': {
        'text': text,
        'senderId': me,
        'createdAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    b.set(msg, {
      'senderId': me,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    b.set(_db.notificationsOf(other).doc(NotificationModel.messageId(chatId)), {
      'type': 'message',
      'relatedId': chatId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await b.commit();
  }
}

final chatServiceProvider =
    Provider<ChatService>((ref) => ChatService(ref.watch(firestoreProvider)));

final myChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(chatServiceProvider).watchChats(uid);
});

final messagesProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>(
  (ref, chatId) => ref.watch(chatServiceProvider).watchMessages(chatId),
);
