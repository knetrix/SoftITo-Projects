import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final int totalPoints;
  final String currentRank;
  final String preferredLanguage;
  final bool isDarkMode;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.totalPoints = 0,
    this.currentRank = 'Çaylak (Seviye 1)',
    this.preferredLanguage = 'tr',
    this.isDarkMode = true,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? totalPoints,
    String? currentRank,
    String? preferredLanguage,
    bool? isDarkMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      currentRank: currentRank ?? this.currentRank,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentRank: json['currentRank'] as String? ?? 'Çaylak (Seviye 1)',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'tr',
      isDarkMode: json['isDarkMode'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'currentRank': currentRank,
      'preferredLanguage': preferredLanguage,
      'isDarkMode': isDarkMode,
    };
  }
}
