import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/library/widgets/book_badges_widget.dart';

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
    expect(find.byTooltip('Filtreler'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Roman'), findsNothing, reason: 'filtreler panelde');
    expect(find.byType(BookBadgesWidget), findsWidgets);
    expect(find.text('Ödünçte'), findsWidgets);
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

  Finder sheetChip(String label) =>
      find.descendant(of: find.byType(BottomSheet), matching: find.widgetWithText(FilterChip, label));

  // Kısa ekranda panel kaydırılır; çip alttaki "kitabı göster" düğmesinin arkasında kalmasın.
  Future<void> tapSheetChip(WidgetTester tester, String label) async {
    await tester.ensureVisible(sheetChip(label));
    await tester.pumpAndSettle();
    await tester.tap(sheetChip(label));
    await tester.pumpAndSettle();
  }

  testWidgets('filtre panelinde birden fazla filtre seçilir; seçimler çip olarak görünür ve kaldırılır', (tester) async {
    await _openLibrary(tester);
    await tester.tap(find.byTooltip('Filtreler'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma durumu'), findsNothing, reason: 'okuma durumu "Okuma Durumu" sekmesinde');
    expect(sheetChip('Okunuyor'), findsNothing);
    expect(find.text('Biçim'), findsOneWidget);
    expect(sheetChip('Fiziksel'), findsOneWidget);
    expect(sheetChip('Dijital'), findsOneWidget);
    expect(sheetChip('Ödünçte'), findsNothing, reason: 'ödünçteki kitaplar "Ödünç Takibi" sekmesinde');

    await tapSheetChip(tester, 'Bilim');
    await tapSheetChip(tester, 'Felsefe');
    await tapSheetChip(tester, 'Fiziksel');
    expect(find.textContaining('kitabı göster'), findsOneWidget);
    await tester.tap(find.textContaining('kitabı göster'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    // Fiziksel kopyası olan bilim / felsefe kitapları; The Republic yalnızca dijital.
    expect(find.text('Meditations'), findsWidgets);
    expect(find.text('The Republic'), findsNothing);
    expect(find.text('Pride and Prejudice'), findsNothing);
    expect(find.byTooltip('Filtreler (3 seçili)'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Bilim'), findsOneWidget);

    await tester.tap(find.descendant(of: find.widgetWithText(InputChip, 'Fiziksel'), matching: find.byTooltip('Filtreyi kaldır')));
    await tester.pumpAndSettle();
    expect(find.text('The Republic'), findsWidgets);
    expect(find.byTooltip('Filtreler (2 seçili)'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Temizle'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    expect(find.byTooltip('Filtreler'), findsOneWidget);
  });
}
