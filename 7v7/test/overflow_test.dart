// §10 madde 10: küçük (360×640) ve büyük (430×932) telefonlarda, TR ve EN,
// açık ve karanlık, hiçbir ekran taşmaz. Taşma (RenderFlex overflow vb.)
// Flutter hatası olarak testi düşürür.
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

void main() {
  final f = Fixture.load();

  setUpAll(() async {
    freezeClock();
    await loadFonts();
  });

  final screens = <(String, Widget Function(), int?)>[
    ('welcome', () => const WelcomeScreen(), null),
    ('signin', () => const SignInScreen(), null),
    ('signup', () => const SignUpScreen(), null),
    ('team', () => const TeamScreen(), 0),
    ('appointments', () => const AppointmentsScreen(), 1),
    ('detail owner', () => const AppointmentDetailScreen(id: 'a1'), null),
    ('detail guest', () => const AppointmentDetailScreen(id: 'e1'), null),
    ('profile', () => const ProfileScreen(), 2),
    ('social friends', () => const SocialScreen(), 3),
    ('social chats', () => const SocialScreen(tab: 'chats'), 3),
    ('chat', () => const ChatScreen(chatId: 'u0_u2'), null),
    ('invite pending', () => const InviteDetailScreen(id: 'i1'), null),
    (
      'invite accepted (sender view)',
      () => const InviteDetailScreen(id: 'o1'),
      null,
    ),
    ('notifications', () => const NotificationsScreen(), null),
  ];

  const sizes = {
    '360x640': (Size(360, 640), EdgeInsets.only(top: 24)),
    '430x932': (Size(430, 932), EdgeInsets.only(top: 59, bottom: 34)),
  };

  for (final MapEntry(key: sizeName, value: (size, safe)) in sizes.entries) {
    for (final locale in ['tr', 'en']) {
      for (final dark in [false, true]) {
        for (final (name, build, tab) in screens) {
          testWidgets('$name $sizeName $locale ${dark ? 'dark' : 'light'}', (
            t,
          ) async {
            setPhone(t, size, safe: safe);
            await pumpScreen(
              t,
              build(),
              overrides: await overridesFor(f, dark: dark, locale: locale),
              dark: dark,
              locale: locale,
              tab: tab,
            );
            expect(t.takeException(), isNull);
          });
        }
      }
    }
  }

  sheetTests();
}

/// Alt paneller 360×640'ta (TR, EN): diziliş, oyuncu, saat, maç daveti.
void sheetTests() {
  final f = Fixture.load();
  for (final locale in ['tr', 'en']) {
    Future<void> open(
      WidgetTester t,
      Widget screen,
      int tab,
      Finder target,
    ) async {
      setPhone(t, const Size(360, 640), safe: const EdgeInsets.only(top: 24));
      await pumpScreen(
        t,
        screen,
        overrides: await overridesFor(f, locale: locale),
        locale: locale,
        tab: tab,
      );
      await t.ensureVisible(target.first);
      await t.pump();
      await t.tap(target.first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(t.takeException(), isNull);
    }

    testWidgets('formation sheet 360x640 $locale', (t) async {
      await open(
        t,
        const TeamScreen(),
        0,
        find.byIcon(PhosphorIconsFill.strategy),
      );
      expect(find.text('2-1-3'), findsOneWidget);
    });
    testWidgets('player sheet 360x640 $locale', (t) async {
      await open(t, const TeamScreen(), 0, find.text('Emre'));
    });
    testWidgets('time sheet 360x640 $locale', (t) async {
      await open(
        t,
        const TeamScreen(),
        0,
        find.byIcon(PhosphorIconsFill.clock),
      );
      expect(find.text('22:00–23:00'), findsOneWidget);
    });
    testWidgets('delete account sheet 360x640 $locale', (t) async {
      await open(
        t,
        const ProfileScreen(),
        2,
        find.text(locale == 'tr' ? 'Hesabı sil' : 'Delete account'),
      );
      expect(
        find.text(locale == 'tr' ? 'Hesabı kalıcı olarak sil' : 'Delete permanently'),
        findsOneWidget,
      );
    });
    testWidgets('invite sheet 360x640 $locale', (t) async {
      await open(
        t,
        const SocialScreen(),
        3,
        find.text(locale == 'tr' ? 'Maça davet et' : 'Invite to match'),
      );
      expect(find.byIcon(PhosphorIconsFill.paperPlaneRight), findsOneWidget);
    });
  }
}
