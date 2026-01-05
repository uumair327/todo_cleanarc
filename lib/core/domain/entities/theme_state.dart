import 'package:equatable/equatable.dart';
import 'app_theme_config.dart';

/// Represents the current state of the theme system
/// 
/// This entity encapsulates the current theme configuration, available themes,
/// and system theme integration settings.
class ThemeState extends Equatable {
  /// The currently active theme configuration
  final AppThemeConfig currentTheme;
  
  /// List of all available theme configurations
  final List<AppThemeConfig> availableThemes;
  
  /// Whether the app should follow system theme changes
  final bool isSystemThemeEnabled;
  
  /// Whether the theme is currently being changed (for loading states)
  final bool isChangingTheme;
  
  /// Optional error message if theme loading failed
  final String? error;

  const ThemeState({
    required this.currentTheme,
    required this.availableThemes,
    this.isSystemThemeEnabled = true,
    this.isChangingTheme = false,
    this.error,
  });

  /// Creates an initial theme state with default values
  factory ThemeState.initial(AppThemeConfig defaultTheme) {
    return ThemeState(
      currentTheme: defaultTheme,
      availableThemes: [defaultTheme],
      isSystemThemeEnabled: true,
      isChangingTheme: false,
    );
  }

  /// Creates a theme state with an error
  factory ThemeState.error(String error, AppThemeConfig fallbackTheme) {
    return ThemeState(
      currentTheme: fallbackTheme,
      availableThemes: [fallbackTheme],
      isSystemThemeEnabled: true,
      isChangingTheme: false,
      error: error,
    );
  }

  /// Creates a loading state while theme is being changed
  ThemeState toLoading() {
    return ThemeState(
      currentTheme: currentTheme,
      availableThemes: availableThemes,
      isSystemThemeEnabled: isSystemThemeEnabled,
      isChangingTheme: true,
      error: null,
    );
  }

  /// Creates a new state with updated current theme
  ThemeState withCurrentTheme(AppThemeConfig theme) {
    return ThemeState(
      currentTheme: theme,
      availableThemes: availableThemes,
      isSystemThemeEnabled: isSystemThemeEnabled,
      isChangingTheme: false,
      error: null,
    );
  }

  /// Creates a new state with updated available themes
  ThemeState withAvailableThemes(List<AppThemeConfig> themes) {
    return ThemeState(
      currentTheme: currentTheme,
      availableThemes: themes,
      isSystemThemeEnabled: isSystemThemeEnabled,
      isChangingTheme: isChangingTheme,
      error: error,
    );
  }

  /// Creates a new state with updated system theme setting
  ThemeState withSystemThemeEnabled(bool enabled) {
    return ThemeState(
      currentTheme: currentTheme,
      availableThemes: availableThemes,
      isSystemThemeEnabled: enabled,
      isChangingTheme: isChangingTheme,
      error: error,
    );
  }

  /// Creates a new state with an error
  ThemeState withError(String error) {
    return ThemeState(
      currentTheme: currentTheme,
      availableThemes: availableThemes,
      isSystemThemeEnabled: isSystemThemeEnabled,
      isChangingTheme: false,
      error: error,
    );
  }

  /// Finds a theme by name in available themes
  AppThemeConfig? findThemeByName(String name) {
    try {
      return availableThemes.firstWhere((theme) => theme.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a theme with the given name exists
  bool hasTheme(String name) {
    return availableThemes.any((theme) => theme.name == name);
  }

  /// Returns the names of all available themes
  List<String> get availableThemeNames {
    return availableThemes.map((theme) => theme.name).toList();
  }

  /// Returns the system default theme if available
  AppThemeConfig? get systemDefaultTheme {
    try {
      return availableThemes.firstWhere((theme) => theme.isSystemDefault);
    } catch (e) {
      return null;
    }
  }

  /// Checks if the current state has any errors
  bool get hasError => error != null;

  /// Checks if the theme system is in a stable state (not loading, no errors)
  bool get isStable => !isChangingTheme && !hasError;

  @override
  List<Object?> get props => [
    currentTheme,
    availableThemes,
    isSystemThemeEnabled,
    isChangingTheme,
    error,
  ];

  @override
  String toString() => 'ThemeState(current: ${currentTheme.name}, available: ${availableThemes.length}, systemEnabled: $isSystemThemeEnabled, changing: $isChangingTheme, error: $error)';
}