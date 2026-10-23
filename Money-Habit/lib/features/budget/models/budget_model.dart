import 'package:flutter/foundation.dart';

@immutable
class BudgetModel {
  final String monthKey; // yyyy-MM
  final int limitAmount; // kuruş

  const BudgetModel({
    required this.monthKey,
    required this.limitAmount,
  });

  BudgetModel copyWith({
    String? monthKey,
    int? limitAmount,
  }) {
    return BudgetModel(
      monthKey: monthKey ?? this.monthKey,
      limitAmount: limitAmount ?? this.limitAmount,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      monthKey: json['monthKey'] as String? ?? '',
      limitAmount: json['limitAmount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'limitAmount': limitAmount,
    };
  }
}
