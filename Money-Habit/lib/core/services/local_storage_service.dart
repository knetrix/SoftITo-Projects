import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  bool get isLoggedIn => _prefs.getBool(StorageKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(StorageKeys.isLoggedIn, value);

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();
}
