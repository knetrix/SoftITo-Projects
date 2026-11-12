// Tanıtım videosu senaryosu: gerçek uygulama, emülatördeki örnek veriyle
// (test/emulator_seed), insan hızında dokunup yazarak gezilir. Ekran kaydı
// dışarıdan alınır (xcrun simctl io recordVideo); her sahnenin başlangıcı
// `DEMO_SCENE <ad> <epoch ms>` olarak yazdırılır.
//
//   flutter test integration_test/demo_recording_test.dart -d <simülatör> \
//     --dart-define=DEMO=true
import 'package:app_7v7/app/app.dart';
import 'package:app_7v7/app/theme/theme_controller.dart';
import 'package:app_7v7/core/widgets/app_button.dart';
import 'package:app_7v7/core/widgets/app_icons.dart';
import 'package:app_7v7/core/widgets/app_text_field.dart';
import 'package:app_7v7/core/widgets/app_toast.dart';
import 'package:app_7v7/core/widgets/icon_circle_button.dart';
import 'package:app_7v7/core/widgets/notification_bell.dart';
import 'package:app_7v7/core/widgets/option_tile.dart';
import 'package:app_7v7/firebase_options.dart';
import 'package:app_7v7/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _on = bool.fromEnvironment('DEMO');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('demo', (t) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    await FirebaseAuth.instance.signOut();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Future<void> wait(int ms) async {
      final end = DateTime.now().add(Duration(milliseconds: ms));
      while (DateTime.now().isBefore(end)) {
        await t.pump(const Duration(milliseconds: 16));
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    }

    Future<void> until(Finder f, {int secs = 30}) async {
      final end = DateTime.now().add(Duration(seconds: secs));
      while (f.evaluate().isEmpty) {
        if (DateTime.now().isAfter(end)) fail('bulunamadı: $f');
        await wait(50);
      }
    }

    Future<void> tap(Finder f, {int after = 700}) async {
      await until(f);
      await t.ensureVisible(f.first);
      await wait(400); // açılış / kaydırma animasyonu otursun
      await t.tap(f.first);
      await wait(after);
    }

    AppLocalizations l() => AppLocalizations.of(t.element(find.byType(Scaffold).last));
    Finder button(String s) => find.widgetWithText(AppButton, s);
    Finder field(String label) => find.descendant(
        of: find.widgetWithText(AppTextField, label), matching: find.byType(TextField));

    // İnsan hızında yazma.
    Future<void> type(Finder f, String text) async {
      await until(f);
      await t.tap(f.first);
      await wait(200);
      for (var i = 1; i <= text.length; i++) {
        await t.enterText(f.first, text.substring(0, i));
        await wait(45);
      }
      await wait(250);
    }

    void scene(String name) =>
        debugPrint('DEMO_SCENE $name ${DateTime.now().millisecondsSinceEpoch}');

    await t.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const SevenApp(),
    ));
    await until(button('Başla'));
    await wait(1500);

    // Kayıt başlasın diye işaret; sahneler buradan itibaren.
    scene('ready');
    await wait(2500);

    // 1) Hoş geldin → giriş
    scene('welcome');
    await wait(1600);
    await tap(button('Başla'), after: 800);
    scene('signin');
    await type(field(l().fEmail), 'kerem@7v7.app');
    await type(field(l().fPw), 'demo12345');
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(300);
    await tap(button(l().siBtn), after: 300);
    await until(find.text(l().tabTeam));
    await wait(1400);

    // 2) Takım kur: saat ve diziliş
    scene('team');
    await wait(600);
    await tap(find.byIcon(PhosphorIconsFill.clock), after: 800);
    await tap(find.widgetWithText(OptionTile, '20:00–21:00'), after: 1000);
    scene('formation');
    await tap(find.ancestor(of: find.textContaining('Diziliş'), matching: find.byType(AppButton)),
        after: 900);
    await tap(find.text('3-2-1'), after: 2000);
    AppToast.hide(); // bildirim görüldü; sonraki sahnelere taşmasın

    // 3) Randevularım → detay
    scene('appointments');
    await tap(find.text(l().tabAppts), after: 1400);
    await tap(find.text('Karşıyaka Arena'), after: 1200);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -420));
    await wait(1300);
    await tap(find.byType(IconCircleButton), after: 700);

    // 4) Arkadaşı maça davet et
    scene('invite');
    await tap(find.text(l().tabSocial), after: 1100);
    await tap(button(l().invFriend), after: 1300);
    await tap(button(l().invSend), after: 1800);
    AppToast.hide();

    // 5) Sohbet
    scene('chat');
    await tap(find.descendant(of: find.byType(AppSegment), matching: find.text(l().soChats)),
        after: 1000);
    await tap(find.text('Burak Demir'), after: 1000);
    await type(find.byType(TextField).last, 'Akşam 21:00, sahada görüşürüz! ⚽');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await wait(1500);
    await tap(find.byType(IconCircleButton).first, after: 600);

    // 6) Bildirimler
    scene('notifications');
    await tap(find.byType(NotificationBell).first, after: 1800);
    await tap(find.byType(IconCircleButton).first, after: 600);

    // 7) Profil → karanlık mod
    scene('dark');
    await tap(find.text(l().tabProfile), after: 1000);
    await tap(find.text(l().dark), after: 1300);
    await tap(find.text(l().tabTeam), after: 2200);

    scene('end');
    await wait(1500);
    await FirebaseAuth.instance.signOut();
  }, skip: !_on, timeout: const Timeout(Duration(minutes: 5)));
}
