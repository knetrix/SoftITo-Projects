// Golden testler (FLUTTER_PROMPT adım 9): her ana ekran 390×844, seed
// verisiyle (Kerem, u0), açık ve karanlık. Üretilen PNG'ler
// test/goldens/ altında; handoff/screens ile yan yana gözle karşılaştırılır.
//
// Golden'ları yeniden üretmek:  flutter test --update-goldens test/goldens_test.dart
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

void main() {
  final f = Fixture.load();
  const phone = Size(390, 844);

  setUpAll(() async {
    freezeClock();
    await loadFonts();
  });

  // (ad, ekran, sekme indeksi, kullanıcı)
  final cases = <(String, Widget Function(), int?, String)>[
    ('01_welcome', () => const WelcomeScreen(), null, 'u0'),
    ('02_signin', () => const SignInScreen(), null, 'u0'),
    ('03_signup', () => const SignUpScreen(), null, 'u0'),
    ('04_team', () => const TeamScreen(), 0, 'u0'),
    ('05_appointments', () => const AppointmentsScreen(), 1, 'u0'),
    (
      '06_detail_owner',
      () => const AppointmentDetailScreen(id: 'a1'),
      null,
      'u0',
    ),
    (
      '06_detail_guest',
      () => const AppointmentDetailScreen(id: 'e1'),
      null,
      'u0',
    ),
    (
      '06_detail_none',
      () => const AppointmentDetailScreen(id: 'yok'),
      null,
      'u0',
    ),
    ('07_profile', () => const ProfileScreen(), 2, 'u0'),
    ('08_social_friends', () => const SocialScreen(), 3, 'u0'),
    ('08_social_chats', () => const SocialScreen(tab: 'chats'), 3, 'u0'),
    ('09_chat', () => const ChatScreen(chatId: 'u0_u2'), null, 'u0'),
    ('10_invite_pending', () => const InviteDetailScreen(id: 'i1'), null, 'u0'),
    ('11_notifications', () => const NotificationsScreen(), null, 'u0'),
  ];

  for (final dark in [false, true]) {
    for (final (name, build, tab, uid) in cases) {
      final file = '${name}__${dark ? 'dark' : 'light'}';
      testWidgets(file, (t) async {
        setPhone(t, phone);
        await pumpScreen(
          t,
          build(),
          overrides: await overridesFor(f, uid: uid, dark: dark),
          dark: dark,
          tab: tab,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$file.png'),
        );
      });
    }
  }

  // Boş durumlar (yeni hesap).
  for (final (name, build, tab) in <(String, Widget Function(), int?)>[
    ('04_team_empty_account', () => const TeamScreen(), 0),
    ('05_appointments_empty', () => const AppointmentsScreen(), 1),
    ('08_social_chats_empty', () => const SocialScreen(tab: 'chats'), 3),
    ('11_notifications_empty', () => const NotificationsScreen(), null),
  ]) {
    testWidgets('${name}__light', (t) async {
      setPhone(t, phone);
      await pumpScreen(
        t,
        build(),
        overrides: await overridesFor(f, uid: 'u9', emptyAccount: true),
        tab: tab,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${name}__light.png'),
      );
    });
  }
}
