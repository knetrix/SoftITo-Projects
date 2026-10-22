import 'package:flutter/foundation.dart';

import 'book_genre.dart';
import 'digital_edition_model.dart';
import 'loan_model.dart';
import 'reading_status.dart';

@immutable
class BookModel {
  final String id;
  final String? isbn;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final int pageCount;
  final int currentPage;
  final BookGenre genre;

  /// Kullanıcının eklediği kategori (`CustomGenreModel.id`); doluysa etiket ve
  /// renk buradan gelir, [genre] ise `other` olarak kalır.
  final String? customGenreId;
  final ReadingStatus status;
  final int? rating;
  final String? review;
  final bool isOwned;
  final LoanModel? loan;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime addedAt;

  /// Telifi bitmiş dijital metin varsa nerede olduğu (yoksa `null`).
  final DigitalEditionModel? digitalEdition;

  const BookModel({
    required this.id,
    this.isbn,
    required this.title,
    this.authors = const [],
    this.coverUrl,
    this.pageCount = 0,
    this.currentPage = 0,
    this.genre = BookGenre.other,
    this.customGenreId,
    this.status = ReadingStatus.toRead,
    this.rating,
    this.review,
    this.isOwned = true,
    this.loan,
    this.startedAt,
    this.finishedAt,
    required this.addedAt,
    this.digitalEdition,
  });

  /// 0.0 - 1.0 arası ilerleme. Saklanmaz, hesaplanır.
  double get progress =>
      pageCount > 0 ? (currentPage / pageCount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).round();

  /// Ödünç yalnızca fiziksel kopya için anlamlıdır: fiziksel kopyası olmayan
  /// kitapta (eski bir kayıtta kalmış olsa bile) ödünç bilgisi yok sayılır.
  bool get isLent => isOwned && loan != null;

  bool get hasDigitalEdition => digitalEdition != null;

  String get authorsLabel => authors.join(', ');

  /// Sayfa sayısı sınırları içinde (0 - pageCount) yeni bir sayfa değeri üretir.
  BookModel copyWith({
    String? id,
    String? isbn,
    String? title,
    List<String>? authors,
    String? coverUrl,
    int? pageCount,
    int? currentPage,
    BookGenre? genre,
    String? customGenreId,
    bool clearCustomGenreId = false,
    ReadingStatus? status,
    int? rating,
    bool clearRating = false,
    String? review,
    bool clearReview = false,
    bool? isOwned,
    LoanModel? loan,
    bool clearLoan = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    DateTime? addedAt,
    DigitalEditionModel? digitalEdition,
    bool clearDigitalEdition = false,
  }) {
    final nextPageCount = pageCount ?? this.pageCount;
    final nextCurrent = (currentPage ?? this.currentPage).clamp(
      0,
      nextPageCount < 0 ? 0 : nextPageCount,
    );
    return BookModel(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      coverUrl: coverUrl ?? this.coverUrl,
      pageCount: nextPageCount,
      currentPage: nextCurrent,
      genre: genre ?? this.genre,
      customGenreId: clearCustomGenreId ? null : (customGenreId ?? this.customGenreId),
      status: status ?? this.status,
      rating: clearRating ? null : (rating ?? this.rating),
      review: clearReview ? null : (review ?? this.review),
      isOwned: isOwned ?? this.isOwned,
      loan: clearLoan ? null : (loan ?? this.loan),
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      addedAt: addedAt ?? this.addedAt,
      digitalEdition: clearDigitalEdition
          ? null
          : (digitalEdition ?? this.digitalEdition),
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final loanJson = json['loan'];
    return BookModel(
      id: json['id'] as String? ?? '',
      isbn: json['isbn'] as String?,
      title: json['title'] as String? ?? '',
      authors: (json['authors'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      coverUrl: json['coverUrl'] as String?,
      pageCount: json['pageCount'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      genre: BookGenre.fromName(json['genre'] as String?),
      customGenreId: json['customGenreId'] as String?,
      status: ReadingStatus.fromName(json['status'] as String?),
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      isOwned: json['isOwned'] as bool? ?? true,
      loan: loanJson is Map<String, dynamic> ? LoanModel.fromJson(loanJson) : null,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? ''),
      addedAt:
          DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      digitalEdition: DigitalEditionModel.tryFromJson(json['digitalEdition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isbn': isbn,
      'title': title,
      'authors': authors,
      'coverUrl': coverUrl,
      'pageCount': pageCount,
      'currentPage': currentPage,
      'genre': genre.name,
      'customGenreId': customGenreId,
      'status': status.name,
      'rating': rating,
      'review': review,
      'isOwned': isOwned,
      'loan': loan?.toJson(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
      'digitalEdition': digitalEdition?.toJson(),
    };
  }
}
