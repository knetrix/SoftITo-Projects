import 'package:flutter/material.dart';

@immutable
class AppSettingsModel {
  final ThemeMode themeMode;
  final String localeCode;

  const AppSettingsModel({
    this.themeMode = ThemeMode.dark,
    this.localeCode = 'tr',
  });

  AppSettingsModel copyWith({ThemeMode? themeMode, String? localeCode}) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final themeName = json['themeMode'] as String?;
    return AppSettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemeMode.dark,
      ),
      localeCode: json['localeCode'] as String? ?? 'tr',
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.name, 'localeCode': localeCode};
  }
}
