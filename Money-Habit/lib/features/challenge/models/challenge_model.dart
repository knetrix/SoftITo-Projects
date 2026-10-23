import 'package:flutter/foundation.dart';

@immutable
class ChallengeTaskModel {
  final int dayNumber; // 1-10
  final String title;
  final String description;
  final DateTime? completedAt;

  const ChallengeTaskModel({
    required this.dayNumber,
    required this.title,
    required this.description,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  ChallengeTaskModel copyWith({
    int? dayNumber,
    String? title,
    String? description,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ChallengeTaskModel(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  factory ChallengeTaskModel.fromJson(Map<String, dynamic> json) {
    return ChallengeTaskModel(
      dayNumber: json['dayNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}

@immutable
class ChallengeModel {
  final String id;
  final String title;
  final List<ChallengeTaskModel> tasks;
  final DateTime startDate;
  final int currentStreak;
  final int bestStreak;
  final bool isCompleted;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.tasks,
    required this.startDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isCompleted = false,
  });

  int get completedTaskCount => tasks.where((t) => t.isCompleted).length;

  ChallengeModel copyWith({
    String? id,
    String? title,
    List<ChallengeTaskModel>? tasks,
    DateTime? startDate,
    int? currentStreak,
    int? bestStreak,
    bool? isCompleted,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
      startDate: startDate ?? this.startDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List? ?? [];
    return ChallengeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tasks: rawTasks
          .whereType<Map<String, dynamic>>()
          .map(ChallengeTaskModel.fromJson)
          .toList(),
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isCompleted': isCompleted,
    };
  }
}
