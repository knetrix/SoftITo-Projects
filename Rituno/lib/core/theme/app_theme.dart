import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Rutino tema yöneticisi
/// Material 3 destekli çift tema (Koyu Varsayılan & Aydınlık)
class AppTheme {
  static final ThemeData dark = createDarkTheme();
  static final ThemeData light = createLightTheme();
}
