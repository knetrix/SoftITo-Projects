import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/genre_choice.dart';
import '../../../core/utils/search_utils.dart';
import '../models/library_shelf_model.dart';

/// Raf görünümünün arama ve (çoklu seçimli) filtre durumunu yönetir. Kitap verisini kopyalamaz;
/// paylaşılan `LibraryController.books` dinlenir ve süzülmüş liste türetilir.
class LibraryShelfController {
  LibraryShelfController({required this._library}) {
    _library.books.addListener(_recompute);
    _library.customGenres.addListener(_recompute);
    _recompute();
  }

  final LibraryController _library;
  final ValueNotifier<LibraryShelfModel> state =
      ValueNotifier<LibraryShelfModel>(const LibraryShelfModel());

  void setQuery(String query) {
    state.value = state.value.copyWith(query: query);
    _recompute();
  }

  /// Seçiliyse kaldırır, değilse ekler (her grupta çoklu seçim).
  void toggleFormat(BookFormatFilter format) {
    state.value = state.value.copyWith(formats: _toggle(state.value.formats, format));
    _recompute();
  }

  void toggleGenre(GenreChoice genre) {
    state.value = state.value.copyWith(genres: _toggle(state.value.genres, genre));
    _recompute();
  }

  /// Tüm filtreleri kaldırır (arama metni korunur).
  void clearFilters() {
    state.value = state.value.copyWith(formats: const {}, genres: const {});
    _recompute();
  }

  static Set<T> _toggle<T>(Set<T> current, T value) =>
      current.contains(value) ? ({...current}..remove(value)) : {...current, value};

  bool _matchesGenres(BookModel book, Set<GenreChoice> genres) {
    if (genres.isEmpty) return true;
    return genres.any(
      (g) => _library.matchesGenre(
        book,
        genre: g.customGenreId == null ? g.genre : null,
        customGenreId: g.customGenreId,
      ),
    );
  }

  void _recompute() {
    final current = state.value;
    final query = foldForSearch(current.query);
    final all = _library.books.value;
    final filtered = all.where((BookModel book) {
      if (current.formats.isNotEmpty && !current.formats.any((f) => f.matches(book))) return false;
      if (!_matchesGenres(book, current.genres)) return false;
      if (query.isEmpty) return true;
      return foldForSearch(book.title).contains(query) ||
          book.authors.any((a) => foldForSearch(a).contains(query));
    }).toList();
    state.value = current.copyWith(
      books: filtered,
      totalCount: all.length,
      customGenres: _library.customGenres.value,
    );
  }

  void dispose() {
    _library.books.removeListener(_recompute);
    _library.customGenres.removeListener(_recompute);
    state.dispose();
  }
}
