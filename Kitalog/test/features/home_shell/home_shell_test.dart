import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/home_shell/controllers/home_shell_controller.dart';
import 'package:kitalog/features/home_shell/views/home_shell_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  test('selectTab geçerli aralıkta çalışır, dışındakini yok sayar', () {
    final controller = HomeShellController(tabCount: 3);
    expect(controller.state.value.selectedIndex, 0);
    controller.selectTab(2);
    expect(controller.state.value.selectedIndex, 2);
    controller.selectTab(5);
    controller.selectTab(-1);
    expect(controller.state.value.selectedIndex, 2);
    controller.dispose();
  });

  test('başlangıç sekmesi sınırlanır', () {
    final controller = HomeShellController(tabCount: 3, initialIndex: 9);
    expect(controller.state.value.selectedIndex, 2);
    controller.dispose();
  });

  testWidgets('NavigationBar sekme değiştirir, sağ üstte ayarlar simgesi vardır', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const HomeShellView(
        pages: [Text('birinci'), Text('ikinci'), Text('üçüncü')],
      ),
    );
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await tester.tap(find.text('Okuma Durumu'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma Durumu'), findsWidgets);
    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.index, 1);
    await tester.tap(find.text('Hedef'));
    await tester.pumpAndSettle();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);
  });
}
