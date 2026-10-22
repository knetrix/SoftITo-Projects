import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:kitalog/core/constants/storage_keys.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/quote_model.dart';
import 'package:kitalog/core/models/reading_goal_model.dart';
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
    expect(await library.setCurrentPage(book.id, 99999), isFalse, reason: 'zaten son sayfada: öneri yinelenmez');
    expect(await library.setCurrentPage(book.id, updated.pageCount - 1), isFalse);
    expect(await library.setCurrentPage(book.id, updated.pageCount), isTrue, reason: 'yeniden son sayfaya gelindi');

    await library.setCurrentPage(book.id, -4);
    expect(library.bookById(book.id)!.currentPage, 0);
  });

  test('sayfa sayısı eşitlenirken ilerleme yüzdesi korunur; biten kitap son sayfada kalır', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final reading = library.books.value.firstWhere((b) => b.status == ReadingStatus.reading);
    await library.setCurrentPage(reading.id, reading.pageCount ~/ 2);
    await library.alignPageCount(reading.id, 100);
    var updated = library.bookById(reading.id)!;
    expect(updated.pageCount, 100);
    expect(updated.currentPage, closeTo(50, 1));

    final finished = library.books.value.firstWhere((b) => b.status == ReadingStatus.finished);
    await library.alignPageCount(finished.id, 42);
    updated = library.bookById(finished.id)!;
    expect(updated.pageCount, 42);
    expect(updated.currentPage, 42);

    await library.alignPageCount(finished.id, 0);
    expect(library.bookById(finished.id)!.pageCount, 42, reason: '0 yok sayılır');
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

  test('iade alınan ödünç geçmişe kaydedilir, kalıcıdır; kitap silinince geçmişi de silinir', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final seeded = library.loanHistory.value.length;
    expect(seeded, greaterThan(0), reason: 'örnek ödünç geçmişi');
    final book = library.lentBooks.first;
    await library.returnBook(book.id);
    expect(library.loanHistory.value.length, seeded + 1);
    final record = library.loanHistory.value.first;
    expect(record.bookId, book.id);
    expect(record.borrowerName, book.loan!.borrowerName);
    expect(record.lentAt, book.loan!.lentAt);

    // Ödünçte olmayan kitabı "iade almak" geçmişe kayıt düşmez.
    await library.returnBook(book.id);
    expect(library.loanHistory.value.length, seeded + 1);

    final reloaded = await deps.loanHistoryRepository.getAll();
    expect(reloaded.map((r) => r.id), library.loanHistory.value.map((r) => r.id));

    await library.deleteBook(book.id);
    expect(library.loanHistory.value.any((r) => r.bookId == book.id), isFalse);
    expect((await deps.loanHistoryRepository.getAll()).any((r) => r.bookId == book.id), isFalse);
  });

  test('fiziksel kopyası olmayan kitaptaki eski ödünç kaydı iade alınınca geçmişe yazılmaz', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final digitalOnly = library.books.value.firstWhere((b) => !b.isOwned);
    await library.updateBook(digitalOnly.copyWith(loan: LoanModel(borrowerName: 'Ali', lentAt: DateTime(2026))));
    final before = library.loanHistory.value.length;
    await library.returnBook(digitalOnly.id);
    expect(library.bookById(digitalOnly.id)!.loan, isNull);
    expect(library.loanHistory.value.length, before);
  });

  test('fiziksel kopyası olmayan kitap ödünç verilemez; eski ödünç kaydı yok sayılır', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final digitalOnly = library.books.value.firstWhere((b) => !b.isOwned);
    await library.lendBook(digitalOnly.id, LoanModel(borrowerName: 'Ali', lentAt: DateTime(2026)));
    expect(library.bookById(digitalOnly.id)!.loan, isNull);

    final legacy = digitalOnly.copyWith(loan: LoanModel(borrowerName: 'Ali', lentAt: DateTime(2026)));
    expect(legacy.isLent, isFalse);
    expect(legacy.copyWith(isOwned: true).isLent, isTrue);
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

  test('eski seed sürümünde yalnızca örnek kitaplar yenilenir, kullanıcı verisi korunur', () async {
    final date = DateTime(2026, 5, 1);
    final oldSeedBook = BookModel(id: 'seed-eski', title: 'Eski Örnek', addedAt: date);
    final userBook = BookModel(id: 'kullanici-1', title: 'Benim Kitabım', addedAt: date);
    final deps = await createTestDependencies({
      StorageKeys.seeded: true,
      StorageKeys.books: jsonEncode([oldSeedBook.toJson(), userBook.toJson()]),
      StorageKeys.quotes: jsonEncode([
        QuoteModel(id: 'q1', bookId: 'seed-eski', text: 'eski', createdAt: date).toJson(),
        QuoteModel(id: 'q2', bookId: 'kullanici-1', text: 'benim', createdAt: date).toJson(),
      ]),
      StorageKeys.goals: jsonEncode([
        ReadingGoalModel(year: DateTime.now().year, targetBookCount: 40).toJson(),
      ]),
    });
    final library = deps.libraryController;
    await library.load();

    final ids = library.books.value.map((b) => b.id).toList();
    expect(ids, contains('kullanici-1'));
    expect(ids, isNot(contains('seed-eski')));
    expect(library.books.value.where((b) => b.hasDigitalEdition).length, greaterThanOrEqualTo(30));
    expect(library.quotes.value.map((q) => q.text), contains('benim'));
    expect(library.quotes.value.map((q) => q.text), isNot(contains('eski')));
    expect(library.goalTargetFor(DateTime.now().year), 40, reason: 'kullanıcının hedefi korunur');

    // Sürüm yazıldığı için ikinci açılışta tekrar yenilenmez.
    await library.deleteBook(library.books.value.firstWhere((b) => SeedData.isSeedId(b.id)).id);
    final count = library.books.value.length;
    await library.load();
    expect(library.books.value.length, count);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(StorageKeys.seedVersion), SeedData.version);
  });

  test('sayfası geri alınmış biten kitap (eski sürüm) açılışta son sayfaya düzeltilir', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final book = library.books.value.firstWhere((b) => b.status == ReadingStatus.finished);
    await library.updateBook(book.copyWith(currentPage: 3));
    await library.load();
    expect(library.bookById(book.id)!.currentPage, book.pageCount);
    await library.load();
    expect(library.bookById(book.id)!.currentPage, book.pageCount);
  });
}
