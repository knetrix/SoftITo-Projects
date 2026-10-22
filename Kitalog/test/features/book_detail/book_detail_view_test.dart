import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/constants/app_colors.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/widgets/genre_chip.dart';
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

  group('son sayfaya ulaşınca "Kitabı bitirdin mi?" onayı kendiliğinden açılır', () {
    Finder dialogConfirm() =>
        find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(FilledButton, 'Bitti olarak işaretle'));

    testWidgets('onaylanınca kitap biter ve pencere bir daha açılmaz', (tester) async {
      final deps = await _open(tester);
      await deps.libraryController.setCurrentPage(_cpId, 550);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('1 sayfa ileri'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing, reason: 'eski SnackBar önerisi yok');
      expect(find.text('Kitabı bitirdin mi?'), findsOneWidget);
      expect(
        find.text('Son sayfaya ulaştın. Kitap "Bitti" olarak işaretlenecek ve bu yılın okuma hedefine sayılacak.'),
        findsOneWidget,
      );

      await tester.tap(dialogConfirm());
      await tester.pumpAndSettle();
      final book = deps.libraryController.bookById(_cpId)!;
      expect(book.status.name, 'finished');
      expect(book.finishedAt, isNotNull);
      expect(find.byType(AlertDialog), findsNothing, reason: 'kuyrukta bekleyen ikinci öneri yok');
    });

    testWidgets('vazgeçilirse kitap okunuyor kalır; son sayfada tekrar "+" basmak pencereyi yinelemez', (tester) async {
      final deps = await _open(tester);
      await deps.libraryController.setCurrentPage(_cpId, 550);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('1 sayfa ileri'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Vazgeç')));
      await tester.pumpAndSettle();
      expect(deps.libraryController.bookById(_cpId)!.status.name, 'reading');

      await tester.tap(find.byTooltip('1 sayfa ileri'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      // Geri gidip yeniden son sayfaya gelince öneri yine açılır.
      await tester.tap(find.byTooltip('1 sayfa geri'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('1 sayfa ileri'));
      await tester.pumpAndSettle();
      expect(find.text('Kitabı bitirdin mi?'), findsOneWidget);
    });

    testWidgets('"Bitti olarak işaretle" düğmesi aynı pencereyi açar', (tester) async {
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Bitti olarak işaretle'));
      await tester.pumpAndSettle();
      expect(find.text('Kitabı bitirdin mi?'), findsOneWidget);
      expect(find.text('Kitap "Bitti" olarak işaretlenecek ve okuma ilerlemesi son sayfaya getirilecek.'), findsOneWidget);
      expect(dialogConfirm(), findsOneWidget);
    });
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

  testWidgets('kullanıcı kategorili kitapta etiket kategorinin adı ve rengiyle görünür', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final mizah = await deps.libraryController.addCustomGenre('Mizah', colorIndex: 2);
    await deps.libraryController.addBook(
      BookModel(id: 'k1', title: 'Gülmece', customGenreId: mizah.id, addedAt: DateTime(2026)),
    );
    await pumpScreen(tester, deps, const BookDetailView(bookId: 'k1'), size: const Size(800, 3000));
    final chip = find.ancestor(of: find.text('Mizah'), matching: find.byType(GenreChip));
    expect(chip, findsOneWidget);
    final box = tester.widget<DecoratedBox>(find.descendant(of: chip, matching: find.byType(DecoratedBox)).first);
    expect((box.decoration as BoxDecoration).color, AppColors.customGenrePalette[2]);
    expect(find.text('Diğer'), findsNothing);
  });

  testWidgets('ödünç bölümü yalnızca fiziksel kopyası olan kitapta görünür', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final digitalOnly = deps.libraryController.books.value.firstWhere((b) => !b.isOwned);
    await pumpScreen(tester, deps, BookDetailView(bookId: digitalOnly.id), size: const Size(800, 3000));
    expect(find.text('Ödünç Bilgisi'), findsNothing);
    expect(find.text('Ödünç Ver'), findsNothing);
    expect(find.text('Fiziksel kopyası yok'), findsOneWidget);
  });
}
