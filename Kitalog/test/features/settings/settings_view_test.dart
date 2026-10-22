import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/avatar_type.dart';
import 'package:kitalog/features/auth/views/login_view.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../../helpers/fake_avatar_picker.dart';
import '../../helpers/fake_reminder_engine.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

Future<AppDependencies> _openSettings(
  WidgetTester tester, {
  FakeAvatarPicker? picker,
  FakeReminderEngine? reminders,
}) async {
  final deps = await createTestDependencies({}, null, null, null, null, null, reminders);
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

  testWidgets('bildirim desteklenmeyen platformda Bildirimler bölümü görünmez', (tester) async {
    await _openSettings(tester);
    expect(find.text('Bildirimler'), findsNothing);
    expect(find.text('İade hatırlatmaları'), findsNothing);
  });

  testWidgets('iade hatırlatmaları anahtarı kapatılır ve açılınca izin istenir', (tester) async {
    final engine = FakeReminderEngine();
    final deps = await _openSettings(tester, reminders: engine);
    expect(find.text('Bildirimler'), findsOneWidget);
    final toggle = find.widgetWithText(SwitchListTile, 'İade hatırlatmaları');
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(deps.settingsController.state.value.loanRemindersEnabled, isFalse);
    expect(engine.permissionRequests, 0);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(engine.permissionRequests, 1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('bildirim izni verilmezse kullanıcı telefon ayarlarına yönlendirilir', (tester) async {
    final deps = await _openSettings(tester, reminders: FakeReminderEngine(grantPermission: false));
    await deps.settingsController.setLoanRemindersEnabled(false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'İade hatırlatmaları'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bildirim izni kapalı'), findsOneWidget);
  });

  testWidgets('okuma hatırlatmaları varsayılan kapalı; açılınca izin istenir ve saat seçilebilir', (tester) async {
    final engine = FakeReminderEngine();
    final deps = await _openSettings(tester, reminders: engine);
    final daily = find.widgetWithText(SwitchListTile, 'Günlük okuma hatırlatması');
    final stalled = find.widgetWithText(SwitchListTile, 'Yarım kalan kitaplar');
    final time = find.widgetWithText(ListTile, 'Okuma hatırlatması saati');
    expect(tester.widget<SwitchListTile>(daily).value, isFalse);
    expect(tester.widget<SwitchListTile>(stalled).value, isFalse);
    expect(tester.widget<ListTile>(time).enabled, isFalse, reason: 'ikisi de kapalıyken saat seçilmez');
    expect(find.text('21:00'), findsOneWidget);
    expect(find.textContaining('14 gün ilerleme olmazsa'), findsOneWidget);

    await tester.tap(daily);
    await tester.pumpAndSettle();
    expect(deps.settingsController.state.value.readingRemindersEnabled, isTrue);
    expect(engine.permissionRequests, 1);
    expect(tester.widget<ListTile>(time).enabled, isTrue);

    await tester.tap(stalled);
    await tester.pumpAndSettle();
    expect(deps.settingsController.state.value.stalledBookRemindersEnabled, isTrue);
    expect(engine.permissionRequests, 2);

    await tester.tap(time);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();
    expect(deps.settingsController.state.value.readingReminderMinutes, 21 * 60, reason: 'vazgeçince saat değişmez');

    await deps.notificationController.readingReminders.setTime(7 * 60 + 30);
    await tester.pumpAndSettle();
    expect(find.text('07:30'), findsOneWidget);
    expect((await deps.settingsRepository.get()).readingReminderMinutes, 7 * 60 + 30);
  });

  testWidgets('okuma hatırlatmasına izin verilmezse bilgilendirme mesajı çıkar', (tester) async {
    await _openSettings(tester, reminders: FakeReminderEngine(grantPermission: false));
    await tester.tap(find.widgetWithText(SwitchListTile, 'Günlük okuma hatırlatması'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bildirim izni kapalı'), findsOneWidget);
  });
}
