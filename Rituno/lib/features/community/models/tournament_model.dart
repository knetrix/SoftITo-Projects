import 'package:flutter/foundation.dart';

@immutable
class TournamentModel {
  final String id;
  final String title;
  final String description;
  final String habitId;
  final int participantCount;
  final List<Map<String, dynamic>> leaderboard;
  final String startDate;
  final String endDate;
  final int rewardPoints;
  final bool isJoined;

  const TournamentModel({
    required this.id,
    required this.title,
    required this.description,
    this.habitId = '',
    this.participantCount = 0,
    this.leaderboard = const [],
    this.startDate = '',
    this.endDate = '',
    this.rewardPoints = 500,
    this.isJoined = false,
  });

  TournamentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? habitId,
    int? participantCount,
    List<Map<String, dynamic>>? leaderboard,
    String? startDate,
    String? endDate,
    int? rewardPoints,
    bool? isJoined,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      habitId: habitId ?? this.habitId,
      participantCount: participantCount ?? this.participantCount,
      leaderboard: leaderboard ?? this.leaderboard,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      habitId: json['habitId'] as String? ?? '',
      participantCount: json['participantCount'] as int? ?? 0,
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      rewardPoints: json['rewardPoints'] as int? ?? 500,
      isJoined: json['isJoined'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'habitId': habitId,
      'participantCount': participantCount,
      'leaderboard': leaderboard,
      'startDate': startDate,
      'endDate': endDate,
      'rewardPoints': rewardPoints,
      'isJoined': isJoined,
    };
  }
}
