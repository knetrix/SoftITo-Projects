import 'package:flutter/foundation.dart';

import '../../../core/models/book_genre.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/models/genre_choice.dart';

/// Kitabın biçimine göre filtre: fiziksel kopya, dijital sürüm. Ödünçteki
/// kitaplar "Ödünç Takibi" sekmesinde izlenir; burada filtresi yoktur.
enum BookFormatFilter {
  physical,
  digital;

  bool matches(BookModel book) => switch (this) {
    BookFormatFilter.physical => book.isOwned,
    BookFormatFilter.digital => book.hasDigitalEdition,
  };

  static BookFormatFilter? fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Raf görünümünün arama ve filtre durumu. Her gruptan birden fazla değer
/// seçilebilir: grup içinde "veya", gruplar arasında "ve" uygulanır. Boş
/// grup o grubu süzmez. Okuma durumuna göre ayırma "Okuma Durumu", ödünçteki
/// kitapların takibi "Ödünç Takibi" sekmesindedir.
@immutable
class LibraryShelfModel {
  final String query;
  final Set<BookFormatFilter> formats;

  /// Seçili yerleşik türler ve kullanıcı kategorileri.
  final Set<GenreChoice> genres;
  final List<BookModel> books;
  final int totalCount;

  /// Filtre panelinde gösterilecek kullanıcı kategorileri.
  final List<CustomGenreModel> customGenres;

  const LibraryShelfModel({
    this.query = '',
    this.formats = const {},
    this.genres = const {},
    this.books = const [],
    this.totalCount = 0,
    this.customGenres = const [],
  });

  /// Filtre düğmesinin rozetinde gösterilen seçili filtre sayısı (arama hariç).
  int get activeFilterCount => formats.length + genres.length;

  bool get isFiltered => query.isNotEmpty || activeFilterCount > 0;
  bool get isLibraryEmpty => totalCount == 0;

  LibraryShelfModel copyWith({
    String? query,
    Set<BookFormatFilter>? formats,
    Set<GenreChoice>? genres,
    List<BookModel>? books,
    int? totalCount,
    List<CustomGenreModel>? customGenres,
  }) {
    return LibraryShelfModel(
      query: query ?? this.query,
      formats: formats ?? this.formats,
      genres: genres ?? this.genres,
      books: books ?? this.books,
      totalCount: totalCount ?? this.totalCount,
      customGenres: customGenres ?? this.customGenres,
    );
  }

  factory LibraryShelfModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> list(String key) => json[key] as List<dynamic>? ?? const [];
    return LibraryShelfModel(
      query: json['query'] as String? ?? '',
      formats: {for (final f in list('formats')) ?BookFormatFilter.fromName(f as String?)},
      genres: {
        for (final g in list('genres'))
          if (g is Map<String, dynamic>)
            (genre: BookGenre.fromName(g['genre'] as String?), customGenreId: g['customGenreId'] as String?),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'formats': [for (final f in formats) f.name],
      'genres': [
        for (final g in genres) {'genre': g.genre.name, 'customGenreId': g.customGenreId},
      ],
    };
  }
}
