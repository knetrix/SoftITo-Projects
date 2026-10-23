import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/password_hasher.dart';
import '../../../core/utils/validators.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, success, failure }

@immutable
class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool clearError = false,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }
}

class AuthController {
  final LocalStorageService _storage;
  final ValueNotifier<AuthState> state;

  static const String testEmail = 'demo@moneyhabit.com';
  static const String testPassword = 'Password123';
  static const String testPhone = '5551234567';

  AuthController(this._storage)
      : state = ValueNotifier<AuthState>(
          AuthState(
            user: _loadUser(_storage),
          ),
        );

  static UserModel? _loadUser(LocalStorageService storage) {
    final json = storage.readJson(StorageKeys.user);
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    state.value = state.value.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final existing = _storage.readJson(StorageKeys.user);
    if (existing != null) {
      final existingUser = UserModel.fromJson(existing);
      if (existingUser.email.toLowerCase() == email.trim().toLowerCase()) {
        state.value = state.value.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'userAlreadyExists',
        );
        return false;
      }
    }

    final newUser = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email.trim(),
      phone: Validators.normalizePhone(phone),
      passwordHash: PasswordHasher.hash(password),
      createdAt: DateTime.now(),
    );

    await _storage.writeJson(StorageKeys.user, newUser.toJson());
    await _storage.setLoggedIn(true);

    state.value = state.value.copyWith(
      status: AuthStatus.success,
      user: newUser,
    );
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state.value = state.value.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final json = _storage.readJson(StorageKeys.user);

    if (json == null) {
      if (email.trim().toLowerCase() == testEmail && password == testPassword) {
        return quickLogin();
      }
      state.value = state.value.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'loginFailed',
      );
      return false;
    }

    final user = UserModel.fromJson(json);
    final emailMatches = user.email.toLowerCase() == email.trim().toLowerCase();
    final passwordMatches = PasswordHasher.verify(password, user.passwordHash);

    if (emailMatches && passwordMatches) {
      await _storage.setLoggedIn(true);
      state.value = state.value.copyWith(
        status: AuthStatus.success,
        user: user,
      );
      return true;
    }

    state.value = state.value.copyWith(
      status: AuthStatus.failure,
      errorMessage: 'loginFailed',
    );
    return false;
  }

  Future<bool> quickLogin() async {
    state.value = state.value.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final json = _storage.readJson(StorageKeys.user);
    UserModel user;
    if (json != null) {
      user = UserModel.fromJson(json);
    } else {
      user = UserModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        email: testEmail,
        phone: testPhone,
        passwordHash: PasswordHasher.hash(testPassword),
        createdAt: DateTime.now(),
      );
      await _storage.writeJson(StorageKeys.user, user.toJson());
    }

    await _storage.setLoggedIn(true);
    state.value = state.value.copyWith(
      status: AuthStatus.success,
      user: user,
    );
    return true;
  }

  Future<void> logout() async {
    await _storage.setLoggedIn(false);
    state.value = state.value.copyWith(status: AuthStatus.initial);
  }

  void dispose() {
    state.dispose();
  }
}
