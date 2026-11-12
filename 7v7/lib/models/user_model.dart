import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/validators.dart';

/// `users/{uid}` (§6.2): herkese açık profil. E-posta ve telefon burada
/// tutulmaz; bkz. `ContactModel` (`users/{uid}/private/contact`).
class UserModel {
  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.city = '',
    this.position = '',
    this.themeMode = 'light',
    this.locale = 'tr',
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String city;

  /// 'gk' | 'def' | 'mid' | 'att' | ''
  final String position;
  final String themeMode;
  final String locale;

  String get fullName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
  bool get isGk => position == 'gk';

  String get initials {
    final parts = fullName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return trUpper(parts.take(2).map((w) => w.substring(0, 1)).join());
  }

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    final s = (m['settings'] as Map?) ?? const {};
    return UserModel(
      uid: d.id,
      firstName: (m['firstName'] ?? '') as String,
      lastName: (m['lastName'] ?? '') as String,
      city: (m['city'] ?? '') as String,
      position: (m['position'] ?? '') as String,
      themeMode: (s['themeMode'] ?? 'light') as String,
      locale: (s['locale'] ?? 'tr') as String,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'position': position,
        'settings': {'themeMode': themeMode, 'locale': locale},
        'createdAt': FieldValue.serverTimestamp(),
      };
}
