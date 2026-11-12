import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_model.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';

/// `users` okuma ve kendi ayarlarını yazma.
class UserService {
  UserService(this._db);
  final FirebaseFirestore _db;

  Stream<UserModel?> watch(String uid) => _db.users
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? UserModel.fromDoc(d) : null);

  Stream<ContactModel?> watchContact(String uid) => _db
      .contactOf(uid)
      .snapshots()
      .map((d) => d.exists ? ContactModel.fromDoc(d) : null)
      .transform(nullOnDenied());

  Stream<List<UserModel>> watchAll() =>
      _db.users.snapshots().map((q) => q.docs.map(UserModel.fromDoc).toList());

  Future<void> updateSettings(String uid, {String? themeMode, String? locale}) {
    return _db.users.doc(uid).update({
      'settings.themeMode': ?themeMode,
      'settings.locale': ?locale,
    });
  }
}

final userServiceProvider =
    Provider<UserService>((ref) => UserService(ref.watch(firestoreProvider)));

/// Oturum açmış kullanıcının profili.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watch(uid);
});

/// Oturum açmış kullanıcının e-posta / telefonu (yalnızca kendisi okur).
final myContactProvider = StreamProvider<ContactModel?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watchContact(uid);
});

/// Tüm kullanıcılar (arkadaş listesi, adlar). Örnek uygulamada küçük bir küme.
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(userServiceProvider).watchAll();
});

/// uid → kullanıcı.
final usersByIdProvider = Provider<Map<String, UserModel>>((ref) {
  final list = ref.watch(allUsersProvider).value ?? const [];
  return {for (final u in list) u.uid: u};
});
