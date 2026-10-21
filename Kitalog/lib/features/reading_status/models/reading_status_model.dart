import 'package:flutter/foundation.dart';

import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';

@immutable
class ReadingStatusModel {
  final List<BookModel> reading;
  final List<BookModel> toRead;
  final List<BookModel> finished;

  /// Hızlı sayacla son sayfaya ulaşılan kitap (bitirme önerisi için).
  final String? finishSuggestedBookId;

  const ReadingStatusModel({
    this.reading = const [],
    this.toRead = const [],
    this.finished = const [],
    this.finishSuggestedBookId,
  });

  List<BookModel> booksFor(ReadingStatus status) => switch (status) {
    ReadingStatus.reading => reading,
    ReadingStatus.toRead => toRead,
    ReadingStatus.finished => finished,
  };

  ReadingStatusModel copyWith({
    List<BookModel>? reading,
    List<BookModel>? toRead,
    List<BookModel>? finished,
    String? finishSuggestedBookId,
    bool clearFinishSuggestion = false,
  }) {
    return ReadingStatusModel(
      reading: reading ?? this.reading,
      toRead: toRead ?? this.toRead,
      finished: finished ?? this.finished,
      finishSuggestedBookId: clearFinishSuggestion
          ? null
          : (finishSuggestedBookId ?? this.finishSuggestedBookId),
    );
  }

  factory ReadingStatusModel.fromJson(Map<String, dynamic> json) {
    List<BookModel> parse(String key) => (json[key] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .toList();
    return ReadingStatusModel(
      reading: parse('reading'),
      toRead: parse('toRead'),
      finished: parse('finished'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reading': reading.map((e) => e.toJson()).toList(),
      'toRead': toRead.map((e) => e.toJson()).toList(),
      'finished': finished.map((e) => e.toJson()).toList(),
    };
  }
}
