import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.error,
      onError: AppColors.darkBackground,
      outline: AppColors.darkOutline,
      outlineVariant: Color(0xFF1E293B),
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkTextPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextPrimary),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.darkTextPrimary,
        iconColor: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          side: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkPrimary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkPrimary);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkPrimary.withValues(alpha: 0.25);
            }
            return AppColors.darkSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkPrimary;
            }
            return AppColors.darkTextSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.darkOutline),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkPrimary.withValues(alpha: 0.25),
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
        side: const BorderSide(color: AppColors.darkOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 2,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 1,
      ),
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.error,
      onError: AppColors.lightBackground,
      outline: AppColors.lightOutline,
      outlineVariant: Color(0xFFE2E8F0),
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightTextPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightTextPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.lightTextPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.lightTextPrimary),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.lightTextPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightTextSecondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.lightTextPrimary),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.lightTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightBackground,
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.lightTextPrimary,
        iconColor: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          side: const BorderSide(color: AppColors.lightOutline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightPrimary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightPrimary);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.lightPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary.withValues(alpha: 0.15);
            }
            return AppColors.lightSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary;
            }
            return AppColors.lightTextSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.lightOutline),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.lightPrimary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
        side: const BorderSide(color: AppColors.lightOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        prefixIconColor: AppColors.lightTextSecondary,
        suffixIconColor: AppColors.lightTextSecondary,
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          side: const BorderSide(color: AppColors.lightPrimary),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 2,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutline,
        thickness: 1,
      ),
    );
  }
}
