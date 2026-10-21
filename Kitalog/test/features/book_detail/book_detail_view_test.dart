import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/book_detail/views/book_detail_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';

Future<AppDependencies> _open(WidgetTester tester, {String id = _cpId}) async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  await pumpScreen(
    tester,
    deps,
    BookDetailView(bookId: id),
    size: const Size(800, 3000),
  );
  return deps;
}

void main() {
  testWidgets('künye, sayfa sayacı ve bölümler görünür', (tester) async {
    await _open(tester);
    expect(find.text('Crime and Punishment'), findsWidgets);
    expect(find.text('Fyodor Dostoyevsky'), findsOneWidget);
    expect(find.text('287 / 551 sayfa'), findsOneWidget);
    expect(find.text('%52'), findsOneWidget);
    expect(find.text('Alıntılar'), findsOneWidget);
    expect(find.text('Notlar'), findsOneWidget);
    expect(find.text('Ödünç Bilgisi'), findsOneWidget);
    expect(find.textContaining('Pain and suffering'), findsOneWidget);
  });

  testWidgets('+ butonu sayfayı artırır ve kalıcı yazar', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('1 sayfa ileri'));
    await tester.pumpAndSettle();
    expect(find.text('288 / 551 sayfa'), findsOneWidget);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, 288);

    await tester.tap(find.byTooltip('10 sayfa geri'));
    await tester.pumpAndSettle();
    expect(find.text('278 / 551 sayfa'), findsOneWidget);
  });

  testWidgets('son sayfaya ulaşınca "Bitti olarak işaretle" önerisi çıkar', (
    tester,
  ) async {
    final deps = await _open(tester);
    await deps.libraryController.setCurrentPage(_cpId, 550);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('1 sayfa ileri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Son sayfaya ulaştın. Kitabı bitirdin mi?'),
      findsOneWidget,
    );
    await tester.tap(
      find.widgetWithText(SnackBarAction, 'Bitti olarak işaretle'),
    );
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_cpId)!.status.name, 'finished');
  });

  group('okuma durumu yalnızca anlamlı sonraki adımı gösterir', () {
    // FilledButton.icon gibi kurucular alt sınıf ürettiği için türe göre değil, ataya göre aranır.
    Finder statusButton(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );

    testWidgets(
      'okunacak: başla veya bitti; okumaya başlayınca "Okunacak" seçeneği kalmaz',
      (tester) async {
        final deps = await _open(tester, id: 'seed-9781561385157');
        expect(find.text('Durum: Okunacak'), findsOneWidget);
        expect(statusButton('Okumaya Başla'), findsOneWidget);
        expect(statusButton('Bitti olarak işaretle'), findsOneWidget);
        await tester.tap(statusButton('Okumaya Başla'));
        await tester.pumpAndSettle();
        expect(
          deps.libraryController.bookById('seed-9781561385157')!.status.name,
          'reading',
        );
        expect(find.text('Durum: Okunuyor'), findsOneWidget);
        expect(statusButton('Okumaya Başla'), findsNothing);
        expect(find.text('Okunacak'), findsNothing);
      },
    );

    testWidgets(
      'bitti onay ister; vazgeçilirse değişmez, onaylanınca sayaç dolup kilitlenir',
      (tester) async {
        final deps = await _open(tester);
        await tester.tap(statusButton('Bitti olarak işaretle'));
        await tester.pumpAndSettle();
        expect(find.text('Kitabı bitirdin mi?'), findsOneWidget);
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
        expect(deps.libraryController.bookById(_cpId)!.status.name, 'reading');

        await tester.tap(statusButton('Bitti olarak işaretle'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Bitti olarak işaretle'),
          ),
        );
        await tester.pumpAndSettle();
        final book = deps.libraryController.bookById(_cpId)!;
        expect(book.status.name, 'finished');
        expect(book.currentPage, 551);
        expect(find.text('551 / 551 sayfa'), findsOneWidget);
        expect(
          find.byTooltip('1 sayfa ileri'),
          findsNothing,
          reason: 'biten kitabın sayacı değiştirilemez',
        );
        expect(statusButton('Bitti olarak işaretle'), findsNothing);
        expect(statusButton('Tekrar Oku'), findsOneWidget);
      },
    );

    testWidgets('tekrar oku onaylanınca ilerleme ve dijital konum sıfırlanır', (
      tester,
    ) async {
      final deps = await _open(tester);
      await deps.libraryController.setStatus(_cpId, ReadingStatus.finished);
      await tester.pumpAndSettle();
      await tester.tap(statusButton('Tekrar Oku'));
      await tester.pumpAndSettle();
      expect(find.text('Kitabı tekrar oku?'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Tekrar Oku'),
        ),
      );
      await tester.pumpAndSettle();
      final book = deps.libraryController.bookById(_cpId)!;
      expect(book.status, ReadingStatus.reading);
      expect(book.currentPage, 0);
      expect(book.finishedAt, isNull);
      expect(find.text('0 / 551 sayfa'), findsOneWidget);
      expect(find.byTooltip('1 sayfa ileri'), findsOneWidget);
      expect(statusButton('Bitti olarak işaretle'), findsOneWidget);
    });
  });

  testWidgets('alıntı ekleme diyaloğu doğrular ve alıntıyı listeler', (
    tester,
  ) async {
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
    expect(deps.libraryController.quotesOf(_cpId).length, 2);
  });

  testWidgets('favori işaretleme ve ödünç verme akışı', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Favorilere ekle').first);
    await tester.pumpAndSettle();
    expect(
      deps.libraryController.quotesOf(_cpId).where((q) => q.isFavorite),
      isNotEmpty,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Ödünç Ver'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Burak');
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Burak kişisine ödünç verildi'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'İade alındı'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_cpId)!.isLent, isFalse);
  });

  testWidgets('kitap silinince ekran kapanır', (tester) async {
    final deps = await _open(tester);
    await tester.tap(find.byTooltip('Kitabı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sil'));
    await tester.pumpAndSettle();
    expect(deps.libraryController.bookById(_cpId), isNull);
  });

  testWidgets('olmayan kitap için bulunamadı mesajı gösterilir', (
    tester,
  ) async {
    await _open(tester, id: 'yok');
    expect(find.text('Kitap bulunamadı.'), findsOneWidget);
  });
}
