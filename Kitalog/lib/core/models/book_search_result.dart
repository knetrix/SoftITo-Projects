import 'package:flutter/foundation.dart';

import 'book_genre.dart';

/// Open Library arama sonucu (henüz kitaplığa eklenmemiş kayıt).
@immutable
class BookSearchResult {
  final String title;
  final List<String> authors;
  final int? pageCount;
  final String? isbn;
  final String? coverUrl;
  final BookGenre genre;

  const BookSearchResult({
    required this.title,
    this.authors = const [],
    this.pageCount,
    this.isbn,
    this.coverUrl,
    this.genre = BookGenre.other,
  });

  BookSearchResult copyWith({
    String? title,
    List<String>? authors,
    int? pageCount,
    String? isbn,
    String? coverUrl,
    BookGenre? genre,
  }) {
    return BookSearchResult(
      title: title ?? this.title,
      authors: authors ?? this.authors,
      pageCount: pageCount ?? this.pageCount,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
    );
  }

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      title: json['title'] as String? ?? '',
      authors: (json['authors'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      pageCount: json['pageCount'] as int?,
      isbn: json['isbn'] as String?,
      coverUrl: json['coverUrl'] as String?,
      genre: BookGenre.fromName(json['genre'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authors': authors,
      'pageCount': pageCount,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'genre': genre.name,
    };
  }
}
