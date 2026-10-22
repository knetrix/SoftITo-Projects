import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/loans/views/loans_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

Future<AppDependencies> _open(WidgetTester tester, {Locale locale = const Locale('tr')}) async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  await pumpScreen(tester, deps, const LoansView(), locale: locale, size: const Size(800, 1600));
  return deps;
}

Finder _inDialog(Finder finder) => find.descendant(of: find.byType(AlertDialog), matching: finder);

void main() {
  testWidgets('özet, sekmeler ve en acil ödünç başta görünür', (tester) async {
    await _open(tester);
    expect(find.text('Ödünçte (4)'), findsOneWidget);
    expect(find.text('Geçmiş (4)'), findsOneWidget);
    expect(find.text('Gecikmiş'), findsOneWidget);
    expect(find.text('İadesi yaklaşan'), findsOneWidget);
    // Alice 15 gün önce iade edilmeliydi; liste başında ve gecikme etiketiyle.
    expect(find.text('15 gün gecikti'), findsOneWidget);
    expect(find.text('Murat kişisine ödünç verildi'), findsOneWidget);
    // Kapak yüklenemediğinde yer tutucu da başlığı yazar; kartın başlığı sonuncusudur.
    final alice = tester.getTopLeft(find.text("Alice's Adventures in Wonderland").last).dy;
    final pride = tester.getTopLeft(find.text('Pride and Prejudice').last).dy;
    expect(alice, lessThan(pride));
    expect(find.textContaining('45 gündür ödünçte'), findsOneWidget);
  });

  testWidgets('iade alındı onaylanınca kitap geçmişe taşınır; vazgeçilirse değişmez', (tester) async {
    await _open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'İade alındı').first);
    await tester.pumpAndSettle();
    expect(find.text('İade alındı mı?'), findsOneWidget);
    await tester.tap(_inDialog(find.text('Vazgeç')));
    await tester.pumpAndSettle();
    expect(find.text('Ödünçte (4)'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'İade alındı').first);
    await tester.pumpAndSettle();
    await tester.tap(_inDialog(find.widgetWithText(FilledButton, 'İade alındı')));
    await tester.pumpAndSettle();
    expect(find.text('Ödünçte (3)'), findsOneWidget);
    expect(find.text('Geçmiş (5)'), findsOneWidget);
    expect(find.text('15 gün gecikti'), findsNothing);

    await tester.tap(find.text('Geçmiş (5)'));
    await tester.pumpAndSettle();
    expect(find.text("Alice's Adventures in Wonderland"), findsWidgets);
    expect(find.text('Geç iade edildi'), findsNWidgets(2), reason: 'Alice ve örnek veride geç iade edilen Frankenstein');
  });

  testWidgets('FAB ile kitap seçilip ödünç verilir; panelde yalnızca ödünç verilebilecek kitaplar var', (tester) async {
    await _open(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Ödünç Ver'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('Ödünç verilecek kitabı seç')), findsOneWidget);

    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)), 'alice');
    await tester.pumpAndSettle();
    expect(find.descendant(of: sheet, matching: find.text('Sonuç bulunamadı')), findsOneWidget, reason: 'Alice zaten ödünçte');
    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)), 'the republic');
    await tester.pumpAndSettle();
    expect(find.descendant(of: sheet, matching: find.text('Sonuç bulunamadı')), findsOneWidget, reason: 'fiziksel kopyası yok');

    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)), 'DRACULA');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: sheet, matching: find.widgetWithText(ListTile, 'Dracula')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.enterText(_inDialog(find.byType(TextFormField)), 'Deniz');
    await tester.tap(_inDialog(find.text('Kaydet')));
    await tester.pumpAndSettle();
    expect(find.text('Ödünçte (5)'), findsOneWidget);
    expect(find.text('Deniz kişisine ödünç verildi'), findsOneWidget);
    expect(find.text('İade tarihi yok'), findsOneWidget);
  });

  testWidgets('Düzenle mevcut bilgiyle açılır ve kişiyi günceller', (tester) async {
    await _open(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Düzenle').first);
    await tester.pumpAndSettle();
    expect(find.text('Ödünç Bilgisini Düzenle'), findsOneWidget);
    expect(_inDialog(find.text('Murat')), findsOneWidget);
    await tester.enterText(_inDialog(find.byType(TextFormField)), 'Mert');
    await tester.tap(_inDialog(find.text('Kaydet')));
    await tester.pumpAndSettle();
    expect(find.text('Mert kişisine ödünç verildi'), findsOneWidget);
    expect(find.text('Murat kişisine ödünç verildi'), findsNothing);
    expect(find.text('Ödünçte (4)'), findsOneWidget);
    expect(find.text('Geçmiş (4)'), findsOneWidget, reason: 'düzenleme geçmişe kayıt düşmez');
  });

  testWidgets('hepsi iade alınınca boş durum mesajı görünür', (tester) async {
    final deps = await _open(tester);
    for (final book in deps.libraryController.lentBooks) {
      await deps.libraryController.returnBook(book.id);
    }
    await tester.pumpAndSettle();
    expect(find.text('Ödünçte kitap yok'), findsOneWidget);
    expect(find.text('Geçmiş (8)'), findsOneWidget);
  });

  testWidgets('İngilizce metinler', (tester) async {
    await _open(tester, locale: const Locale('en'));
    expect(find.text('On loan (4)'), findsOneWidget);
    expect(find.text('History (4)'), findsOneWidget);
    expect(find.text('15 days overdue'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Lend book'), findsOneWidget);
  });
}
