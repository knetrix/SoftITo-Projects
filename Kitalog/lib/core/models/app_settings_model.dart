import 'package:flutter/material.dart';

@immutable
class AppSettingsModel {
  final ThemeMode themeMode;
  final String localeCode;

  /// Dijital okuyucunun yazı boyutu çarpanı.
  final double readerTextScale;

  /// Ödünç verilen kitapların iade hatırlatmaları (yerel bildirim) açık mı.
  final bool loanRemindersEnabled;

  /// Günlük okuma hatırlatması (okuma serisi dahil) açık mı.
  final bool readingRemindersEnabled;

  /// Uzun süredir ilerlemeyen "Okunuyor" kitap hatırlatması açık mı.
  final bool stalledBookRemindersEnabled;

  /// Okuma hatırlatmalarının saati, gece yarısından itibaren dakika (varsayılan 21:00).
  final int readingReminderMinutes;

  static const int defaultReadingReminderMinutes = 21 * 60;
  static const int _minutesPerDay = 24 * 60;

  static const double minReaderTextScale = 0.8;
  static const double maxReaderTextScale = 1.8;

  const AppSettingsModel({
    this.themeMode = ThemeMode.dark,
    this.localeCode = 'tr',
    this.readerTextScale = 1.0,
    this.loanRemindersEnabled = true,
    this.readingRemindersEnabled = false,
    this.stalledBookRemindersEnabled = false,
    this.readingReminderMinutes = defaultReadingReminderMinutes,
  });

  /// Okuma hatırlatmalarından en az biri açık mı (saat seçimi buna göre etkin).
  bool get anyReadingReminderEnabled => readingRemindersEnabled || stalledBookRemindersEnabled;

  /// Geçersiz dakika (ör. elle bozulmuş kayıt) varsayılan saate düşer.
  static int _validMinutes(int minutes) =>
      minutes >= 0 && minutes < _minutesPerDay ? minutes : defaultReadingReminderMinutes;

  AppSettingsModel copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    double? readerTextScale,
    bool? loanRemindersEnabled,
    bool? readingRemindersEnabled,
    bool? stalledBookRemindersEnabled,
    int? readingReminderMinutes,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      readerTextScale: (readerTextScale ?? this.readerTextScale).clamp(
        minReaderTextScale,
        maxReaderTextScale,
      ),
      loanRemindersEnabled: loanRemindersEnabled ?? this.loanRemindersEnabled,
      readingRemindersEnabled: readingRemindersEnabled ?? this.readingRemindersEnabled,
      stalledBookRemindersEnabled: stalledBookRemindersEnabled ?? this.stalledBookRemindersEnabled,
      readingReminderMinutes: _validMinutes(readingReminderMinutes ?? this.readingReminderMinutes),
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final themeName = json['themeMode'] as String?;
    final scale = (json['readerTextScale'] as num?)?.toDouble() ?? 1.0;
    return AppSettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemeMode.dark,
      ),
      localeCode: json['localeCode'] as String? ?? 'tr',
      readerTextScale: scale.clamp(minReaderTextScale, maxReaderTextScale),
      loanRemindersEnabled: json['loanRemindersEnabled'] as bool? ?? true,
      readingRemindersEnabled: json['readingRemindersEnabled'] as bool? ?? false,
      stalledBookRemindersEnabled: json['stalledBookRemindersEnabled'] as bool? ?? false,
      readingReminderMinutes: _validMinutes(json['readingReminderMinutes'] as int? ?? defaultReadingReminderMinutes),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'localeCode': localeCode,
      'readerTextScale': readerTextScale,
      'loanRemindersEnabled': loanRemindersEnabled,
      'readingRemindersEnabled': readingRemindersEnabled,
      'stalledBookRemindersEnabled': stalledBookRemindersEnabled,
      'readingReminderMinutes': readingReminderMinutes,
    };
  }
}
