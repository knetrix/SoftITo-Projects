import 'package:flutter/foundation.dart';

import '../../../core/models/book_genre.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';

@immutable
class LibraryShelfModel {
  final String query;
  final BookGenre? genre;
  final ReadingStatus? status;
  final List<BookModel> books;
  final int totalCount;

  const LibraryShelfModel({
    this.query = '',
    this.genre,
    this.status,
    this.books = const [],
    this.totalCount = 0,
  });

  bool get isFiltered => query.isNotEmpty || genre != null || status != null;
  bool get isLibraryEmpty => totalCount == 0;

  LibraryShelfModel copyWith({
    String? query,
    BookGenre? genre,
    bool clearGenre = false,
    ReadingStatus? status,
    bool clearStatus = false,
    List<BookModel>? books,
    int? totalCount,
  }) {
    return LibraryShelfModel(
      query: query ?? this.query,
      genre: clearGenre ? null : (genre ?? this.genre),
      status: clearStatus ? null : (status ?? this.status),
      books: books ?? this.books,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  factory LibraryShelfModel.fromJson(Map<String, dynamic> json) {
    final genreName = json['genre'] as String?;
    final statusName = json['status'] as String?;
    return LibraryShelfModel(
      query: json['query'] as String? ?? '',
      genre: genreName == null ? null : BookGenre.fromName(genreName),
      status: statusName == null ? null : ReadingStatus.fromName(statusName),
    );
  }

  Map<String, dynamic> toJson() {
    return {'query': query, 'genre': genre?.name, 'status': status?.name};
  }
}
