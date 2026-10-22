import 'package:flutter/foundation.dart';

/// Bir kitapta bir günde ilerlenen sayfa sayısı (günlük okuma kaydı). Okuma
/// hatırlatmasının "bugün okudun mu", okuma serisi ve yarım kalan kitap
/// kuralları bu kayıtlardan hesaplanır.
@immutable
class ReadingLogEntryModel {
  final String bookId;

  /// Takvim günü (saat yok sayılır, gece yarısına yuvarlanır).
  final DateTime day;
  final int pages;

  ReadingLogEntryModel({required this.bookId, required DateTime day, required this.pages}) : day = dayOf(day);

  static DateTime dayOf(DateTime moment) => DateTime(moment.year, moment.month, moment.day);

  ReadingLogEntryModel copyWith({String? bookId, DateTime? day, int? pages}) {
    return ReadingLogEntryModel(bookId: bookId ?? this.bookId, day: day ?? this.day, pages: pages ?? this.pages);
  }

  factory ReadingLogEntryModel.fromJson(Map<String, dynamic> json) {
    return ReadingLogEntryModel(
      bookId: json['bookId'] as String? ?? '',
      day: DateTime.tryParse(json['day'] as String? ?? '') ?? DateTime(1970),
      pages: json['pages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return {'bookId': bookId, 'day': '${day.year}-$m-$d', 'pages': pages};
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingLogEntryModel && other.bookId == bookId && other.day == day && other.pages == pages;

  @override
  int get hashCode => Object.hash(bookId, day, pages);
}
