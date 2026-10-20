import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;

import 'storage_service.dart';

/// Uygulama geneli tema + dil durumu. `main.dart` sahibidir.
class SettingsController {
  SettingsController(this._storage)
      : themeMode = ValueNotifier<ThemeMode>(_storage.loadThemeMode()),
        locale = ValueNotifier<Locale>(_storage.loadLocale());

  static const List<Locale> supportedLocales = [Locale('tr'), Locale('en')];

  final StorageService _storage;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale> locale;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;
    themeMode.value = mode;
    await _storage.saveThemeMode(mode);
  }

  Future<void> setLocale(Locale newLocale) async {
    if (locale.value == newLocale) return;
    locale.value = newLocale;
    await _storage.saveLocale(newLocale);
  }

  void dispose() {
    themeMode.dispose();
    locale.dispose();
  }
}
