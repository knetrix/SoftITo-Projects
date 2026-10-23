import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

enum ExpenseCategory {
  market,
  transport,
  bills,
  entertainment,
  health,
  education,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  IconData get icon => switch (this) {
        ExpenseCategory.market => Icons.shopping_cart_outlined,
        ExpenseCategory.transport => Icons.directions_bus_outlined,
        ExpenseCategory.bills => Icons.receipt_long_outlined,
        ExpenseCategory.entertainment => Icons.movie_outlined,
        ExpenseCategory.health => Icons.medical_services_outlined,
        ExpenseCategory.education => Icons.school_outlined,
        ExpenseCategory.other => Icons.more_horiz,
      };

  Color get color => switch (this) {
        ExpenseCategory.market => AppColors.categoryMarket,
        ExpenseCategory.transport => AppColors.categoryTransport,
        ExpenseCategory.bills => AppColors.categoryBills,
        ExpenseCategory.entertainment => AppColors.categoryEntertainment,
        ExpenseCategory.health => AppColors.categoryHealth,
        ExpenseCategory.education => AppColors.categoryEducation,
        ExpenseCategory.other => AppColors.categoryOther,
      };

  String label(AppLocalizations l10n) => switch (this) {
        ExpenseCategory.market => l10n.categoryMarket,
        ExpenseCategory.transport => l10n.categoryTransport,
        ExpenseCategory.bills => l10n.categoryBills,
        ExpenseCategory.entertainment => l10n.categoryEntertainment,
        ExpenseCategory.health => l10n.categoryHealth,
        ExpenseCategory.education => l10n.categoryEducation,
        ExpenseCategory.other => l10n.categoryOther,
      };
}

@immutable
class ExpenseModel {
  final String id;
  final int amount; // kuruş (125,50 TL -> 12550)
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  ExpenseModel copyWith({
    String? id,
    int? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      category: ExpenseCategory.values.asNameMap()[json['category']] ??
          ExpenseCategory.other,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}
