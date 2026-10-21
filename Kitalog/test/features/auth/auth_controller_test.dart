import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/auth_controller.dart';
import 'package:kitalog/core/models/avatar_type.dart';
import 'package:kitalog/core/repositories/auth_repository.dart';
import 'package:kitalog/features/auth/controllers/login_controller.dart';
import 'package:kitalog/features/auth/controllers/register_controller.dart';
import 'package:kitalog/core/models/view_status.dart';

import '../../helpers/test_dependencies.dart';

void main() {
  test('kayıt kullanıcıyı şifre özetiyle saklar ve oturumu açar', () async {
    final deps = await createTestDependencies();
    final auth = deps.authController;
    await auth.register(
      email: '  Ali@Ornek.COM ',
      phone: '05321234567',
      password: 'Abcdefg1',
    );
    final user = auth.user!;
    expect(user.email, 'ali@ornek.com');
    expect(user.passwordHash, isNot('Abcdefg1'));
    expect(user.passwordHash, AuthRepository.hashPassword('Abcdefg1'));
    expect(auth.state.value.isLoggedIn, isTrue);
    expect(await deps.authRepository.isSessionActive(), isTrue);
  });

  test(
    'restoreSession kayıtlı oturumu geri yükler, çıkış oturumu kapatır',
    () async {
      final deps = await createTestDependencies();
      await deps.authController.register(
        email: 'a@b.com',
        phone: '05321234567',
        password: 'Abcdefg1',
      );

      final fresh = AuthController(repository: deps.authRepository);
      expect(await fresh.restoreSession(), isTrue);

      await fresh.logout();
      expect(fresh.state.value.isLoggedIn, isFalse);
      expect(fresh.user, isNotNull, reason: 'Çıkışta veriler silinmez');
      expect(
        await AuthController(repository: deps.authRepository).restoreSession(),
        isFalse,
      );
    },
  );

  test('giriş doğru bilgiyle başarılı, yanlış bilgiyle hata verir', () async {
    final deps = await createTestDependencies();
    final auth = deps.authController;
    await auth.register(
      email: 'a@b.com',
      phone: '05321234567',
      password: 'Abcdefg1',
    );
    await auth.logout();

    expect(
      await auth.login(email: 'a@b.com', password: 'yanlis'),
      AuthError.invalidCredentials,
    );
    expect(
      await auth.login(email: 'x@b.com', password: 'Abcdefg1'),
      AuthError.invalidCredentials,
    );
    expect(await auth.login(email: ' A@B.com ', password: 'Abcdefg1'), isNull);
    expect(auth.state.value.isLoggedIn, isTrue);
  });

  test('e-posta, telefon, şifre ve avatar güncellemesi kalıcıdır', () async {
    final deps = await createTestDependencies();
    final auth = deps.authController;
    await auth.register(
      email: 'a@b.com',
      phone: '05321234567',
      password: 'Abcdefg1',
    );

    await auth.updateEmail('Yeni@Mail.com');
    await auth.updatePhone('05001112233');
    await auth.setAvatar(AvatarType.preset, 'avatar_2');
    expect(
      await auth.updatePassword(
        currentPassword: 'yanlis',
        newPassword: 'Yenisifre1',
      ),
      AuthError.wrongCurrentPassword,
    );
    expect(
      await auth.updatePassword(
        currentPassword: 'Abcdefg1',
        newPassword: 'Yenisifre1',
      ),
      isNull,
    );

    final stored = (await deps.authRepository.getUser())!;
    expect(stored.email, 'yeni@mail.com');
    expect(stored.phone, '05001112233');
    expect(stored.avatarType, AvatarType.preset);
    expect(stored.avatarValue, 'avatar_2');
    expect(
      await auth.login(email: 'yeni@mail.com', password: 'Yenisifre1'),
      isNull,
    );
  });

  test('RegisterController durumu loading → success olur', () async {
    final deps = await createTestDependencies();
    final controller = RegisterController(auth: deps.authController);
    final states = <ViewStatus>[];
    controller.state.addListener(
      () => states.add(controller.state.value.status),
    );
    await controller.submit(
      email: 'a@b.com',
      phone: '05321234567',
      password: 'Abcdefg1',
    );
    expect(states, [ViewStatus.loading, ViewStatus.success]);
    controller.dispose();
  });

  test(
    'LoginController hatalı girişte failure ve hata anahtarı verir',
    () async {
      final deps = await createTestDependencies();
      final controller = LoginController(auth: deps.authController);
      expect(controller.state.value.status, ViewStatus.initial);
      await controller.submit(email: 'a@b.com', password: 'Abcdefg1');
      expect(controller.state.value.status, ViewStatus.failure);
      expect(controller.state.value.error, AuthError.invalidCredentials);
      controller.dispose();
    },
  );
}
