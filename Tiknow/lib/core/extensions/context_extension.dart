import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

extension ContextExtension on BuildContext {
  /// Aktif dile göre çeviri. `{ad}` yer tutucuları [args] ile doldurulur.
  String tr(String key, {Map<String, String>? args}) {
    return AppStrings.translate(
      Localizations.localeOf(this).languageCode,
      key,
      args: args,
    );
  }

  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
