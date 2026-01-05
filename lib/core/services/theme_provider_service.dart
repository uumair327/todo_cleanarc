import 'dart:async';
import '../domain/entities/app_theme_config.dart';
import '../domain/entities/theme_state.dart';
import '../domain/value_objects/app_color.dart';
import '../utils/typedef.dart';

/// Abstract service for providing theme-aware colors and managing theme state
/// 
/// This service acts as the central point for theme management, providing
/// colors through dependency injection and handling theme change notifications.
abstract class ThemeProviderService {
  /// Stream of theme state changes
  Stream<ThemeState> get themeStream;
  
  /// Current theme state
  ThemeState get currentTheme;
  
  /// Sets the active theme by name
  /// 
  /// Validates the theme exists and updates the current theme state.
  /// Notifies all listeners of the theme change.
  ResultVoid setTheme(String themeName);
  
  /// Toggles system theme following on/off
  /// 
  /// When enabled, the app will automatically switch between light/dark
  /// themes based on system settings.
  ResultVoid toggleSystemTheme(bool enabled);
  
  /// Adds a new custom theme to the available themes
  /// 
  /// Validates the theme configuration before adding it to the system.
  ResultVoid addCustomTheme(AppThemeConfig theme);
  
  /// Gets a color by its semantic token name
  /// 
  /// Returns the appropriate color for the current theme mode.
  /// Throws an exception if the color token doesn't exist.
  AppColor getColor(String tokenName);
  
  /// Gets the appropriate text color for a surface
  /// 
  /// Returns the "on" color variant for the given surface token.
  /// For example, for 'surfacePrimary' returns the appropriate text color.
  AppColor getOnColor(String surfaceTokenName);
  
  /// Gets all colors for the current theme
  /// 
  /// Returns a map of all color token names to their resolved colors.
  Map<String, AppColor> getAllColors();
  
  /// Initializes the theme provider service
  /// 
  /// Must be called before using other methods. Loads the current theme
  /// and sets up system theme watching if enabled.
  ResultVoid initialize();
  
  /// Disposes of resources used by the service
  /// 
  /// Closes streams and cancels subscriptions.
  void dispose();
}