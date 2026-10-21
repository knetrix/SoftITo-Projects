import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/avatar_type.dart';
import 'package:kitalog/core/models/view_status.dart';
import 'package:kitalog/features/settings/controllers/avatar_picker.dart';
import 'package:kitalog/features/settings/controllers/settings_screen_controller.dart';
import 'package:kitalog/features/settings/models/settings_screen_model.dart';

import '../../helpers/fake_avatar_picker.dart';
import '../../helpers/test_dependencies.dart';

Future<(SettingsScreenController, dynamic, FakeAvatarPicker)> _create({
  FakeAvatarPicker? picker,
}) async {
  final deps = await createTestDependencies();
  await deps.authController.register(
    email: 'a@b.com',
    phone: '05321234567',
    password: 'Abcdefg1',
  );
  final fake = picker ?? FakeAvatarPicker(bytes: Uint8List.fromList([1, 2, 3]));
  return (
    SettingsScreenController(auth: deps.authController, avatarPicker: fake),
    deps,
    fake,
  );
}

void main() {
  test('e-posta ve telefon güncellenir, mesaj anahtarı yazılır', () async {
    final (controller, deps, _) = await _create();
    await controller.saveEmail('Yeni@Mail.com');
    expect(deps.authController.user!.email, 'yeni@mail.com');
    expect(controller.state.value.message, SettingsMessage.emailSaved);
    controller.consumeMessage();
    expect(controller.state.value.message, isNull);

    await controller.savePhone('05001112233');
    expect(deps.authController.user!.phone, '05001112233');
    expect(controller.state.value.message, SettingsMessage.phoneSaved);
    controller.dispose();
  });

  test('şifre güncellemede mevcut şifre doğrulanır', () async {
    final (controller, deps, _) = await _create();
    final wrong = await controller.savePassword(
      currentPassword: 'yanlis',
      newPassword: 'Yenisifre1',
    );
    expect(wrong, isFalse);
    expect(controller.state.value.currentPasswordWrong, isTrue);

    controller.clearPasswordError();
    expect(controller.state.value.currentPasswordWrong, isFalse);

    final ok = await controller.savePassword(
      currentPassword: 'Abcdefg1',
      newPassword: 'Yenisifre1',
    );
    expect(ok, isTrue);
    expect(controller.state.value.message, SettingsMessage.passwordSaved);
    await deps.authController.logout();
    expect(await deps.authController.login(email: 'a@b.com', password: 'Yenisifre1'), isNull);
    controller.dispose();
  });

  test('hazır avatar seçme, yükleme ve kaldırma', () async {
    final (controller, deps, picker) = await _create();
    await controller.selectPresetAvatar('avatar_3');
    expect(deps.authController.user!.avatarType, AvatarType.preset);
    expect(deps.authController.user!.avatarValue, 'avatar_3');

    await controller.pickCustomAvatar(AvatarSource.gallery);
    expect(picker.lastSource, AvatarSource.gallery);
    expect(deps.authController.user!.avatarType, AvatarType.custom);
    expect(base64Decode(deps.authController.user!.avatarValue!), [1, 2, 3]);

    await controller.removeAvatar();
    expect(deps.authController.user!.avatarType, AvatarType.none);
    expect(deps.authController.user!.avatarValue, isNull);
    controller.dispose();
  });

  test('seçimden vazgeçilirse avatar değişmez; hata olursa failure mesajı verilir', () async {
    var (controller, deps, _) = await _create(picker: FakeAvatarPicker());
    await controller.pickCustomAvatar(AvatarSource.camera);
    expect(deps.authController.user!.avatarType, AvatarType.none);
    expect(controller.state.value.status, ViewStatus.initial);

    (controller, deps, _) = await _create(picker: FakeAvatarPicker(shouldThrow: true));
    await controller.pickCustomAvatar(AvatarSource.gallery);
    expect(controller.state.value.status, ViewStatus.failure);
    expect(controller.state.value.message, SettingsMessage.avatarFailed);
    expect(deps.authController.user!.avatarType, AvatarType.none);
  });

  test('logout oturumu kapatır ama kullanıcıyı korur', () async {
    final (controller, deps, _) = await _create();
    await controller.logout();
    expect(deps.authController.state.value.isLoggedIn, isFalse);
    expect(deps.authController.user, isNotNull);
    controller.dispose();
  });
}
