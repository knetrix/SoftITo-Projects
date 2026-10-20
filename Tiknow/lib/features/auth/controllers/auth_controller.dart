import 'package:flutter/foundation.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/password_hasher.dart';
import '../../../core/utils/validators.dart';
import '../models/user_model.dart';

enum AuthState { unauthenticated, authenticated, loading, failure }

/// Yerel (backend'siz) kimlik doğrulama. Tek hesap saklanır; şifre
/// SHA-256 + salt ile hash'lenir.
class AuthController {
  AuthController(this._storage)
      : user = ValueNotifier<UserModel?>(_storage.loadUser()),
        state = ValueNotifier<AuthState>(AuthState.unauthenticated),
        errorKey = ValueNotifier<String?>(null) {
    if (user.value != null && _storage.isSessionActive) {
      state.value = AuthState.authenticated;
    }
  }

  final StorageService _storage;
  final ValueNotifier<UserModel?> user;
  final ValueNotifier<AuthState> state;

  /// Son hatanın `AppStrings` anahtarı (view `context.tr` ile çözer).
  final ValueNotifier<String?> errorKey;

  bool get hasAccount => user.value != null;

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
  }) async {
    final error = Validators.email(email) ??
        Validators.phone(phone) ??
        Validators.password(password) ??
        Validators.passwordConfirm(passwordConfirm, password);
    if (error != null) return _fail(error);

    state.value = AuthState.loading;
    errorKey.value = null;
    final salt = PasswordHasher.generateSalt();
    final created = UserModel(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      phone: Validators.normalizePhone(phone),
      passwordHash: PasswordHasher.hash(password, salt),
      salt: salt,
    );
    await _storage.saveUser(created);
    await _storage.setSessionActive(true);
    user.value = created;
    state.value = AuthState.authenticated;
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    final error = Validators.email(email) ??
        (password.isEmpty ? 'err_password_required' : null);
    if (error != null) return _fail(error);

    state.value = AuthState.loading;
    errorKey.value = null;
    final account = user.value;
    final valid = account != null &&
        account.email == email.trim().toLowerCase() &&
        PasswordHasher.verify(password, account.salt, account.passwordHash);
    if (!valid) return _fail('err_login_failed');

    await _storage.setSessionActive(true);
    state.value = AuthState.authenticated;
    return true;
  }

  Future<void> logout() async {
    await _storage.setSessionActive(false);
    errorKey.value = null;
    state.value = AuthState.unauthenticated;
  }

  /// Profil denetleyicisi kullanıcıyı güncelledikten sonra çağırır.
  Future<void> updateUser(UserModel updated) async {
    await _storage.saveUser(updated);
    user.value = updated;
  }

  void clearError() => errorKey.value = null;

  bool _fail(String key) {
    errorKey.value = key;
    state.value = AuthState.failure;
    return false;
  }

  void dispose() {
    user.dispose();
    state.dispose();
    errorKey.dispose();
  }
}
