import 'package:flutter/foundation.dart';
import '../../auth/models/user_model.dart';
import '../../../core/services/storage_service.dart';

class ProfileController {
  final StorageService _storageService;
  final ValueNotifier<UserModel?> userNotifier = ValueNotifier<UserModel?>(null);
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('tr');

  ProfileController(this._storageService) {
    _loadData();
  }

  void _loadData() {
    userNotifier.value = _storageService.loadUser();
    isDarkModeNotifier.value = _storageService.loadDarkMode();
    languageNotifier.value = _storageService.loadLanguage();
  }

  void syncUser(UserModel? user) {
    userNotifier.value = user;
  }

  Future<void> toggleDarkMode(bool val) async {
    isDarkModeNotifier.value = val;
    await _storageService.saveDarkMode(val);
    if (userNotifier.value != null) {
      final updated = userNotifier.value!.copyWith(isDarkMode: val);
      userNotifier.value = updated;
      await _storageService.saveUser(updated);
    }
  }

  Future<void> setLanguage(String lang) async {
    languageNotifier.value = lang;
    await _storageService.saveLanguage(lang);
    if (userNotifier.value != null) {
      final updated = userNotifier.value!.copyWith(preferredLanguage: lang);
      userNotifier.value = updated;
      await _storageService.saveUser(updated);
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    if (userNotifier.value == null) return;
    final updated = userNotifier.value!.copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatarUrl: avatarUrl ?? userNotifier.value!.avatarUrl,
    );
    userNotifier.value = updated;
    await _storageService.saveUser(updated);
  }

  void addPoints(int points) {
    if (userNotifier.value == null) return;
    final current = userNotifier.value!;
    final newPoints = (current.totalPoints + points).clamp(0, 999999);

    String rank = current.currentRank;
    if (newPoints > 1500) {
      rank = 'Efsane Lider (Seviye 5)';
    } else if (newPoints > 800) {
      rank = 'Usta Odakçı (Seviye 4)';
    } else if (newPoints > 400) {
      rank = 'İstikrarlı Yolcu (Seviye 3)';
    } else if (newPoints > 150) {
      rank = 'Çırak Rutinci (Seviye 2)';
    }

    final updated = current.copyWith(
      totalPoints: newPoints,
      currentRank: rank,
    );
    userNotifier.value = updated;
    _storageService.saveUser(updated);
  }

  void dispose() {
    userNotifier.dispose();
    isDarkModeNotifier.dispose();
    languageNotifier.dispose();
  }
}
