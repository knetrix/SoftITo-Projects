import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import 'firebase_providers.dart';

/// Kullanıcının kendi bildirimleri: okuma ve okundu işaretleme.
class NotificationService {
  NotificationService(this._db);
  final FirebaseFirestore _db;

  Stream<List<NotificationModel>> watch(String uid) => _db
      .notificationsOf(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map(NotificationModel.fromDoc).toList());

  Future<void> markRead(String uid, String id) =>
      _db.notificationsOf(uid).doc(id).update({'isRead': true});

  Future<void> markAllRead(String uid, Iterable<String> ids) async {
    final b = _db.batch();
    for (final id in ids) {
      b.update(_db.notificationsOf(uid).doc(id), {'isRead': true});
    }
    await b.commit();
  }
}

final notificationServiceProvider = Provider<NotificationService>(
    (ref) => NotificationService(ref.watch(firestoreProvider)));

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationServiceProvider).watch(uid);
});

final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => !n.isRead).length;
});
