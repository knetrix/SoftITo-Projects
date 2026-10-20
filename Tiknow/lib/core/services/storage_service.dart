import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/active_rentals/models/active_rental_model.dart';
import '../../features/auth/models/user_model.dart';

/// `shared_preferences` için TEK erişim noktası. View/controller doğrudan
/// `SharedPreferences` çağırmaz. Bozuk JSON okunursa varsayılana dönülür.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeKey = 'tiknow.theme_mode';
  static const String _localeKey = 'tiknow.locale';
  static const String _userKey = 'tiknow.user';
  static const String _sessionKey = 'tiknow.session_active';
  static const String _rentalsKey = 'tiknow.active_rentals';

  static Future<StorageService> init() async {
    return StorageService(await SharedPreferences.getInstance());
  }

  // --- Tema ---

  ThemeMode loadThemeMode() {
    final raw = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  // --- Dil ---

  Locale loadLocale() {
    final raw = _prefs.getString(_localeKey);
    return Locale(raw == 'en' ? 'en' : 'tr');
  }

  Future<void> saveLocale(Locale locale) =>
      _prefs.setString(_localeKey, locale.languageCode);

  // --- Kullanıcı + oturum ---

  UserModel? loadUser() {
    final json = _readJson(_userKey);
    if (json is! Map<String, dynamic>) return null;
    final user = UserModel.fromJson(json);
    return user.email.isEmpty ? null : user;
  }

  Future<void> saveUser(UserModel user) =>
      _prefs.setString(_userKey, jsonEncode(user.toJson()));

  bool get isSessionActive => _prefs.getBool(_sessionKey) ?? false;

  Future<void> setSessionActive(bool active) =>
      _prefs.setBool(_sessionKey, active);

  // --- Aktif kiralamalar ---

  List<ActiveRentalModel> loadRentals() {
    final json = _readJson(_rentalsKey);
    if (json is! List) return const [];
    final rentals = <ActiveRentalModel>[];
    for (final item in json) {
      if (item is! Map) continue;
      final rental = ActiveRentalModel.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (rental.id.isNotEmpty && rental.status == RentalStatus.active) {
        rentals.add(rental);
      }
    }
    return rentals;
  }

  Future<void> saveRentals(List<ActiveRentalModel> rentals) {
    return _prefs.setString(
      _rentalsKey,
      jsonEncode([for (final r in rentals) r.toJson()]),
    );
  }

  Object? _readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException catch (e) {
      debugPrint('StorageService: "$key" bozuk JSON, varsayılana dönüldü: $e');
      return null;
    }
  }
}
