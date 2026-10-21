import 'package:flutter/foundation.dart';

import 'avatar_type.dart';

@immutable
class UserModel {
  final String id;
  final String email;
  final String phone;
  final String passwordHash;
  final AvatarType avatarType;
  final String? avatarValue;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordHash,
    this.avatarType = AvatarType.none,
    this.avatarValue,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? passwordHash,
    AvatarType? avatarType,
    String? avatarValue,
    bool clearAvatarValue = false,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarType: avatarType ?? this.avatarType,
      avatarValue: clearAvatarValue ? null : (avatarValue ?? this.avatarValue),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      avatarType: AvatarType.fromName(json['avatarType'] as String?),
      avatarValue: json['avatarValue'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'avatarType': avatarType.name,
      'avatarValue': avatarValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
