import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/avatar_type.dart';
import '../../../core/models/view_status.dart';
import '../models/settings_screen_model.dart';
import 'avatar_picker.dart';

/// Ayarlar ekranının hesap güncelleme ve profil resmi işlemleri.
/// Tema/dil doğrudan paylaşılan `SettingsController` ile değiştirilir.
class SettingsScreenController {
  SettingsScreenController({
    required this._auth,
    required this._avatarPicker,
  });

  final AuthController _auth;
  final AvatarPicker _avatarPicker;

  final ValueNotifier<SettingsScreenModel> state =
      ValueNotifier<SettingsScreenModel>(const SettingsScreenModel());

  bool get cameraAvailable => _avatarPicker.cameraAvailable;

  Future<bool> saveEmail(String email) async {
    await _auth.updateEmail(email);
    _notify(SettingsMessage.emailSaved);
    return true;
  }

  Future<bool> savePhone(String phoneDigits) async {
    await _auth.updatePhone(phoneDigits);
    _notify(SettingsMessage.phoneSaved);
    return true;
  }

  /// Mevcut şifre doğrulanır; yanlışsa `false` döner ve işaret state'e yazılır.
  Future<bool> savePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final error = await _auth.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (error != null) {
      state.value = state.value.copyWith(currentPasswordWrong: true);
      return false;
    }
    _notify(SettingsMessage.passwordSaved, clearWrongPassword: true);
    return true;
  }

  void clearPasswordError() {
    if (state.value.currentPasswordWrong) {
      state.value = state.value.copyWith(currentPasswordWrong: false);
    }
  }

  Future<void> selectPresetAvatar(String key) async {
    await _auth.setAvatar(AvatarType.preset, key);
    _notify(SettingsMessage.avatarSaved);
  }

  Future<void> removeAvatar() async {
    await _auth.setAvatar(AvatarType.none, null);
    _notify(SettingsMessage.avatarSaved);
  }

  /// Galeriden/kameradan seçilen resmi küçültülmüş baytlar olarak kaydeder.
  /// Bayt (base64) saklama web dahil tüm platformlarda çalışır ve kalıcıdır.
  Future<void> pickCustomAvatar(AvatarSource source) async {
    state.value = state.value.copyWith(status: ViewStatus.loading);
    try {
      final bytes = await _avatarPicker.pick(source);
      if (bytes == null) {
        state.value = state.value.copyWith(status: ViewStatus.initial);
        return;
      }
      await _auth.setAvatar(AvatarType.custom, base64Encode(bytes));
      _notify(SettingsMessage.avatarSaved);
    } on Exception {
      state.value = state.value.copyWith(
        status: ViewStatus.failure,
        message: SettingsMessage.avatarFailed,
      );
    }
  }

  void consumeMessage() {
    state.value = state.value.copyWith(clearMessage: true);
  }

  Future<void> logout() => _auth.logout();

  void _notify(SettingsMessage message, {bool clearWrongPassword = false}) {
    state.value = state.value.copyWith(
      status: ViewStatus.success,
      message: message,
      currentPasswordWrong: clearWrongPassword ? false : null,
    );
  }

  void dispose() {
    state.dispose();
  }
}
