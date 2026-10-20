import 'package:flutter/foundation.dart';

import '../../auth/models/user_model.dart';

@immutable
class ProfileModel {
  const ProfileModel({required this.email, required this.phone});

  final String email;

  /// Kayıt biçimi `5XXXXXXXXX`.
  final String phone;

  factory ProfileModel.fromUser(UserModel? user) =>
      ProfileModel(email: user?.email ?? '', phone: user?.phone ?? '');

  /// Görüntü biçimi: `0 5XX XXX XX XX`.
  String get displayPhone {
    if (phone.length != 10) return phone;
    return '0 ${phone.substring(0, 3)} ${phone.substring(3, 6)} '
        '${phone.substring(6, 8)} ${phone.substring(8)}';
  }

  String get initial => email.isEmpty ? '?' : email[0].toUpperCase();

  @override
  bool operator ==(Object other) =>
      other is ProfileModel && other.email == email && other.phone == phone;

  @override
  int get hashCode => Object.hash(email, phone);
}
