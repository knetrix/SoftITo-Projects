import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/models/view_status.dart';
import '../../../core/repositories/book_search_repository.dart';
import '../../../core/utils/isbn_utils.dart';
import '../models/add_book_model.dart';

/// Open Library araması ve manuel kayıt. Hatalar try-catch ile controller'da
/// yakalanır ve `AddBookError` olarak state'e yazılır.
class AddBookController {
  AddBookController({
    required this._library,
    required this._search,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LibraryController _library;
  final BookSearchRepository _search;
  final DateTime Function() _clock;

  final ValueNotifier<AddBookModel> state = ValueNotifier<AddBookModel>(
    const AddBookModel(),
  );

  String _lastQuery = '';

  void setMode(AddBookMode mode) {
    state.value = state.value.copyWith(mode: mode);
  }

  /// ISBN (10/13 hane) ya da başlık/yazar metniyle arar.
  Future<void> search(String rawQuery) async {
    if (state.value.isSearching) return;
    final query = rawQuery.trim();
    _lastQuery = query;
    if (query.isEmpty) return _fail(AddBookError.emptyQuery);

    final isbn = IsbnUtils.normalize(query);
    if (isbn != null && !IsbnUtils.isValid(isbn)) {
      return _fail(AddBookError.invalidIsbn);
    }

    state.value = state.value.copyWith(
      searchStatus: ViewStatus.loading,
      results: const [],
      clearError: true,
    );
    try {
      final results = isbn != null
          ? await _search.searchByIsbn(isbn)
          : await _search.searchByText(query);
      if (results.isEmpty) return _fail(AddBookError.notFound);
      state.value = state.value.copyWith(
        searchStatus: ViewStatus.success,
        results: results,
      );
    } on BookSearchException catch (e) {
      _fail(
        e.failure == BookSearchFailure.network
            ? AddBookError.network
            : AddBookError.server,
      );
    }
  }

  Future<void> retry() => search(_lastQuery);

  /// Arama sonucunu manuel forma taşır; kullanıcı tür/durumu onaylayıp kaydeder.
  void selectResult(BookSearchResult result) {
    state.value = state.value.copyWith(
      mode: AddBookMode.manual,
      prefill: result,
      prefillVersion: state.value.prefillVersion + 1,
      clearError: true,
    );
  }

  /// Formdan hızlıca yeni kategori ekler; aynı adda kategori varsa o döner.
  Future<CustomGenreModel> createGenre(NewGenreInput input) {
    return _library.addCustomGenre(input.name, colorIndex: input.colorIndex);
  }

  Future<void> save(BookDraft draft) async {
    final isbn = draft.isbn;
    final duplicate =
        isbn != null &&
        isbn.isNotEmpty &&
        _library.books.value.any((b) => b.isbn == isbn);
    if (duplicate) {
      state.value = state.value.copyWith(error: AddBookError.duplicate);
      return;
    }
    final now = _clock();
    final pages = draft.pageCount < 0 ? 0 : draft.pageCount;
    final status = draft.status;
    final book = BookModel(
      id: _library.newId(),
      isbn: (isbn == null || isbn.isEmpty) ? null : isbn,
      title: draft.title.trim(),
      authors: draft.authors,
      coverUrl: (draft.coverUrl == null || draft.coverUrl!.isEmpty)
          ? null
          : draft.coverUrl,
      pageCount: pages,
      currentPage: status == ReadingStatus.finished ? pages : 0,
      genre: draft.customGenreId == null ? draft.genre : BookGenre.other,
      customGenreId: draft.customGenreId,
      status: status,
      isOwned: draft.isOwned,
      startedAt: status == ReadingStatus.toRead ? null : now,
      finishedAt: status == ReadingStatus.finished ? now : null,
      addedAt: now,
    );
    await _library.addBook(book);
    state.value = state.value.copyWith(saved: true, clearError: true);
  }

  void _fail(AddBookError error) {
    state.value = state.value.copyWith(
      searchStatus: ViewStatus.failure,
      error: error,
    );
  }

  void dispose() {
    state.dispose();
  }
}
