import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/storage_keys.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('ilk yüklemede seed bir kez yazılır, ikinci yüklemede tekrarlanmaz', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final count = library.books.value.length;
    expect(count, greaterThanOrEqualTo(30));

    await library.deleteBook(library.books.value.first.id);
    await library.load();
    expect(library.books.value.length, count - 1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(StorageKeys.seeded), isTrue);
  });

  test('kayıtlar SharedPreferences\'a JSON olarak yazılır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(StorageKeys.books), isNotNull);
    expect(prefs.getString(StorageKeys.quotes), isNotNull);
    expect(prefs.getString(StorageKeys.goals), isNotNull);
  });

  test('sayfa sayacı sınırlanır, okunacak kitap okunuyor olur', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final book = library.books.value.firstWhere(
      (b) => b.status == ReadingStatus.toRead,
    );
    await library.changePage(book.id, 5);
    var updated = library.bookById(book.id)!;
    expect(updated.currentPage, 5);
    expect(updated.status, ReadingStatus.reading);
    expect(updated.startedAt, isNotNull);

    final reachedEnd = await library.setCurrentPage(book.id, 99999);
    updated = library.bookById(book.id)!;
    expect(updated.currentPage, updated.pageCount);
    expect(reachedEnd, isTrue);

    await library.setCurrentPage(book.id, -4);
    expect(library.bookById(book.id)!.currentPage, 0);
  });

  test('bitti durumu sayfayı tamamlar ve bitiş tarihini yazar', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final book = library.books.value.firstWhere(
      (b) => b.status == ReadingStatus.reading,
    );
    await library.setStatus(book.id, ReadingStatus.finished);
    final updated = library.bookById(book.id)!;
    expect(updated.currentPage, updated.pageCount);
    expect(updated.finishedAt, isNotNull);

    await library.setStatus(book.id, ReadingStatus.toRead);
    expect(library.bookById(book.id)!.finishedAt, isNull);
  });

  test('ödünç verme, iade, puan ve inceleme', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final id = library.books.value.firstWhere((b) => !b.isLent).id;
    await library.lendBook(id, LoanModel(borrowerName: 'Deniz', lentAt: DateTime.now()));
    expect(library.bookById(id)!.isLent, isTrue);
    await library.returnBook(id);
    expect(library.bookById(id)!.isLent, isFalse);

    await library.setRating(id, 9);
    expect(library.bookById(id)!.rating, 5);
    await library.setReview(id, '   ');
    expect(library.bookById(id)!.review, isNull);
  });

  test('alıntı ve not ekleme/silme, kitap silinince bağlı kayıtlar silinir', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final id = library.books.value.first.id;
    final quoteCount = library.quotesOf(id).length;
    await library.addQuote(id, '  yeni alıntı ', 12);
    expect(library.quotesOf(id).length, quoteCount + 1);
    final quote = library.quotesOf(id).first;
    expect(quote.text, 'yeni alıntı');
    await library.toggleFavoriteQuote(quote.id);
    expect(library.quotesOf(id).first.isFavorite, isTrue);
    await library.addNote(id, 'not');
    expect(library.notesOf(id).first.content, 'not');

    await library.deleteBook(id);
    expect(library.quotesOf(id), isEmpty);
    expect(library.notesOf(id), isEmpty);
  });

  test('hedef güncellenir ve kalıcı yazılır', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    expect(library.goalTargetFor(DateTime.now().year), 24);
    await library.setGoalTarget(DateTime.now().year, 30);
    expect(library.goalTargetFor(DateTime.now().year), 30);
    await library.setGoalTarget(DateTime.now().year, 0);
    expect(library.goalTargetFor(DateTime.now().year), 1);
    expect(library.goalTargetFor(1999), 12);
  });
}
