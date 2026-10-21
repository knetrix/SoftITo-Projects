import 'package:flutter/foundation.dart';

@immutable
class ReadingGoalModel {
  final int year;
  final int targetBookCount;

  const ReadingGoalModel({required this.year, required this.targetBookCount});

  ReadingGoalModel copyWith({int? year, int? targetBookCount}) {
    return ReadingGoalModel(
      year: year ?? this.year,
      targetBookCount: targetBookCount ?? this.targetBookCount,
    );
  }

  factory ReadingGoalModel.fromJson(Map<String, dynamic> json) {
    return ReadingGoalModel(
      year: json['year'] as int? ?? DateTime.now().year,
      targetBookCount: json['targetBookCount'] as int? ?? 12,
    );
  }

  Map<String, dynamic> toJson() {
    return {'year': year, 'targetBookCount': targetBookCount};
  }
}
