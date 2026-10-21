import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/auth/views/register_view.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';
import 'package:kitalog/features/home_shell/views/home_shell_view.dart';
import 'package:kitalog/features/library/views/library_view.dart';
import 'package:kitalog/features/reader/views/reader_view.dart';
import 'package:kitalog/features/reading_goal/views/reading_goal_view.dart';
import 'package:kitalog/features/reading_status/views/reading_status_view.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

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

final _screens = <String, Widget Function()>{
  'Kayıt': () => const RegisterView(),
  'Ana kabuk': () => const HomeShellView(
    pages: [LibraryView(), ReadingStatusView(), ReadingGoalView()],
  ),
  'Okuma durumu': () => const Scaffold(body: ReadingStatusView()),
  'Kitap detayı': () => const BookDetailView(bookId: 'seed-9781435131828'),
  'Ayarlar': () => const SettingsView(),
  'Okuyucu': () => const ReaderView(bookId: 'seed-9781435131828'),
};

void main() {
  for (final screen in _screens.entries) {
    testWidgets('${screen.key}: dokunma hedefleri ve etiketler erişilebilirlik kurallarına uyar', (tester) async {
      final handle = tester.ensureSemantics();
      final deps = await _deps();
      await pumpScreen(tester, deps, screen.value(), size: const Size(390, 1600));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  }

  testWidgets('Kayıt ve Ayarlar: metin kontrastı yeterlidir', (tester) async {
    final handle = tester.ensureSemantics();
    final deps = await _deps();
    await pumpScreen(tester, deps, const RegisterView(), size: const Size(390, 1000));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
