import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// `SharedPreferences` üzerindeki TEK erişim noktası.
/// View ve Controller bu sınıfa doğrudan erişmez; yalnızca Repository'ler kullanır.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  Map<String, dynamic>? readJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return const [];
      return decoded.whereType<Map<String, dynamic>>().toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> writeJsonMap(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  bool readBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  int readInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
