import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/auth_controller.dart';
import 'package:kitalog/core/repositories/auth_repository.dart';
import 'package:kitalog/features/auth/controllers/forgot_password_controller.dart';
import 'package:kitalog/features/auth/models/forgot_password_model.dart';
import 'package:kitalog/features/auth/views/forgot_password_view.dart';
import 'package:kitalog/features/auth/views/login_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _email = 'ali@ornek.com';
const _phone = '05321234567';
const _oldPassword = 'Abcdefg1';
const _newPassword = 'Yenisifre9';

Future<AuthController> _registeredAuth({DateTime Function()? clock}) async {
  final repository = AuthRepository(await testStorage());
  final auth = AuthController(repository: repository, clock: clock);
  await auth.register(email: _email, phone: _phone, password: _oldPassword);
  await auth.logout();
  return auth;
}

void main() {
  group('AuthController şifremi unuttum', () {
    test('kayıtlı e-posta + telefon eşleşirse doğrulanır; büyük harf ve telefon biçimi önemsizdir', () async {
      final auth = await _registeredAuth();
      expect(await auth.verifyRecovery(email: '  ALI@Ornek.com ', phone: '0 (532) 123 45 67'), isNull);
      expect(await auth.verifyRecovery(email: 'veli@ornek.com', phone: _phone), AuthError.recoveryMismatch);
      expect(await auth.verifyRecovery(email: _email, phone: '05329999999'), AuthError.recoveryMismatch);
    });

    test('5 hatalı denemeden sonra 30 sn kilitlenir; süre dolunca yeniden denenebilir', () async {
      var now = DateTime(2026, 10, 22, 12);
      final auth = await _registeredAuth(clock: () => now);
      for (var i = 0; i < AuthController.maxRecoveryAttempts; i++) {
        expect(await auth.verifyRecovery(email: _email, phone: '05320000000'), AuthError.recoveryMismatch);
      }
      expect(await auth.verifyRecovery(email: _email, phone: _phone), AuthError.tooManyAttempts,
          reason: 'kilitliyken doğru bilgi de kabul edilmez');
      now = now.add(AuthController.recoveryLockout);
      expect(await auth.verifyRecovery(email: _email, phone: _phone), isNull);
    });

    test('şifre sıfırlanır, oturum açılmaz; eski şifre geçmez, yeni şifre geçer', () async {
      final auth = await _registeredAuth();
      expect(await auth.resetPassword(email: _email, phone: '05329999999', newPassword: _newPassword),
          AuthError.recoveryMismatch);
      expect(auth.user!.passwordHash, AuthRepository.hashPassword(_oldPassword));

      expect(await auth.resetPassword(email: _email, phone: _phone, newPassword: _newPassword), isNull);
      expect(auth.state.value.isLoggedIn, isFalse);
      expect(await auth.login(email: _email, password: _oldPassword), AuthError.invalidCredentials);
      expect(await auth.login(email: _email, password: _newPassword), isNull);
    });
  });

  group('ForgotPasswordController', () {
    test('doğrulamadan sonra yeni şifre adımına geçer; geri dönünce bilgiler temizlenir', () async {
      final controller = ForgotPasswordController(auth: await _registeredAuth());
      await controller.verify(email: _email, phone: '05320000000');
      expect(controller.state.value.step, ForgotPasswordStep.verify);
      expect(controller.state.value.error, AuthError.recoveryMismatch);

      await controller.verify(email: _email, phone: _phone);
      expect(controller.state.value.step, ForgotPasswordStep.newPassword);
      expect(controller.state.value.error, isNull);
      controller.backToVerify();
      expect(controller.state.value.step, ForgotPasswordStep.verify);
      expect(controller.state.value.email, isEmpty);

      await controller.verify(email: _email, phone: _phone);
      await controller.resetPassword(_newPassword);
      expect(controller.state.value.isDone, isTrue);
      expect(ForgotPasswordModel.fromJson(controller.state.value.toJson()).email, _email);
      expect(controller.state.value.toJson().containsKey('phone'), isFalse, reason: 'telefon dışarı yazılmaz');
      controller.dispose();
    });
  });

  testWidgets('girişten "Şifremi unuttum" → doğrula → yeni şifre → girişe dön (e-posta dolu) → yeni şifreyle giriş', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await deps.authController.register(email: _email, phone: _phone, password: _oldPassword);
    await deps.authController.logout();
    await pumpScreen(tester, deps, const LoginView(), size: const Size(420, 1100));

    await tester.tap(find.text('Şifremi unuttum'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordView), findsOneWidget);
    expect(find.text('Şifreni Sıfırla'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), _email);
    await tester.enterText(fields.at(1), '05329999999');
    await tester.tap(find.widgetWithText(FilledButton, 'Devam'));
    await tester.pumpAndSettle();
    expect(find.text('E-posta veya telefon kayıtlı bilgilerle eşleşmedi.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), _phone);
    await tester.tap(find.widgetWithText(FilledButton, 'Devam'));
    await tester.pumpAndSettle();
    expect(find.text('$_email hesabı doğrulandı. Yeni şifreni belirle.'), findsOneWidget);
    expect(find.text('E-posta veya telefon kayıtlı bilgilerle eşleşmedi.'), findsNothing);

    // Kayıt ekranıyla aynı şifre kuralları.
    await tester.enterText(find.byType(TextFormField).at(0), 'kisa');
    await tester.enterText(find.byType(TextFormField).at(1), 'baska');
    await tester.tap(find.widgetWithText(FilledButton, 'Şifreyi Güncelle'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordView), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), _newPassword);
    await tester.enterText(find.byType(TextFormField).at(1), _newPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Şifreyi Güncelle'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordView), findsNothing);
    expect(find.text('Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, _email), findsOneWidget, reason: 'e-posta önceden dolu');

    await tester.enterText(find.byType(TextFormField).at(1), _newPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pumpAndSettle();
    expect(deps.authController.state.value.isLoggedIn, isTrue);
  });

  testWidgets('"Girişe dön" ve "Geri" akışı bozmaz', (tester) async {
    final deps = await createTestDependencies();
    await deps.authController.register(email: _email, phone: _phone, password: _oldPassword);
    await deps.authController.logout();
    await pumpScreen(tester, deps, const LoginView(), size: const Size(420, 1100));
    await tester.tap(find.text('Şifremi unuttum'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), _email);
    await tester.enterText(find.byType(TextFormField).at(1), _phone);
    await tester.tap(find.widgetWithText(FilledButton, 'Devam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Geri'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Devam'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Girişe dön'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(ForgotPasswordView), findsNothing);
    expect(find.byType(SnackBar), findsNothing, reason: 'şifre değişmedi, bilgi mesajı yok');
  });
}
