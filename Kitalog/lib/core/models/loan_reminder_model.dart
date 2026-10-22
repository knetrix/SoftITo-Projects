import 'package:flutter/foundation.dart';

/// Hatırlatmanın türü: iade gününden bir gün önce veya iade günü.
enum LoanReminderKind {
  dueTomorrow,
  dueToday;

  static LoanReminderKind fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return LoanReminderKind.dueToday;
  }
}

/// Ödünçteki bir kitap için zamanlanmış iade hatırlatması. Metni (başlık,
/// kişi) zamanlanırken uygulama diline göre üretilir; burada saklanmaz.
@immutable
class LoanReminderModel {
  final String bookId;
  final LoanReminderKind kind;
  final DateTime scheduledAt;

  const LoanReminderModel({required this.bookId, required this.kind, required this.scheduledAt});

  LoanReminderModel copyWith({String? bookId, LoanReminderKind? kind, DateTime? scheduledAt}) {
    return LoanReminderModel(
      bookId: bookId ?? this.bookId,
      kind: kind ?? this.kind,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  factory LoanReminderModel.fromJson(Map<String, dynamic> json) {
    return LoanReminderModel(
      bookId: json['bookId'] as String? ?? '',
      kind: LoanReminderKind.fromName(json['kind'] as String?),
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'kind': kind.name, 'scheduledAt': scheduledAt.toIso8601String()};
  }

  @override
  bool operator ==(Object other) =>
      other is LoanReminderModel && other.bookId == bookId && other.kind == kind && other.scheduledAt == scheduledAt;

  @override
  int get hashCode => Object.hash(bookId, kind, scheduledAt);
}
