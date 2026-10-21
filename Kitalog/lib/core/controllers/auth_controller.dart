import 'package:flutter/foundation.dart';

import '../models/avatar_type.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthError { invalidCredentials, wrongCurrentPassword }

@immutable
class AuthState {
  final UserModel? user;
  final bool isLoggedIn;

  const AuthState({this.user, this.isLoggedIn = false});
}

/// Kullanıcı ve oturum durumunu tutan paylaşılan controller.
class AuthController {
  AuthController({required this._repository});

  final AuthRepository _repository;
  final ValueNotifier<AuthState> state = ValueNotifier<AuthState>(
    const AuthState(),
  );

  UserModel? get user => state.value.user;

  /// Kayıtlı oturum varsa durumu yükler ve `true` döner.
  Future<bool> restoreSession() async {
    final user = await _repository.getUser();
    final active = await _repository.isSessionActive();
    final loggedIn = user != null && active;
    state.value = AuthState(user: user, isLoggedIn: loggedIn);
    return loggedIn;
  }

  Future<void> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email.trim().toLowerCase(),
      phone: phone,
      passwordHash: AuthRepository.hashPassword(password),
      createdAt: DateTime.now(),
    );
    await _repository.saveUser(user);
    await _repository.setSessionActive(true);
    state.value = AuthState(user: user, isLoggedIn: true);
  }

  /// Başarılıysa `null`, değilse hata döner.
  Future<AuthError?> login({
    required String email,
    required String password,
  }) async {
    final user = await _repository.getUser();
    final ok =
        user != null &&
        user.email == email.trim().toLowerCase() &&
        user.passwordHash == AuthRepository.hashPassword(password);
    if (!ok) return AuthError.invalidCredentials;
    await _repository.setSessionActive(true);
    state.value = AuthState(user: user, isLoggedIn: true);
    return null;
  }

  /// Oturumu kapatır; kullanıcı ve kitap verileri silinmez.
  Future<void> logout() async {
    await _repository.setSessionActive(false);
    state.value = AuthState(user: state.value.user);
  }

  Future<void> updateEmail(String email) {
    return _update((u) => u.copyWith(email: email.trim().toLowerCase()));
  }

  Future<void> updatePhone(String phone) {
    return _update((u) => u.copyWith(phone: phone));
  }

  Future<AuthError?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final current = user;
    if (current == null ||
        current.passwordHash != AuthRepository.hashPassword(currentPassword)) {
      return AuthError.wrongCurrentPassword;
    }
    await _update(
      (u) => u.copyWith(passwordHash: AuthRepository.hashPassword(newPassword)),
    );
    return null;
  }

  Future<void> setAvatar(AvatarType type, String? value) {
    return _update(
      (u) => u.copyWith(
        avatarType: type,
        avatarValue: value,
        clearAvatarValue: value == null,
      ),
    );
  }

  Future<void> _update(UserModel Function(UserModel) change) async {
    final current = user;
    if (current == null) return;
    final next = change(current);
    await _repository.saveUser(next);
    state.value = AuthState(user: next, isLoggedIn: state.value.isLoggedIn);
  }

  void dispose() {
    state.dispose();
  }
}
