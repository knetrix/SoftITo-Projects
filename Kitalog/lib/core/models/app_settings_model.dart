import 'package:flutter/material.dart';

@immutable
class AppSettingsModel {
  final ThemeMode themeMode;
  final String localeCode;

  /// Dijital okuyucunun yazı boyutu çarpanı.
  final double readerTextScale;

  static const double minReaderTextScale = 0.8;
  static const double maxReaderTextScale = 1.8;

  const AppSettingsModel({
    this.themeMode = ThemeMode.dark,
    this.localeCode = 'tr',
    this.readerTextScale = 1.0,
  });

  AppSettingsModel copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    double? readerTextScale,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      readerTextScale: (readerTextScale ?? this.readerTextScale).clamp(
        minReaderTextScale,
        maxReaderTextScale,
      ),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'localeCode': localeCode,
      'readerTextScale': readerTextScale,
    };
  }
}
