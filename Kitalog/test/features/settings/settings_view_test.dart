import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/avatar_type.dart';
import 'package:kitalog/features/auth/views/login_view.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../../helpers/fake_avatar_picker.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

Future<AppDependencies> _openSettings(WidgetTester tester, {FakeAvatarPicker? picker}) async {
  final deps = await createTestDependencies();
  await deps.authController.register(
    email: 'a@b.com',
    phone: '05321234567',
    password: 'Abcdefg1',
  );
  await deps.settingsController.load();
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    deps.scope(child: KitalogAppWithHome(home: SettingsView(avatarPicker: picker))),
  );
  await tester.pumpAndSettle();
  return deps;
}

void main() {
  testWidgets('profil özeti e-posta ve maskeli telefonu gösterir', (tester) async {
    await _openSettings(tester);
    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('0 (532) 123 45 67'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
  });

  testWidgets('tema ve dil anında değişir ve kalıcı yazılır', (tester) async {
    final deps = await _openSettings(tester);
    expect(deps.settingsController.state.value.themeMode, ThemeMode.dark);
    await tester.tap(find.text('Aydınlık'));
    await tester.pumpAndSettle();
    expect(deps.settingsController.state.value.themeMode, ThemeMode.light);
    expect((await deps.settingsRepository.get()).themeMode, ThemeMode.light);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect((await deps.settingsRepository.get()).localeCode, 'en');
  });

  testWidgets('e-posta güncelleme aynı doğrulamayı kullanır', (tester) async {
    final deps = await _openSettings(tester);
    await tester.tap(find.text('E-posta adresini güncelle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'gecersiz');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Yeni@Mail.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(deps.authController.user!.email, 'yeni@mail.com');
    expect(find.text('E-posta güncellendi.'), findsOneWidget);
  });

  testWidgets('telefon güncelleme maske ve doğrulama uygular', (tester) async {
    final deps = await _openSettings(tester);
    await tester.tap(find.text('Telefon numarasını güncelle'));
    await tester.pumpAndSettle();
    final field = find.byType(TextFormField).first;
    await tester.enterText(field, '0432');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Telefon 0 ile başlamalı'), findsOneWidget);

    await tester.enterText(field, '05001112233');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(deps.authController.user!.phone, '05001112233');
  });

  testWidgets('şifre güncelleme yanlış mevcut şifrede hata gösterir', (tester) async {
    final deps = await _openSettings(tester);
    await tester.tap(find.text('Şifreyi güncelle'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'yanlis');
    await tester.enterText(fields.at(1), 'Yenisifre1');
    await tester.enterText(fields.at(2), 'Yenisifre1');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Mevcut şifre hatalı.'), findsOneWidget);

    await tester.enterText(fields.at(0), 'Abcdefg1');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Şifre güncellendi.'), findsOneWidget);
    await deps.authController.logout();
    expect(await deps.authController.login(email: 'a@b.com', password: 'Yenisifre1'), isNull);
  });

  testWidgets('hazır avatar seçilir ve yüklenen resim kaydedilir', (tester) async {
    final picker = FakeAvatarPicker(bytes: null);
    final deps = await _openSettings(tester, picker: picker);
    await tester.tap(find.byTooltip('Profil resmini değiştir').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('avatar_2'));
    await tester.pumpAndSettle();
    expect(deps.authController.user!.avatarType, AvatarType.preset);
    expect(deps.authController.user!.avatarValue, 'avatar_2');

    await tester.tap(find.byTooltip('Profil resmini değiştir').first);
    await tester.pumpAndSettle();
    expect(find.text('Kamerayla çek'), findsOneWidget);
    await tester.tap(find.text('Profil resmini kaldır'));
    await tester.pumpAndSettle();
    expect(deps.authController.user!.avatarType, AvatarType.none);
  });

  testWidgets('çıkış yap oturumu kapatır ve giriş ekranına döner', (tester) async {
    final deps = await _openSettings(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Çıkış Yap'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Çıkış Yap'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(deps.authController.state.value.isLoggedIn, isFalse);
    expect(deps.authController.user, isNotNull);
  });
}
