import 'package:flutter/foundation.dart';

import '../../../core/models/book_genre.dart';
import '../../../core/models/custom_genre_model.dart';

/// Yıllık hedef panelinin UI state'i. Biten kitap sayısı ve dağılımlar saklanmaz;
/// `BookModel.finishedAt` yılından hesaplanır.
@immutable
class ReadingGoalState {
  final int year;
  final int targetBookCount;
  final int finishedCount;
  final int totalPagesRead;

  /// Ocak..Aralık için biten kitap sayıları (12 eleman).
  final List<int> monthlyFinished;
  /// Yerleşik türlere göre biten kitaplar (kullanıcı kategorili kitaplar hariç).
  final Map<BookGenre, int> genreCounts;

  /// Kullanıcı kategorilerine (`CustomGenreModel.id`) göre biten kitaplar.
  final Map<String, int> customGenreCounts;

  /// [customGenreCounts] anahtarlarının adı ve rengi için kategoriler (saklanmaz).
  final List<CustomGenreModel> customGenres;

  const ReadingGoalState({
    required this.year,
    this.targetBookCount = 12,
    this.finishedCount = 0,
    this.totalPagesRead = 0,
    this.monthlyFinished = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.genreCounts = const {},
    this.customGenreCounts = const {},
    this.customGenres = const [],
  });

  double get progress => targetBookCount > 0
      ? (finishedCount / targetBookCount).clamp(0.0, 1.0)
      : 0.0;

  int get remaining =>
      (targetBookCount - finishedCount).clamp(0, targetBookCount);

  bool get isCompleted => targetBookCount > 0 && finishedCount >= targetBookCount;

  int get maxMonthly =>
      monthlyFinished.fold(0, (max, v) => v > max ? v : max);

  ReadingGoalState copyWith({
    int? year,
    int? targetBookCount,
    int? finishedCount,
    int? totalPagesRead,
    List<int>? monthlyFinished,
    Map<BookGenre, int>? genreCounts,
    Map<String, int>? customGenreCounts,
    List<CustomGenreModel>? customGenres,
  }) {
    return ReadingGoalState(
      year: year ?? this.year,
      targetBookCount: targetBookCount ?? this.targetBookCount,
      finishedCount: finishedCount ?? this.finishedCount,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      monthlyFinished: monthlyFinished ?? this.monthlyFinished,
      genreCounts: genreCounts ?? this.genreCounts,
      customGenreCounts: customGenreCounts ?? this.customGenreCounts,
      customGenres: customGenres ?? this.customGenres,
    );
  }

  factory ReadingGoalState.fromJson(Map<String, dynamic> json) {
    final genres = <BookGenre, int>{};
    (json['genreCounts'] as Map<String, dynamic>? ?? const {}).forEach((k, v) {
      genres[BookGenre.fromName(k)] = v as int;
    });
    return ReadingGoalState(
      year: json['year'] as int? ?? DateTime.now().year,
      targetBookCount: json['targetBookCount'] as int? ?? 12,
      finishedCount: json['finishedCount'] as int? ?? 0,
      totalPagesRead: json['totalPagesRead'] as int? ?? 0,
      monthlyFinished: (json['monthlyFinished'] as List<dynamic>? ??
              List<int>.filled(12, 0))
          .map((e) => e as int)
          .toList(),
      genreCounts: genres,
      customGenreCounts: {
        for (final e in (json['customGenreCounts'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: e.value as int,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'targetBookCount': targetBookCount,
      'finishedCount': finishedCount,
      'totalPagesRead': totalPagesRead,
      'monthlyFinished': monthlyFinished,
      'genreCounts': {for (final e in genreCounts.entries) e.key.name: e.value},
      'customGenreCounts': customGenreCounts,
    };
  }
}
