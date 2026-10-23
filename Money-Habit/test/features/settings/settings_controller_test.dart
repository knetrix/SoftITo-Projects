import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/auth/models/avatar_model.dart';
import 'package:money_habit_tracker/features/auth/models/user_model.dart';
import 'package:money_habit_tracker/features/settings/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late SettingsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();

    // Initial mock user
    final user = UserModel(
      id: '1',
      email: 'user@example.com',
      phone: '5551234567',
      passwordHash: 'hash123',
      createdAt: DateTime(2026, 1, 1),
    );
    await storage.writeJson(StorageKeys.user, user.toJson());

    controller = SettingsController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('varsayılan tema dark ve dil tr olarak başlar', () {
    expect(controller.state.value.themeMode, ThemeMode.dark);
    expect(controller.state.value.localeCode, 'tr');
    expect(controller.currentUser.value?.email, 'user@example.com');
  });

  test('tema modu değiştirildiğinde state ve storage güncellenir', () async {
    await controller.setThemeMode(ThemeMode.light);
    expect(controller.state.value.themeMode, ThemeMode.light);

    final savedJson = storage.readJson(StorageKeys.appSettings);
    expect(savedJson?['themeMode'], 'light');
  });

  test('dil değiştirildiğinde state ve storage güncellenir', () async {
    await controller.setLocaleCode('en');
    expect(controller.state.value.localeCode, 'en');

    final savedJson = storage.readJson(StorageKeys.appSettings);
    expect(savedJson?['localeCode'], 'en');
  });

  test('avatar güncellendiğinde user model ve storage güncellenir', () async {
    const avatar = AvatarModel(
      type: AvatarType.preset,
      value: 'assets/avatars/avatar_1.png',
    );

    await controller.updateAvatar(avatar);
    expect(controller.currentUser.value?.avatar?.value, 'assets/avatars/avatar_1.png');

    final userJson = storage.readJson(StorageKeys.user);
    expect(userJson?['avatar']?['value'], 'assets/avatars/avatar_1.png');
  });

  test('kullanıcı güncellendiğinde storage güncellenir', () async {
    final updated = controller.currentUser.value!.copyWith(
      email: 'newemail@example.com',
      phone: '5559876543',
    );

    await controller.updateUser(updated);
    expect(controller.currentUser.value?.email, 'newemail@example.com');
    expect(controller.currentUser.value?.phone, '5559876543');

    final userJson = storage.readJson(StorageKeys.user);
    expect(userJson?['email'], 'newemail@example.com');
  });
}
