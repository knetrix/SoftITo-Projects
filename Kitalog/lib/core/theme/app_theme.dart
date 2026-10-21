import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// "Gece Kütüphanesi" (koyu) ve "Kağıt" (aydınlık) temaları.
abstract final class AppTheme {
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.amber,
    onPrimary: AppColors.inkBlack,
    primaryContainer: AppColors.amberContainer,
    onPrimaryContainer: AppColors.amberLight,
    secondary: AppColors.amber,
    onSecondary: AppColors.inkBlack,
    secondaryContainer: AppColors.inkSurfaceHigh,
    onSecondaryContainer: AppColors.inkText,
    error: AppColors.errorDark,
    onError: AppColors.inkBlack,
    surface: AppColors.inkBlack,
    onSurface: AppColors.inkText,
    onSurfaceVariant: AppColors.inkTextMuted,
    surfaceContainerLow: AppColors.inkSurface,
    surfaceContainer: AppColors.inkSurface,
    surfaceContainerHigh: AppColors.inkSurfaceHigh,
    surfaceContainerHighest: AppColors.inkSurfaceHigh,
    outline: AppColors.inkOutline,
    outlineVariant: AppColors.inkOutline,
    scrim: AppColors.scrim,
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.amberDeep,
    onPrimary: AppColors.paperSurface,
    primaryContainer: AppColors.amberLight,
    onPrimaryContainer: AppColors.paperText,
    secondary: AppColors.amberDeep,
    onSecondary: AppColors.paperSurface,
    secondaryContainer: AppColors.paperSurfaceHigh,
    onSecondaryContainer: AppColors.paperText,
    error: AppColors.errorLight,
    onError: AppColors.paperSurface,
    surface: AppColors.paper,
    onSurface: AppColors.paperText,
    onSurfaceVariant: AppColors.paperTextMuted,
    surfaceContainerLow: AppColors.paperSurface,
    surfaceContainer: AppColors.paperSurface,
    surfaceContainerHigh: AppColors.paperSurfaceHigh,
    surfaceContainerHighest: AppColors.paperSurfaceHigh,
    outline: AppColors.paperOutline,
    outlineVariant: AppColors.paperOutline,
    scrim: AppColors.scrim,
  );

  static ThemeData get dark => _build(_darkScheme);
  static ThemeData get light => _build(_lightScheme);

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );
    final textTheme = _textTheme(base.textTheme, scheme);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: shape,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        linearMinHeight: 8,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    return base
        .copyWith(
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          bodySmall: base.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
