import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../models/app_settings_model.dart';
import '../repositories/settings_repository.dart';

/// Tema ve dil ayarlarını tutan paylaşılan controller (AppScope üzerinden).
class SettingsController {
  SettingsController({required this._repository});

  final SettingsRepository _repository;
  final ValueNotifier<AppSettingsModel> state =
      ValueNotifier<AppSettingsModel>(const AppSettingsModel());

  Future<void> load() async {
    state.value = await _repository.get();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final next = state.value.copyWith(themeMode: mode);
    await _repository.save(next);
    state.value = next;
  }

  Future<void> setLocaleCode(String code) async {
    final next = state.value.copyWith(localeCode: code);
    await _repository.save(next);
    state.value = next;
  }

  Future<void> setReaderTextScale(double scale) async {
    final next = state.value.copyWith(readerTextScale: scale);
    await _repository.save(next);
    state.value = next;
  }

  Future<void> setLoanRemindersEnabled(bool enabled) async {
    final next = state.value.copyWith(loanRemindersEnabled: enabled);
    await _repository.save(next);
    state.value = next;
  }

  Future<void> setReadingRemindersEnabled(bool enabled) async {
    final next = state.value.copyWith(readingRemindersEnabled: enabled);
    await _repository.save(next);
    state.value = next;
  }

  Future<void> setStalledBookRemindersEnabled(bool enabled) async {
    final next = state.value.copyWith(stalledBookRemindersEnabled: enabled);
    await _repository.save(next);
    state.value = next;
  }

  /// Okuma hatırlatmalarının saati (gece yarısından itibaren dakika).
  Future<void> setReadingReminderMinutes(int minutes) async {
    final next = state.value.copyWith(readingReminderMinutes: minutes);
    await _repository.save(next);
    state.value = next;
  }

  void dispose() {
    state.dispose();
  }
}
