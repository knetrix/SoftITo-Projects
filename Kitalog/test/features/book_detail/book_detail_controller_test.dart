import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/book_detail/controllers/book_detail_controller.dart';

import '../../helpers/test_dependencies.dart';

const _duneId = 'seed-9780340839935';

Future<BookDetailController> _create() async {
  final deps = await createTestDependencies();
  await deps.libraryController.load();
  return BookDetailController(
    library: deps.libraryController,
    bookId: _duneId,
  );
}

void main() {
  test('başlangıç state\'i kitap, alıntı ve notları içerir', () async {
    final controller = await _create();
    final state = controller.state.value;
    expect(state.book?.title, 'Dune');
    expect(state.quotes.length, 2);
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
    expect(controller.state.value.book!.currentPage, 608);
    controller.dispose();
  });

  test('son sayfaya ulaşınca bitirme önerisi tetiklenir ve tüketilir', () async {
    final controller = await _create();
    await controller.setPage(608);
    expect(controller.state.value.finishSuggested, isTrue);
    controller.consumeFinishSuggestion();
    expect(controller.state.value.finishSuggested, isFalse);
    await controller.setStatus(ReadingStatus.finished);
    expect(controller.state.value.book!.status, ReadingStatus.finished);
    expect(controller.state.value.book!.finishedAt, isNotNull);
    controller.dispose();
  });

  test('puan, inceleme, alıntı ve not işlemleri state\'e yansır', () async {
    final controller = await _create();
    await controller.setRating(4);
    await controller.saveReview('  Harika  ');
    expect(controller.state.value.book!.rating, 4);
    expect(controller.state.value.book!.review, 'Harika');

    await controller.addQuote('Yeni alıntı', 42);
    expect(controller.state.value.quotes.length, 3);
    final quote = controller.state.value.quotes.first;
    expect(quote.page, 42);
    await controller.toggleFavoriteQuote(quote.id);
    expect(controller.state.value.quotes.firstWhere((q) => q.id == quote.id).isFavorite, isTrue);
    await controller.deleteQuote(quote.id);
    expect(controller.state.value.quotes.length, 2);

    await controller.addNote('Not');
    expect(controller.state.value.notes.length, 2);
    await controller.deleteNote(controller.state.value.notes.first.id);
    expect(controller.state.value.notes.length, 1);
    controller.dispose();
  });

  test('ödünç verme ve iade alma', () async {
    final controller = await _create();
    expect(controller.state.value.book!.isLent, isFalse);
    await controller.lend(LoanModel(borrowerName: 'Selin', lentAt: DateTime.now()));
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
