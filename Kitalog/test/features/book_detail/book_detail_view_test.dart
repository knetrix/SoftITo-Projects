import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _duneId = 'seed-9780340839935';

Future<AppDependencies> _open(WidgetTester tester, {String id = _duneId}) async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  await pumpScreen(tester, deps, BookDetailView(bookId: id), size: const Size(800, 3000));
  return deps;
}

void main() {
  testWidgets('künye, sayfa sayacı ve bölümler görünür', (tester) async {
    await _open(tester);
    expect(find.text('Dune'), findsWidgets);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('316 / 608 sayfa'), findsOneWidget);
    expect(find.text('%52'), findsOneWidget);
    expect(find.text('Alıntılar'), findsOneWidget);
    expect(find.text('Notlar'), findsOneWidget);
    expect(find.text('Ödünç Bilgisi'), findsOneWidget);
    expect(find.textContaining('I must not fear'), findsOneWidget);
  });

  testWidgets('+ butonu sayfayı artırır ve kalıcı yazar', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('1 sayfa ileri'));
    await tester.pumpAndSettle();
    expect(find.text('317 / 608 sayfa'), findsOneWidget);
    expect(deps.libraryController.bookById(_duneId)!.currentPage, 317);

    await tester.tap(find.byTooltip('10 sayfa geri'));
    await tester.pumpAndSettle();
    expect(find.text('307 / 608 sayfa'), findsOneWidget);
  });

  testWidgets('son sayfaya ulaşınca "Bitti olarak işaretle" önerisi çıkar', (tester) async {
    final deps = await _open(tester);
    await deps.libraryController.setCurrentPage(_duneId, 607);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('1 sayfa ileri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Son sayfaya ulaştın. Kitabı bitirdin mi?'), findsOneWidget);
    await tester.tap(find.text('Bitti olarak işaretle'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_duneId)!.status.name, 'finished');
  });

  testWidgets('alıntı ekleme diyaloğu doğrular ve alıntıyı listeler', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Alıntı Ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pump();
    expect(find.text('Bu alan boş bırakılamaz.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Test alıntısı');
    await tester.enterText(find.byType(TextFormField).at(1), '77');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Test alıntısı'), findsOneWidget);
    expect(find.text('s. 77'), findsOneWidget);
    expect(deps.libraryController.quotesOf(_duneId).length, 3);
  });

  testWidgets('favori işaretleme ve ödünç verme akışı', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Favorilere ekle').first);
    await tester.pumpAndSettle();
    expect(deps.libraryController.quotesOf(_duneId).where((q) => q.isFavorite), isNotEmpty);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Ödünç Ver'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Burak');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Burak kişisine ödünç verildi'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'İade alındı'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_duneId)!.isLent, isFalse);
  });

  testWidgets('kitap silinince ekran kapanır', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Kitabı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sil'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_duneId), isNull);
  });

  testWidgets('olmayan kitap için bulunamadı mesajı gösterilir', (tester) async {
    await _open(tester, id: 'yok');
    expect(find.text('Kitap bulunamadı.'), findsOneWidget);
  });
}
