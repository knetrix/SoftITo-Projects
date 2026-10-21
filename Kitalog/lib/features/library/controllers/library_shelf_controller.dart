import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/utils/search_utils.dart';
import '../models/library_shelf_model.dart';

/// Raf görünümünün arama ve filtre durumunu yönetir. Kitap verisini kopyalamaz;
/// paylaşılan `LibraryController.books` dinlenir ve süzülmüş liste türetilir.
class LibraryShelfController {
  LibraryShelfController({required this._library}) {
    _library.books.addListener(_recompute);
    _recompute();
  }

  final LibraryController _library;
  final ValueNotifier<LibraryShelfModel> state =
      ValueNotifier<LibraryShelfModel>(const LibraryShelfModel());

  void setQuery(String query) {
    state.value = state.value.copyWith(query: query);
    _recompute();
  }

  void setGenre(BookGenre? genre) {
    state.value = genre == null
        ? state.value.copyWith(clearGenre: true)
        : state.value.copyWith(genre: genre);
    _recompute();
  }

  void setStatus(ReadingStatus? status) {
    state.value = status == null
        ? state.value.copyWith(clearStatus: true)
        : state.value.copyWith(status: status);
    _recompute();
  }

  void _recompute() {
    final current = state.value;
    final query = foldForSearch(current.query);
    final all = _library.books.value;
    final filtered = all.where((BookModel book) {
      if (current.genre != null && book.genre != current.genre) return false;
      if (current.status != null && book.status != current.status) return false;
      if (query.isEmpty) return true;
      return foldForSearch(book.title).contains(query) ||
          book.authors.any((a) => foldForSearch(a).contains(query));
    }).toList();
    state.value = current.copyWith(books: filtered, totalCount: all.length);
  }

  void dispose() {
    _library.books.removeListener(_recompute);
    state.dispose();
  }
}
