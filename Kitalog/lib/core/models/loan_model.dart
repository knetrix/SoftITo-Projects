import 'package:flutter/foundation.dart';

@immutable
class LoanModel {
  final String borrowerName;
  final DateTime lentAt;
  final DateTime? dueAt;

  const LoanModel({
    required this.borrowerName,
    required this.lentAt,
    this.dueAt,
  });

  /// İki tarih arasındaki takvim günü farkı (saat ve yaz saati farkı yok sayılır).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// İade gününe kalan gün: bugün 0, geçtiyse negatif; iade tarihi yoksa `null`.
  int? daysUntilDue(DateTime now) => dueAt == null ? null : daysBetween(now, dueAt!);

  /// İade günü geçmişse ödünç gecikmiştir; iade günü henüz gecikme sayılmaz
  /// (hesaplanan değer, saklanmaz).
  bool isOverdue(DateTime now) => (daysUntilDue(now) ?? 0) < 0;

  /// Kitabın kaç gündür ödünçte olduğu (veriliş günü 0).
  int daysOut(DateTime now) => daysBetween(lentAt, now);

  LoanModel copyWith({
    String? borrowerName,
    DateTime? lentAt,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) {
    return LoanModel(
      borrowerName: borrowerName ?? this.borrowerName,
      lentAt: lentAt ?? this.lentAt,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
    );
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      borrowerName: json['borrowerName'] as String? ?? '',
      lentAt:
          DateTime.tryParse(json['lentAt'] as String? ?? '') ?? DateTime.now(),
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrowerName': borrowerName,
      'lentAt': lentAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
    };
  }
}
