import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/loan_model.dart';
import '../../../core/models/reading_status.dart';
import '../models/book_detail_actions.dart';
import '../models/book_detail_model.dart';

/// Tek bir kitabın detayını yönetir. Veri paylaşılan `LibraryController`'dan
/// okunur; her değişiklik önce oraya yazılır, sonra state güncellenir.
class BookDetailController {
  BookDetailController({required this._library, required this.bookId}) {
    _library.books.addListener(_sync);
    _library.quotes.addListener(_sync);
    _library.notes.addListener(_sync);
    _sync();
  }

  final LibraryController _library;
  final String bookId;

  final ValueNotifier<BookDetailModel> state = ValueNotifier<BookDetailModel>(
    const BookDetailModel(),
  );

  late final BookDetailActions actions = BookDetailActions(
    changePage: changePage,
    setPage: setPage,
    setStatus: setStatus,
    setRating: setRating,
    saveReview: saveReview,
    addQuote: addQuote,
    toggleFavoriteQuote: toggleFavoriteQuote,
    deleteQuote: deleteQuote,
    addNote: addNote,
    deleteNote: deleteNote,
    lend: lend,
    returnBook: returnBook,
  );

  void _sync() {
    state.value = state.value.copyWith(
      book: _library.bookById(bookId),
      clearBook: _library.bookById(bookId) == null,
      quotes: _library.quotesOf(bookId),
      notes: _library.notesOf(bookId),
    );
  }

  Future<void> changePage(int delta) async {
    final book = state.value.book;
    if (book == null) return;
    await setPage(book.currentPage + delta);
  }

  Future<void> setPage(int page) async {
    final reachedEnd = await _library.setCurrentPage(bookId, page);
    if (reachedEnd) {
      state.value = state.value.copyWith(finishSuggested: true);
    }
  }

  /// Öneri gösterildikten sonra tekrar tetiklenmemesi için çağrılır.
  void consumeFinishSuggestion() {
    state.value = state.value.copyWith(finishSuggested: false);
  }

  Future<void> setStatus(ReadingStatus status) =>
      _library.setStatus(bookId, status);

  Future<void> setRating(int rating) => _library.setRating(bookId, rating);

  Future<void> saveReview(String review) => _library.setReview(bookId, review);

  Future<void> addQuote(String text, int? page) {
    return _library.addQuote(bookId, text, page);
  }

  Future<void> toggleFavoriteQuote(String quoteId) =>
      _library.toggleFavoriteQuote(quoteId);

  Future<void> deleteQuote(String quoteId) => _library.deleteQuote(quoteId);

  Future<void> addNote(String content) => _library.addNote(bookId, content);

  Future<void> deleteNote(String noteId) => _library.deleteNote(noteId);

  Future<void> lend(LoanModel loan) => _library.lendBook(bookId, loan);

  Future<void> returnBook() => _library.returnBook(bookId);

  Future<void> deleteBook() => _library.deleteBook(bookId);

  void dispose() {
    _library.books.removeListener(_sync);
    _library.quotes.removeListener(_sync);
    _library.notes.removeListener(_sync);
    state.dispose();
  }
}
