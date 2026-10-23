import 'package:flutter/material.dart';

@immutable
class AppSettingsModel {
  final ThemeMode themeMode;
  final String localeCode;

  const AppSettingsModel({
    this.themeMode = ThemeMode.dark,
    this.localeCode = 'tr',
  });

  AppSettingsModel copyWith({
    ThemeMode? themeMode,
    String? localeCode,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final themeStr = json['themeMode'] as String? ?? 'dark';
    final theme = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
    final locale = json['localeCode'] as String? ?? 'tr';
    return AppSettingsModel(
      themeMode: theme,
      localeCode: locale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'localeCode': localeCode,
    };
  }
}
