// README ekran görüntüleri: gerçek ekranlar, örnek veriyle (test/emulator_seed),
// 390×844 @3x. Yalnızca bilerek üretilir:
//
//   flutter test test/screenshots_test.dart --update-goldens --dart-define=SCREENSHOTS=true
//
// Çıktı: docs/screenshots/*.png
import 'package:app_7v7/core/widgets/app_icons.dart';
import 'package:app_7v7/features/appointments/appointment_detail_screen.dart';
import 'package:app_7v7/features/appointments/appointments_screen.dart';
import 'package:app_7v7/features/auth/signin_screen.dart';
import 'package:app_7v7/features/auth/signup_screen.dart';
import 'package:app_7v7/features/notifications/notifications_screen.dart';
import 'package:app_7v7/features/onboarding/welcome_screen.dart';
import 'package:app_7v7/features/profile/profile_screen.dart';
import 'package:app_7v7/features/social/chat_screen.dart';
import 'package:app_7v7/features/social/invite_detail_screen.dart';
import 'package:app_7v7/features/social/social_screen.dart';
import 'package:app_7v7/features/team/team_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/harness.dart';

const _on = bool.fromEnvironment('SCREENSHOTS');

void main() {
  final f = Fixture.load();

  setUpAll(() async {
    freezeClock();
    await loadFonts();
  });

  void phone(WidgetTester t) {
    const size = Size(390, 844);
    t.view.physicalSize = size * 3;
    t.view.devicePixelRatio = 3;
    t.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
    t.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
    addTearDown(t.view.reset);
  }

  // (dosya, ekran, sekme, karanlık, dil, boş hesap, açılacak panelin hedefi)
  final shots = <(String, Widget Function(), int?, bool, String, bool, Finder Function()?)>[
    ('01-welcome', () => const WelcomeScreen(), null, false, 'tr', false, null),
    ('02-signin', () => const SignInScreen(), null, false, 'tr', false, null),
    ('03-signup', () => const SignUpScreen(), null, false, 'tr', false, null),
    ('04-forgot-password', () => const SignInScreen(), null, false, 'tr', false,
        () => find.text('Şifremi unuttum')),
    ('05-team', () => const TeamScreen(), 0, false, 'tr', false, null),
    ('06-formation-sheet', () => const TeamScreen(), 0, false, 'tr', false,
        () => find.byIcon(PhosphorIconsFill.strategy)),
    ('07-player-sheet', () => const TeamScreen(), 0, false, 'tr', false,
        () => find.text('Emre')),
    ('08-time-sheet', () => const TeamScreen(), 0, false, 'tr', false,
        () => find.byIcon(PhosphorIconsFill.clock)),
    ('09-appointments', () => const AppointmentsScreen(), 1, false, 'tr', false, null),
    ('10-detail-owner', () => const AppointmentDetailScreen(id: 'a1'), null, false, 'tr', false, null),
    ('11-detail-guest', () => const AppointmentDetailScreen(id: 'e1'), null, false, 'tr', false, null),
    ('12-friends', () => const SocialScreen(), 3, false, 'tr', false, null),
    ('13-invite-sheet', () => const SocialScreen(), 3, false, 'tr', false,
        () => find.text('Maça davet et')),
    ('14-invite-detail', () => const InviteDetailScreen(id: 'i1'), null, false, 'tr', false, null),
    ('15-chats', () => const SocialScreen(tab: 'chats'), 3, false, 'tr', false, null),
    ('16-chat', () => const ChatScreen(chatId: 'u0_u2'), null, false, 'tr', false, null),
    ('17-notifications', () => const NotificationsScreen(), null, false, 'tr', false, null),
    ('18-profile', () => const ProfileScreen(), 2, false, 'tr', false, null),
    ('19-delete-account', () => const ProfileScreen(), 2, false, 'tr', false,
        () => find.text('Hesabı sil')),
    ('20-team-dark', () => const TeamScreen(), 0, true, 'tr', false, null),
    ('21-appointments-dark', () => const AppointmentsScreen(), 1, true, 'tr', false, null),
    ('22-chat-dark', () => const ChatScreen(chatId: 'u0_u2'), null, true, 'tr', false, null),
    ('23-team-en', () => const TeamScreen(), 0, false, 'en', false, null),
    ('24-appointments-empty', () => const AppointmentsScreen(), 1, false, 'tr', true, null),
  ];

  for (final (name, build, tab, dark, locale, empty, target) in shots) {
    testWidgets(name, (t) async {
      phone(t);
      await pumpScreen(
        t,
        build(),
        overrides: await overridesFor(
          f,
          uid: empty ? 'u9' : 'u0',
          dark: dark,
          locale: locale,
          emptyAccount: empty,
        ),
        dark: dark,
        locale: locale,
        tab: tab,
      );
      if (target != null) {
        final x = target().first;
        await t.ensureVisible(x);
        await t.pump();
        await t.tap(x);
        await t.pump();
        await t.pump(const Duration(milliseconds: 600));
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../docs/screenshots/$name.png'),
      );
    }, skip: !_on);
  }
}
