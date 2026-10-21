import 'package:flutter/foundation.dart';

import '../../../core/models/book_genre.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/models/view_status.dart';

enum AddBookMode { search, manual }

/// Hata mesajı metin olarak değil anahtar olarak tutulur; view `context.l10n` ile çevirir.
enum AddBookError {
  emptyQuery,
  invalidIsbn,
  notFound,
  network,
  server,
  duplicate,
}

/// Manuel formdan (veya bir arama sonucundan) gelen kitap bilgisi.
@immutable
class BookDraft {
  final String title;
  final List<String> authors;
  final int pageCount;
  final String? isbn;
  final String? coverUrl;
  final BookGenre genre;
  final ReadingStatus status;
  final bool isOwned;

  const BookDraft({
    required this.title,
    this.authors = const [],
    required this.pageCount,
    this.isbn,
    this.coverUrl,
    this.genre = BookGenre.other,
    this.status = ReadingStatus.toRead,
    this.isOwned = true,
  });

  BookDraft copyWith({
    String? title,
    List<String>? authors,
    int? pageCount,
    String? isbn,
    String? coverUrl,
    BookGenre? genre,
    ReadingStatus? status,
    bool? isOwned,
  }) {
    return BookDraft(
      title: title ?? this.title,
      authors: authors ?? this.authors,
      pageCount: pageCount ?? this.pageCount,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  factory BookDraft.fromJson(Map<String, dynamic> json) {
    return BookDraft(
      title: json['title'] as String? ?? '',
      authors: (json['authors'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      pageCount: json['pageCount'] as int? ?? 0,
      isbn: json['isbn'] as String?,
      coverUrl: json['coverUrl'] as String?,
      genre: BookGenre.fromName(json['genre'] as String?),
      status: ReadingStatus.fromName(json['status'] as String?),
      isOwned: json['isOwned'] as bool? ?? true,
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
      'status': status.name,
      'isOwned': isOwned,
    };
  }
}

@immutable
class AddBookModel {
  final AddBookMode mode;
  final ViewStatus searchStatus;
  final List<BookSearchResult> results;
  final AddBookError? error;

  /// Manuel forma taşınan arama sonucu (form her seçimde yenilenir).
  final BookSearchResult? prefill;
  final int prefillVersion;
  final bool saved;

  const AddBookModel({
    this.mode = AddBookMode.search,
    this.searchStatus = ViewStatus.initial,
    this.results = const [],
    this.error,
    this.prefill,
    this.prefillVersion = 0,
    this.saved = false,
  });

  bool get isSearching => searchStatus == ViewStatus.loading;

  AddBookModel copyWith({
    AddBookMode? mode,
    ViewStatus? searchStatus,
    List<BookSearchResult>? results,
    AddBookError? error,
    bool clearError = false,
    BookSearchResult? prefill,
    bool clearPrefill = false,
    int? prefillVersion,
    bool? saved,
  }) {
    return AddBookModel(
      mode: mode ?? this.mode,
      searchStatus: searchStatus ?? this.searchStatus,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
      prefill: clearPrefill ? null : (prefill ?? this.prefill),
      prefillVersion: prefillVersion ?? this.prefillVersion,
      saved: saved ?? this.saved,
    );
  }

  factory AddBookModel.fromJson(Map<String, dynamic> json) {
    return AddBookModel(
      mode: AddBookMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => AddBookMode.search,
      ),
      results: (json['results'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BookSearchResult.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
