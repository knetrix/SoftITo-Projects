import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../core/services/storage_service.dart';

class AuthController {
  final StorageService _storageService;
  final ValueNotifier<UserModel?> userNotifier = ValueNotifier<UserModel?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);

  AuthController(this._storageService) {
    _loadInitialUser();
  }

  void _loadInitialUser() {
    userNotifier.value = _storageService.loadUser();
  }

  bool get isAuthenticated => userNotifier.value != null;

  Future<bool> login(String email, String password) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    await Future.delayed(const Duration(milliseconds: 500));

    final existingUser = _storageService.loadUser();
    if (existingUser != null && existingUser.email == email.trim()) {
      userNotifier.value = existingUser;
      isLoadingNotifier.value = false;
      return true;
    }

    // Başarılı giriş ile yeni veya mevcut kullanıcı oturumu
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.toUpperCase(),
      email: email.trim(),
      totalPoints: 250,
    );
    await _storageService.saveUser(user);
    userNotifier.value = user;
    isLoadingNotifier.value = false;
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    await Future.delayed(const Duration(milliseconds: 500));

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      totalPoints: 100, // Hoş geldin bonusu
    );

    await _storageService.saveUser(newUser);
    userNotifier.value = newUser;
    isLoadingNotifier.value = false;
    return true;
  }

  Future<void> guestLogin() async {
    isLoadingNotifier.value = true;
    const guestUser = UserModel(
      id: 'guest_user',
      name: 'Misafir Kullanıcı',
      email: 'misafir@rutino.com',
      totalPoints: 50,
    );
    await _storageService.saveUser(guestUser);
    userNotifier.value = guestUser;
    isLoadingNotifier.value = false;
  }

  Future<void> logout() async {
    await _storageService.clearUser();
    userNotifier.value = null;
  }

  void dispose() {
    userNotifier.dispose();
    isLoadingNotifier.dispose();
    errorNotifier.dispose();
  }
}
