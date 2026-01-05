import 'package:flutter/material.dart';
import '../../utils/typedef.dart';
import '../entities/app_theme_config.dart';
import '../entities/theme_state.dart';

/// Repository interface for theme configuration management and persistence
/// 
/// This interface defines the contract for managing theme configurations,
/// user preferences, and system theme integration.
abstract class ThemeRepository {
  /// Retrieves the currently active theme configuration
  /// 
  /// Returns the theme that should be applied to the application.
  /// If no theme is saved, returns the default theme.
  ResultFuture<AppThemeConfig> getCurrentTheme();

  /// Saves the specified theme as the current theme
  /// 
  /// Persists the theme selection so it can be restored when the app restarts.
  ResultVoid saveTheme(AppThemeConfig theme);

  /// Retrieves all available theme configurations
  /// 
  /// Returns a list of all themes that the user can choose from,
  /// including built-in and custom themes.
  ResultFuture<List<AppThemeConfig>> getAvailableThemes();

  /// Adds a new custom theme to the available themes
  /// 
  /// Allows users to create and save custom theme configurations.
  ResultVoid addCustomTheme(AppThemeConfig theme);

  /// Removes a custom theme from the available themes
  /// 
  /// Built-in themes cannot be removed, only custom themes.
  ResultVoid removeCustomTheme(String themeName);

  /// Updates an existing custom theme
  /// 
  /// Allows modification of custom theme configurations.
  /// Built-in themes cannot be modified.
  ResultVoid updateCustomTheme(AppThemeConfig theme);

  /// Watches for system theme changes (light/dark mode)
  /// 
  /// Returns a stream that emits the current system theme mode
  /// whenever it changes. Used for automatic theme switching.
  Stream<ThemeMode> watchSystemTheme();

  /// Gets the current system theme mode
  /// 
  /// Returns the current system preference for light/dark mode.
  ResultFuture<ThemeMode> getSystemThemeMode();

  /// Retrieves the user's system theme preference setting
  /// 
  /// Returns whether the user has enabled automatic system theme following.
  ResultFuture<bool> getSystemThemeEnabled();

  /// Saves the user's system theme preference setting
  /// 
  /// Persists whether the app should follow system theme changes.
  ResultVoid setSystemThemeEnabled(bool enabled);

  /// Retrieves the complete current theme state
  /// 
  /// Returns a ThemeState object containing the current theme,
  /// available themes, and system theme settings.
  ResultFuture<ThemeState> getThemeState();

  /// Saves the complete theme state
  /// 
  /// Persists all theme-related settings and configurations.
  ResultVoid saveThemeState(ThemeState state);

  /// Resets all theme settings to defaults
  /// 
  /// Clears all custom themes and preferences, returning to
  /// the default theme configuration.
  ResultVoid resetToDefaults();

  /// Validates that a theme configuration is valid
  /// 
  /// Checks that the theme has all required color tokens and
  /// meets the application's theme requirements.
  ResultVoid validateTheme(AppThemeConfig theme);

  /// Exports a theme configuration to a shareable format
  /// 
  /// Converts a theme to a format that can be shared or backed up.
  ResultFuture<Map<String, dynamic>> exportTheme(AppThemeConfig theme);

  /// Imports a theme configuration from an external format
  /// 
  /// Creates a theme configuration from imported data.
  ResultFuture<AppThemeConfig> importTheme(Map<String, dynamic> themeData);

  /// Checks if a theme with the given name already exists
  /// 
  /// Used to prevent duplicate theme names when creating custom themes.
  ResultFuture<bool> themeExists(String themeName);

  /// Gets the default theme configuration
  /// 
  /// Returns the built-in default theme that serves as a fallback.
  ResultFuture<AppThemeConfig> getDefaultTheme();
}