import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/book_detail/controllers/book_detail_controller.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';

Future<BookDetailController> _create() async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  return BookDetailController(library: deps.libraryController, bookId: _cpId);
}

void main() {
  test('başlangıç state\'i kitap, alıntı ve notları içerir', () async {
    final controller = await _create();
    final state = controller.state.value;
    expect(state.book?.title, 'Crime and Punishment');
    expect(state.book?.digitalEdition?.sourceId, '2554');
    expect(state.quotes.length, 1);
    expect(state.notes.length, 1);
    expect(state.finishSuggested, isFalse);
    expect(state.isMissing, isFalse);
    controller.dispose();
  });

  test('changePage sayfayı 0 ile pageCount arasında sınırlar', () async {
    final controller = await _create();
    final start = controller.state.value.book!.currentPage;
    await controller.changePage(1);
    expect(controller.state.value.book!.currentPage, start + 1);
    await controller.changePage(-100000);
    expect(controller.state.value.book!.currentPage, 0);
    await controller.changePage(100000);
    expect(controller.state.value.book!.currentPage, 551);
    controller.dispose();
  });

  test(
    'son sayfaya ulaşınca bitirme önerisi tetiklenir ve tüketilir',
    () async {
      final controller = await _create();
      await controller.setPage(551);
      expect(controller.state.value.finishSuggested, isTrue);
      controller.consumeFinishSuggestion();
      expect(controller.state.value.finishSuggested, isFalse);
      await controller.setStatus(ReadingStatus.finished);
      expect(controller.state.value.book!.status, ReadingStatus.finished);
      expect(controller.state.value.book!.finishedAt, isNotNull);
      controller.dispose();
    },
  );

  test(
    'tekrar oku: sayaç, tarihler ve dijital kopyadaki konum sıfırlanır',
    () async {
      final deps = await createTestDependencies(
        const {},
        FakeDigitalSources(gutenbergTexts: {'2554': 'Suç ve Ceza metni'})
            .client,
      );
      await deps.libraryController.load();
      final book = deps.libraryController.bookById(_cpId)!;
      await deps.digitalBookRepository.download(book);
      await deps.digitalBookRepository.savePosition(_cpId, 10);
      final controller = BookDetailController(
        library: deps.libraryController,
        bookId: _cpId,
        digital: deps.digitalBookRepository,
      );
      await controller.setStatus(ReadingStatus.finished);
      await controller.readAgain();
      final next = controller.state.value.book!;
      expect(next.status, ReadingStatus.reading);
      expect(next.currentPage, 0);
      expect(next.finishedAt, isNull);
      expect(next.startedAt, isNotNull);
      expect((await deps.digitalBookRepository.copyOf(_cpId))!.lastOffset, 0);
      // Biten kitabın sayacı (ör. okuyucudan) değişmez.
      await controller.setStatus(ReadingStatus.finished);
      await controller.setPage(100);
      expect(controller.state.value.book!.currentPage, 551);
      controller.dispose();
    },
  );

  test('puan, inceleme, alıntı ve not işlemleri state\'e yansır', () async {
    final controller = await _create();
    await controller.setRating(4);
    await controller.saveReview('  Harika  ');
    expect(controller.state.value.book!.rating, 4);
    expect(controller.state.value.book!.review, 'Harika');

    await controller.addQuote('Yeni alıntı', 42);
    expect(controller.state.value.quotes.length, 2);
    final quote = controller.state.value.quotes.first;
    expect(quote.page, 42);
    await controller.toggleFavoriteQuote(quote.id);
    expect(
      controller.state.value.quotes
          .firstWhere((q) => q.id == quote.id)
          .isFavorite,
      isTrue,
    );
    await controller.deleteQuote(quote.id);
    expect(controller.state.value.quotes.length, 1);

    await controller.addNote('Not');
    expect(controller.state.value.notes.length, 2);
    await controller.deleteNote(controller.state.value.notes.first.id);
    expect(controller.state.value.notes.length, 1);
    controller.dispose();
  });

  test('ödünç verme ve iade alma', () async {
    final controller = await _create();
    expect(controller.state.value.book!.isLent, isFalse);
    await controller.lend(
      LoanModel(borrowerName: 'Selin', lentAt: DateTime.now()),
    );
    expect(controller.state.value.book!.loan?.borrowerName, 'Selin');
    await controller.returnBook();
    expect(controller.state.value.book!.isLent, isFalse);
    controller.dispose();
  });

  test('kitap silinince state eksik (isMissing) olur', () async {
    final controller = await _create();
    await controller.deleteBook();
    expect(controller.state.value.isMissing, isTrue);
    expect(controller.state.value.quotes, isEmpty);
    controller.dispose();
  });
}
