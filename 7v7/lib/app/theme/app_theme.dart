import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// İki tema (açık / karanlık). Material varsayılanları görüntülerle
/// çeliştiği yerlerde özel widget'lar kullanılır (core/widgets).
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.error,
      onError: c.card,
      surface: c.card,
      onSurface: c.ink,
      surfaceContainerHighest: c.chip,
      outline: c.line,
    );
    final base = AppTextStyles.body(400, color: c.ink);
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: AppTextStyles.family,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      splashColor: c.ink.withValues(alpha: .06),
      highlightColor: Colors.transparent,
      textTheme: TextTheme(
        bodyLarge: base,
        bodyMedium: base,
        bodySmall: AppTextStyles.bodySm(400, color: c.ink2),
        titleLarge: AppTextStyles.title(color: c.ink),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.ink,
        selectionColor: c.accent.withValues(alpha: .3),
        selectionHandleColor: c.accent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerColor: c.line,
    );
  }
}
