import 'package:flutter/foundation.dart';

@immutable
class GoalStepModel {
  final String id;
  final int amount; // kuruş
  final DateTime date;
  final String? note;

  const GoalStepModel({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  GoalStepModel copyWith({
    String? id,
    int? amount,
    DateTime? date,
    String? note,
  }) {
    return GoalStepModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory GoalStepModel.fromJson(Map<String, dynamic> json) {
    return GoalStepModel(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

@immutable
class GoalModel {
  final String id;
  final String title;
  final int targetAmount; // kuruş
  final List<GoalStepModel> steps;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.steps = const [],
    required this.createdAt,
  });

  int get savedAmount => steps.fold(0, (sum, s) => sum + s.amount);

  double get progress =>
      targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isReached => savedAmount >= targetAmount && targetAmount > 0;

  GoalModel copyWith({
    String? id,
    String? title,
    int? targetAmount,
    List<GoalStepModel>? steps,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List? ?? [];
    return GoalModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetAmount: json['targetAmount'] as int? ?? 0,
      steps: rawSteps
          .whereType<Map<String, dynamic>>()
          .map(GoalStepModel.fromJson)
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'steps': steps.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
