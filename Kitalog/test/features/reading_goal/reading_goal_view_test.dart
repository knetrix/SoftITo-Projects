import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/reading_goal/views/reading_goal_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  testWidgets('hedef kartı, istatistikler, aylık grafik ve tür dağılımı görünür', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingGoalView()),
      size: const Size(800, 2400),
    );
    expect(find.text('12 / 24 kitap'), findsOneWidget);
    expect(find.text('Hedefe 12 kitap kaldı'), findsOneWidget);
    expect(find.text('Hedef: 24 kitap'), findsOneWidget);
    expect(find.text('Toplam okunan sayfa'), findsOneWidget);
    expect(find.text('Aylık biten kitaplar'), findsOneWidget);
    expect(find.text('Türlere göre dağılım'), findsOneWidget);
    expect(find.text('Roman'), findsWidgets);
  });

  testWidgets('hedef +/- butonları hedefi günceller', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingGoalView()),
      size: const Size(800, 2400),
    );
    await tester.tap(find.byTooltip('Hedefi artır'));
    await tester.pumpAndSettle();
    expect(find.text('Hedef: 25 kitap'), findsOneWidget);
    expect(find.text('12 / 25 kitap'), findsOneWidget);
    await tester.tap(find.byTooltip('Hedefi azalt'));
    await tester.tap(find.byTooltip('Hedefi azalt'));
    await tester.pumpAndSettle();
    expect(find.text('Hedef: 23 kitap'), findsOneWidget);
  });

  testWidgets('hedefe ulaşılınca tebrik mesajı gösterilir', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await deps.libraryController.setGoalTarget(DateTime.now().year, 12);
    await pumpScreen(
      tester,
      deps,
      const Scaffold(body: ReadingGoalView()),
      size: const Size(800, 2400),
    );
    expect(find.text('Yıllık hedefine ulaştın, tebrikler!'), findsOneWidget);
  });
}
