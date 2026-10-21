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

  /// İade tarihi geçmişse ödünç gecikmiştir (hesaplanan değer, saklanmaz).
  bool isOverdue(DateTime now) => dueAt != null && dueAt!.isBefore(now);

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
