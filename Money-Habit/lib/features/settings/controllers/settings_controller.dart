import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/models/avatar_model.dart';
import '../../auth/models/user_model.dart';
import '../models/app_settings_model.dart';

class SettingsController {
  final LocalStorageService _storage;
  final ValueNotifier<AppSettingsModel> state;
  final ValueNotifier<UserModel?> currentUser;

  SettingsController(this._storage)
      : state = ValueNotifier<AppSettingsModel>(_loadSettings(_storage)),
        currentUser = ValueNotifier<UserModel?>(_loadUser(_storage));

  static AppSettingsModel _loadSettings(LocalStorageService storage) {
    final json = storage.readJson(StorageKeys.appSettings);
    if (json == null) return const AppSettingsModel();
    return AppSettingsModel.fromJson(json);
  }

  static UserModel? _loadUser(LocalStorageService storage) {
    final json = storage.readJson(StorageKeys.user);
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  void refreshUser() {
    currentUser.value = _loadUser(_storage);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state.value = state.value.copyWith(themeMode: mode);
    await _storage.writeJson(StorageKeys.appSettings, state.value.toJson());
  }

  Future<void> setLocaleCode(String code) async {
    state.value = state.value.copyWith(localeCode: code);
    await _storage.writeJson(StorageKeys.appSettings, state.value.toJson());
  }

  Future<void> updateAvatar(AvatarModel? avatar) async {
    final user = currentUser.value;
    if (user == null) return;
    final updated = user.copyWith(avatar: avatar, clearAvatar: avatar == null);
    currentUser.value = updated;
    await _storage.writeJson(StorageKeys.user, updated.toJson());
  }

  Future<void> updateUser(UserModel updated) async {
    currentUser.value = updated;
    await _storage.writeJson(StorageKeys.user, updated.toJson());
  }

  void dispose() {
    state.dispose();
    currentUser.dispose();
  }
}
