import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/library/widgets/loan_badge_widget.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

Future<void> _openLibrary(WidgetTester tester) async {
  final deps = await createTestDependencies();
  await deps.authController.register(
    email: 'a@b.com',
    phone: '05321234567',
    password: 'Abcdefg1',
  );
  await pumpKitalog(tester, deps);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  testWidgets('raf görünümü kitapları, filtre çiplerini ve FAB\'ı gösterir', (tester) async {
    await _openLibrary(tester);
    expect(find.text('Kitaplığım'), findsWidgets);
    expect(find.text('Pride and Prejudice'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Roman'), findsOneWidget);
    expect(find.byType(LoanBadgeWidget), findsWidgets);
  });

  testWidgets('arama kutusu listeyi süzer, sonuç yoksa boş durum görünür', (tester) async {
    await _openLibrary(tester);
    await tester.enterText(find.byType(TextField), 'kurk mantolu');
    await tester.pumpAndSettle();
    expect(find.text('Kürk Mantolu Madonna'), findsWidgets);
    expect(find.text('Cosmos'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Sonuç bulunamadı'), findsOneWidget);
  });

  testWidgets('tür çipi seçilince yalnızca o türdeki kitaplar kalır', (tester) async {
    await _openLibrary(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Roman'));
    await tester.pumpAndSettle();
    expect(find.text('Kürk Mantolu Madonna'), findsWidgets);
    expect(find.text('Cosmos'), findsNothing);
  });
}
