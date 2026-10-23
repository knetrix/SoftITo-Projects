import 'package:flutter/foundation.dart';

import 'avatar_model.dart';

@immutable
class UserModel {
  final String id;
  final String email;
  final String phone;
  final String passwordHash;
  final AvatarModel? avatar;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordHash,
    this.avatar,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? passwordHash,
    AvatarModel? avatar,
    bool clearAvatar = false,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      avatar: json['avatar'] != null
          ? AvatarModel.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      if (avatar != null) 'avatar': avatar!.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
