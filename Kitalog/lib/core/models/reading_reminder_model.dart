import 'package:flutter/foundation.dart';

/// Okuma hatırlatmasının türü.
enum ReadingReminderKind {
  /// Günlük okuma daveti.
  daily,

  /// Günlük davetin seri hâli: dün ve öncesinde art arda okundu, seri bozulmasın.
  streak,

  /// "Okunuyor" durumundaki kitapta uzun süredir ilerleme yok.
  stalled;

  static ReadingReminderKind fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return ReadingReminderKind.daily;
  }
}

/// Zamanlanan okuma hatırlatması. Saklanmaz; kitaplar, günlük okuma kaydı ve
/// ayarlardan hesaplanır (`ReadingReminderController.plan`). Metin zamanlanırken
/// uygulama diline göre üretilir. [bookId] boşsa okunan kitap yoktur.
@immutable
class ReadingReminderModel {
  final ReadingReminderKind kind;
  final DateTime scheduledAt;
  final String? bookId;

  /// Seri hatırlatmasında art arda okunan gün sayısı; diğerlerinde 0.
  final int streakDays;

  const ReadingReminderModel({required this.kind, required this.scheduledAt, this.bookId, this.streakDays = 0});

  ReadingReminderModel copyWith({ReadingReminderKind? kind, DateTime? scheduledAt, String? bookId, int? streakDays}) {
    return ReadingReminderModel(
      kind: kind ?? this.kind,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      bookId: bookId ?? this.bookId,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  factory ReadingReminderModel.fromJson(Map<String, dynamic> json) {
    return ReadingReminderModel(
      kind: ReadingReminderKind.fromName(json['kind'] as String?),
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      bookId: json['bookId'] as String?,
      streakDays: json['streakDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'kind': kind.name, 'scheduledAt': scheduledAt.toIso8601String(), 'bookId': bookId, 'streakDays': streakDays};
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingReminderModel &&
      other.kind == kind &&
      other.scheduledAt == scheduledAt &&
      other.bookId == bookId &&
      other.streakDays == streakDays;

  @override
  int get hashCode => Object.hash(kind, scheduledAt, bookId, streakDays);
}
