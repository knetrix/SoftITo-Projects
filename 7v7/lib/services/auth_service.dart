import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/phone.dart';
import '../core/utils/validators.dart';
import '../models/contact_model.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';

/// Kimlik doğrulama hatası. [key] bir ARB anahtarıdır, [field] hatanın
/// gösterileceği alan ('ident', 'password', 'email', 'phone' ya da null).
class AuthFailure implements Exception {
  const AuthFailure(this.key, {this.field});
  final String key;
  final String? field;
  @override
  String toString() => 'AuthFailure($key)';
}

/// Firebase Auth: e-postayla giriş + kayıt (§6.3). Telefon yalnızca tekillik
/// için `phoneIndex`'e yazılır; dizin kimseye okunmaz (KVKK).
class AuthService {
  AuthService(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Kayıt sırasında kısa süreli oturumda yönlendirmeyi durdurmak için.
  static final ValueNotifier<bool> suppressRedirect = ValueNotifier(false);

  /// E-posta + şifre ile giriş.
  Future<void> signIn(String ident, String password) async {
    final email = ident.trim();
    if (!Validators.isEmail(email)) throw const AuthFailure('eEmail', field: 'ident');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'user-not-found' => const AuthFailure('eNoacct', field: 'ident'),
        'invalid-email' => const AuthFailure('eEmail', field: 'ident'),
        'wrong-password' || 'invalid-credential' || 'INVALID_LOGIN_CREDENTIALS' =>
          const AuthFailure('eWrongpw', field: 'password'),
        _ => const AuthFailure('eGeneric'),
      };
    }
  }

  /// Kayıt: Auth hesabı → `users` + `private/contact` + `phoneIndex` batch.
  /// Telefon tekilliğini `phoneIndex` oluşturma kuralı sağlar (belge varsa
  /// yazma güncelleme sayılır ve reddedilir); o zaman Auth hesabı silinir.
  /// Başarıda oturum kapatılır.
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String locale,
    required String themeMode,
  }) async {
    final digits = normPhone(phone);
    // Firebase Auth e-postayı küçük harfe çevirir; phoneIndex kuralı
    // token.email ile birebir karşılaştırdığı için aynı biçimde saklanır.
    email = email.trim().toLowerCase();

    suppressRedirect.value = true;
    try {
      final UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
      } on FirebaseAuthException catch (e) {
        throw switch (e.code) {
          'email-already-in-use' => const AuthFailure('eExists', field: 'email'),
          'invalid-email' => const AuthFailure('eEmail', field: 'email'),
          'weak-password' => const AuthFailure('ePwlen', field: 'password'),
          _ => const AuthFailure('eGeneric'),
        };
      }
      final user = cred.user!;
      final model = UserModel(
        uid: user.uid,
        firstName: squish(firstName),
        lastName: squish(lastName),
        themeMode: themeMode,
        locale: locale,
      );
      try {
        await user.updateDisplayName(model.fullName);
        final b = _db.batch();
        b.set(_db.users.doc(user.uid), model.toCreateMap());
        b.set(
          _db.contactOf(user.uid),
          ContactModel(email: email, phone: formatPhone(phone), phoneNormalized: digits)
              .toCreateMap(),
        );
        b.set(_db.phoneIndex.doc(digits), {'uid': user.uid});
        await b.commit();
      } catch (_) {
        await user.delete();
        rethrow;
      }
      await _auth.signOut();
    } on AuthFailure {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('ePhoneExists', field: 'phone');
      }
      throw const AuthFailure('eGeneric');
    } finally {
      suppressRedirect.value = false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'user-not-found' => const AuthFailure('eNoacct', field: 'email'),
        'invalid-email' => const AuthFailure('eEmail', field: 'email'),
        _ => const AuthFailure('eGeneric'),
      };
    }
  }

  Future<void> signOut() => _auth.signOut();
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)),
);
