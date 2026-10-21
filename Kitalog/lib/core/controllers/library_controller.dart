import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/book_model.dart';
import '../models/loan_model.dart';
import '../models/note_model.dart';
import '../models/quote_model.dart';
import '../models/reading_goal_model.dart';
import '../models/reading_status.dart';
import '../repositories/book_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/quote_repository.dart';

/// Kitap, alıntı, not ve hedef verisinin tek doğruluk kaynağı (AppScope).
/// Ekranlar bu veriyi kopyalamaz; notifier'ları dinler.
class LibraryController {
  LibraryController({
    required BookRepository bookRepository,
    required QuoteRepository quoteRepository,
    required NoteRepository noteRepository,
    required GoalRepository goalRepository,
    DateTime Function()? clock,
  }) : _books = bookRepository,
       _quotes = quoteRepository,
       _notes = noteRepository,
       _goals = goalRepository,
       _clock = clock ?? DateTime.now;

  static const int defaultGoalTarget = 12;

  final BookRepository _books;
  final QuoteRepository _quotes;
  final NoteRepository _notes;
  final GoalRepository _goals;
  final DateTime Function() _clock;
  int _idCounter = 0;

  final ValueNotifier<List<BookModel>> books = ValueNotifier(const []);
  final ValueNotifier<List<QuoteModel>> quotes = ValueNotifier(const []);
  final ValueNotifier<List<NoteModel>> notes = ValueNotifier(const []);
  final ValueNotifier<List<ReadingGoalModel>> goals = ValueNotifier(const []);

  String newId() => '${_clock().microsecondsSinceEpoch}-${_idCounter++}';

  Future<void> load() async {
    if (!await _books.isSeeded()) {
      final seed = SeedData.build(_clock());
      await _books.saveAll(seed.books);
      await _quotes.saveAll(seed.quotes);
      await _notes.saveAll(seed.notes);
      await _goals.saveAll([seed.goal]);
      await _books.markSeeded();
      await _books.saveSeedVersion(SeedData.version);
    } else if (await _books.seedVersion() < SeedData.version) {
      await _upgradeSeed();
    }
    books.value = await _normalizeFinished(await _books.getAll());
    quotes.value = await _quotes.getAll();
    notes.value = await _notes.getAll();
    goals.value = await _goals.getAll();
  }

  /// Biten kitabın sayacı son sayfadadır. Eski sürümde biten kitabın sayfası
  /// geri alınabiliyordu; böyle kayıtlar açılışta düzeltilip kaydedilir.
  Future<List<BookModel>> _normalizeFinished(List<BookModel> all) async {
    final fixed = [
      for (final b in all)
        b.status == ReadingStatus.finished && b.currentPage != b.pageCount
            ? b.copyWith(currentPage: b.pageCount)
            : b,
    ];
    if (fixed.indexed.any((e) => !identical(e.$2, all[e.$1]))) {
      await _books.saveAll(fixed);
    }
    return fixed;
  }

  /// Yalnızca örnek kitaplar (ve onlara ait alıntı/notlar) yenilenir;
  /// kullanıcının eklediği kitaplar ve kendi hedefi korunur.
  Future<void> _upgradeSeed() async {
    final seed = SeedData.build(_clock());
    bool ownBook(String bookId) => !SeedData.isSeedId(bookId);
    final userBooks = (await _books.getAll()).where((b) => ownBook(b.id));
    final userQuotes = (await _quotes.getAll()).where((q) => ownBook(q.bookId));
    final userNotes = (await _notes.getAll()).where((n) => ownBook(n.bookId));
    final goals = await _goals.getAll();
    await _books.saveAll([...seed.books, ...userBooks]);
    await _quotes.saveAll([...seed.quotes, ...userQuotes]);
    await _notes.saveAll([...seed.notes, ...userNotes]);
    if (!goals.any((g) => g.year == seed.goal.year)) {
      await _goals.saveAll([...goals, seed.goal]);
    }
    await _books.saveSeedVersion(SeedData.version);
  }

  BookModel? bookById(String id) {
    for (final book in books.value) {
      if (book.id == id) return book;
    }
    return null;
  }

  List<QuoteModel> quotesOf(String bookId) =>
      quotes.value.where((q) => q.bookId == bookId).toList();

  List<NoteModel> notesOf(String bookId) =>
      notes.value.where((n) => n.bookId == bookId).toList();

  int goalTargetFor(int year) {
    for (final goal in goals.value) {
      if (goal.year == year) return goal.targetBookCount;
    }
    return defaultGoalTarget;
  }

  // ---- Kitaplar ----------------------------------------------------------

  Future<void> addBook(BookModel book) async {
    await _saveBooks([book, ...books.value]);
  }

  Future<void> updateBook(BookModel book) async {
    await _saveBooks([for (final b in books.value) b.id == book.id ? book : b]);
  }

  Future<void> deleteBook(String id) async {
    await _saveBooks(books.value.where((b) => b.id != id).toList());
    await _saveQuotes(quotes.value.where((q) => q.bookId != id).toList());
    await _saveNotes(notes.value.where((n) => n.bookId != id).toList());
  }

  /// Sayfayı 0 - pageCount aralığında günceller. Okunacak bir kitapta sayfa
  /// artarsa durum "okunuyor" olur. Son sayfaya ulaşıldıysa `true` döner
  /// (arayüz "Bitti olarak işaretle" önerisini gösterir). Biten kitabın sayacı
  /// değişmez (ör. okuyucuda geri sayfalara bakmak); baştan okumak için
  /// [restartReading] kullanılır.
  Future<bool> setCurrentPage(String bookId, int page) async {
    final book = bookById(bookId);
    if (book == null || book.status == ReadingStatus.finished) return false;
    var next = book.copyWith(currentPage: page);
    if (next.currentPage > 0 && book.status == ReadingStatus.toRead) {
      next = next.copyWith(
        status: ReadingStatus.reading,
        startedAt: book.startedAt ?? _clock(),
      );
    }
    await updateBook(next);
    return next.pageCount > 0 &&
        next.currentPage >= next.pageCount &&
        next.status != ReadingStatus.finished;
  }

  Future<void> changePage(String bookId, int delta) async {
    final book = bookById(bookId);
    if (book == null) return;
    await setCurrentPage(bookId, book.currentPage + delta);
  }

  Future<void> setStatus(String bookId, ReadingStatus status) async {
    final book = bookById(bookId);
    if (book == null || book.status == status) return;
    final now = _clock();
    var next = book.copyWith(status: status);
    switch (status) {
      case ReadingStatus.toRead:
        next = next.copyWith(clearStartedAt: true, clearFinishedAt: true);
      case ReadingStatus.reading:
        next = next.copyWith(
          startedAt: book.startedAt ?? now,
          clearFinishedAt: true,
        );
      case ReadingStatus.finished:
        next = next.copyWith(
          startedAt: book.startedAt ?? now,
          finishedAt: now,
          currentPage: book.pageCount,
        );
    }
    await updateBook(next);
  }

  /// Biten kitabı yeniden okumaya başlatır: ilerleme sıfırlanır, durum
  /// "okunuyor" olur, başlangıç bugüne alınır ve bitiş tarihi silinir.
  Future<void> restartReading(String bookId) async {
    final book = bookById(bookId);
    if (book == null) return;
    await updateBook(
      book.copyWith(
        status: ReadingStatus.reading,
        currentPage: 0,
        startedAt: _clock(),
        clearFinishedAt: true,
      ),
    );
  }

  Future<void> setRating(String bookId, int? rating) async {
    final book = bookById(bookId);
    if (book == null) return;
    final value = rating?.clamp(1, 5);
    await updateBook(
      value == null
          ? book.copyWith(clearRating: true)
          : book.copyWith(rating: value),
    );
  }

  Future<void> setReview(String bookId, String review) async {
    final book = bookById(bookId);
    if (book == null) return;
    final text = review.trim();
    await updateBook(
      text.isEmpty
          ? book.copyWith(clearReview: true)
          : book.copyWith(review: text),
    );
  }

  Future<void> lendBook(String bookId, LoanModel loan) async {
    final book = bookById(bookId);
    if (book == null) return;
    await updateBook(book.copyWith(loan: loan));
  }

  Future<void> returnBook(String bookId) async {
    final book = bookById(bookId);
    if (book == null) return;
    await updateBook(book.copyWith(clearLoan: true));
  }

  // ---- Alıntılar ---------------------------------------------------------

  Future<void> addQuote(String bookId, String text, int? page) async {
    final quote = QuoteModel(
      id: newId(),
      bookId: bookId,
      text: text.trim(),
      page: page,
      createdAt: _clock(),
    );
    await _saveQuotes([quote, ...quotes.value]);
  }

  Future<void> toggleFavoriteQuote(String quoteId) async {
    await _saveQuotes([
      for (final q in quotes.value)
        q.id == quoteId ? q.copyWith(isFavorite: !q.isFavorite) : q,
    ]);
  }

  Future<void> deleteQuote(String quoteId) async {
    await _saveQuotes(quotes.value.where((q) => q.id != quoteId).toList());
  }

  // ---- Notlar ------------------------------------------------------------

  Future<void> addNote(String bookId, String content) async {
    final now = _clock();
    final note = NoteModel(
      id: newId(),
      bookId: bookId,
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _saveNotes([note, ...notes.value]);
  }

  Future<void> deleteNote(String noteId) async {
    await _saveNotes(notes.value.where((n) => n.id != noteId).toList());
  }

  // ---- Hedef -------------------------------------------------------------

  Future<void> setGoalTarget(int year, int target) async {
    final value = target < 1 ? 1 : target;
    final exists = goals.value.any((g) => g.year == year);
    final next = exists
        ? [
            for (final g in goals.value)
              g.year == year ? g.copyWith(targetBookCount: value) : g,
          ]
        : [
            ...goals.value,
            ReadingGoalModel(year: year, targetBookCount: value),
          ];
    await _goals.saveAll(next);
    goals.value = next;
  }

  // ---- Yardımcılar -------------------------------------------------------

  Future<void> _saveBooks(List<BookModel> next) async {
    await _books.saveAll(next);
    books.value = next;
  }

  Future<void> _saveQuotes(List<QuoteModel> next) async {
    await _quotes.saveAll(next);
    quotes.value = next;
  }

  Future<void> _saveNotes(List<NoteModel> next) async {
    await _notes.saveAll(next);
    notes.value = next;
  }

  void dispose() {
    books.dispose();
    quotes.dispose();
    notes.dispose();
    goals.dispose();
  }
}
