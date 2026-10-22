import 'package:flutter/foundation.dart';

@immutable
class HabitModel {
  final String id;
  final String title;
  final String description;
  final String frequency;
  final String? reminderTime;
  final int streakCount;
  final int bestStreak;
  final bool isCompletedToday;
  final List<String> completedDates;
  final String category;

  const HabitModel({
    required this.id,
    required this.title,
    this.description = '',
    this.frequency = 'Her Gün',
    this.reminderTime,
    this.streakCount = 0,
    this.bestStreak = 0,
    this.isCompletedToday = false,
    this.completedDates = const <String>[],
    this.category = 'Sağlık & Spor',
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    String? reminderTime,
    int? streakCount,
    int? bestStreak,
    bool? isCompletedToday,
    List<String>? completedDates,
    String? category,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      streakCount: streakCount ?? this.streakCount,
      bestStreak: bestStreak ?? this.bestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      completedDates: completedDates ?? this.completedDates,
      category: category ?? this.category,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'Her Gün',
      reminderTime: json['reminderTime'] as String?,
      streakCount: json['streakCount'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      category: json['category'] as String? ?? 'Sağlık & Spor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
      'reminderTime': reminderTime,
      'streakCount': streakCount,
      'bestStreak': bestStreak,
      'isCompletedToday': isCompletedToday,
      'completedDates': completedDates,
      'category': category,
    };
  }
}
