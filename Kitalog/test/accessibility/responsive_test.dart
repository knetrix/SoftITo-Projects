import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/add_book/views/add_book_view.dart';
import 'package:kitalog/features/auth/views/login_view.dart';
import 'package:kitalog/features/auth/views/register_view.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';
import 'package:kitalog/features/home_shell/views/home_shell_view.dart';
import 'package:kitalog/features/library/views/library_view.dart';
import 'package:kitalog/features/reading_goal/views/reading_goal_view.dart';
import 'package:kitalog/features/reading_status/views/reading_status_view.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

const _sizes = <String, Size>{
  'küçük telefon 320x568': Size(320, 568),
  'telefon 390x844': Size(390, 844),
  'tablet 820x1180': Size(820, 1180),
  'masaüstü 1280x800': Size(1280, 800),
};

const _textScales = [1.0, 1.6];

typedef _ScreenBuilder = Widget Function();

final _screens = <String, _ScreenBuilder>{
  'Kayıt': () => const RegisterView(),
  'Giriş': () => const LoginView(),
  'Ana kabuk (Kitaplığım)': () => const HomeShellView(
    pages: [LibraryView(), ReadingStatusView(), ReadingGoalView()],
  ),
  'Okuma durumu': () => const Scaffold(body: ReadingStatusView()),
  'Hedef paneli': () => const Scaffold(body: ReadingGoalView()),
  'Kitap detayı': () => const BookDetailView(bookId: 'seed-9780340839935'),
  'Kitap ekle': () => const AddBookView(),
  'Ayarlar': () => const SettingsView(),
};

Future<AppDependencies> _deps() async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  await deps.authController.register(
    email: 'a@b.com',
    phone: '05321234567',
    password: 'Abcdefg1',
  );
  return deps;
}

void main() {
  for (final screen in _screens.entries) {
    for (final size in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets(
          '${screen.key} – ${size.key}, yazı ölçeği $scale taşma/istisna üretmez',
          (tester) async {
            final deps = await _deps();
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            await pumpScreen(tester, deps, screen.value(), size: size.value);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('İngilizce dilde ana kabuk taşma üretmez (küçük ekran)', (tester) async {
    final deps = await _deps();
    await pumpScreen(
      tester,
      deps,
      const HomeShellView(pages: [LibraryView(), ReadingStatusView(), ReadingGoalView()]),
      locale: const Locale('en'),
      size: const Size(320, 568),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('My Library'), findsWidgets);
  });
}
