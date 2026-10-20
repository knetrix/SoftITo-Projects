import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.salt,
  });

  final String id;
  final String email;

  /// Başındaki 0 atılmış 10 hane (`5XXXXXXXXX`).
  final String phone;
  final String passwordHash;
  final String salt;

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? passwordHash,
    String? salt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      salt: json['salt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'passwordHash': passwordHash,
        'salt': salt,
      };
}
