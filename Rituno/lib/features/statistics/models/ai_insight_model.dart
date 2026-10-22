import 'package:flutter/foundation.dart';

@immutable
class AIInsightModel {
  final String id;
  final String userId;
  final String generatedSummary;
  final List<String> suggestions;
  final String createdAt;

  const AIInsightModel({
    required this.id,
    required this.userId,
    required this.generatedSummary,
    required this.suggestions,
    required this.createdAt,
  });

  AIInsightModel copyWith({
    String? id,
    String? userId,
    String? generatedSummary,
    List<String>? suggestions,
    String? createdAt,
  }) {
    return AIInsightModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      generatedSummary: generatedSummary ?? this.generatedSummary,
      suggestions: suggestions ?? this.suggestions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AIInsightModel.fromJson(Map<String, dynamic> json) {
    return AIInsightModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      generatedSummary: json['generatedSummary'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'generatedSummary': generatedSummary,
      'suggestions': suggestions,
      'createdAt': createdAt,
    };
  }
}
