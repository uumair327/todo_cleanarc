import 'package:flutter/material.dart';

import 'app_typography.dart';

import 'app_theme_data.dart';

class AppTheme {
  // Static text theme for direct access
  static const TextTheme textTheme = TextTheme(
    displayLarge: AppTypography.h1,
    displayMedium: AppTypography.h2,
    displaySmall: AppTypography.h3,
    headlineLarge: AppTypography.h4,
    headlineMedium: AppTypography.h5,
    headlineSmall: AppTypography.h6,
    titleLarge: AppTypography.h5,
    titleMedium: AppTypography.h6,
    titleSmall: AppTypography.labelLarge,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  static ThemeData get lightTheme {
    final colorExtension = AppThemeData.createColorExtension(ThemeMode.light);
    return AppThemeData.lightTheme(colorExtension);
  }

  static ThemeData get darkTheme {
    final colorExtension = AppThemeData.createColorExtension(ThemeMode.dark);
    return AppThemeData.darkTheme(colorExtension);
  }
}
