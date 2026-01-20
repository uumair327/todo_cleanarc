import 'package:flutter/material.dart';
import 'app_color_extension.dart';

/// Extension on BuildContext to provide easy access to semantic colors
/// 
/// This extension provides type-safe, convenient access to all semantic colors
/// defined in the AppColorExtension, ensuring that widgets can access colors
/// without directly depending on the theme system implementation.
extension BuildContextColorExtension on BuildContext {
  /// Gets the AppColorExtension from the current theme
  /// 
  /// Throws an exception if AppColorExtension is not found in the theme,
  /// which indicates a configuration error in the theme setup.
  AppColorExtension get appColors {
    final extension = Theme.of(this).extension<AppColorExtension>();
    if (extension == null) {
      throw StateError(
        'AppColorExtension not found in theme. '
        'Make sure AppColorExtension is added to ThemeData.extensions.'
      );
    }
    return extension;
  }

  /// Gets the Material 3 ColorScheme from the current theme
  /// 
  /// Provides access to standard Material 3 colors that are automatically
  /// generated from the semantic color system.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the current theme's brightness
  Brightness get brightness => Theme.of(this).brightness;

  /// Checks if the current theme is dark mode
  bool get isDarkMode => brightness == Brightness.dark;

  /// Checks if the current theme is light mode
  bool get isLightMode => brightness == Brightness.light;

  // Convenience getters for commonly used surface colors

  /// Primary surface color - main background color
  Color get surfacePrimary => appColors.surfacePrimary.toFlutterColor();

  /// Secondary surface color - elevated surfaces
  Color get surfaceSecondary => appColors.surfaceSecondary.toFlutterColor();

  /// Tertiary surface color - highest elevation surfaces
  Color get surfaceTertiary => appColors.surfaceTertiary.toFlutterColor();

  /// Primary text color on surfaces
  Color get onSurfacePrimary => appColors.onSurfacePrimary.toFlutterColor();

  /// Secondary text color on surfaces (lower emphasis)
  Color get onSurfaceSecondary => appColors.onSurfaceSecondary.toFlutterColor();

  // Convenience getters for task category colors

  /// Color for ongoing tasks
  Color get ongoingTaskColor => appColors.ongoingTask.toFlutterColor();

  /// Color for in-process tasks
  Color get inProcessTaskColor => appColors.inProcessTask.toFlutterColor();

  /// Color for completed tasks
  Color get completedTaskColor => appColors.completedTask.toFlutterColor();

  /// Color for canceled tasks
  Color get canceledTaskColor => appColors.canceledTask.toFlutterColor();

  /// Text color for ongoing task backgrounds
  Color get onOngoingTaskColor => appColors.onOngoingTask.toFlutterColor();

  /// Text color for in-process task backgrounds
  Color get onInProcessTaskColor => appColors.onInProcessTask.toFlutterColor();

  /// Text color for completed task backgrounds
  Color get onCompletedTaskColor => appColors.onCompletedTask.toFlutterColor();

  /// Text color for canceled task backgrounds
  Color get onCanceledTaskColor => appColors.onCanceledTask.toFlutterColor();

  // Convenience getters for state background colors

  /// Success state background color
  Color get successBackground => appColors.successBackground.toFlutterColor();

  /// Warning state background color
  Color get warningBackground => appColors.warningBackground.toFlutterColor();

  /// Error state background color
  Color get errorBackground => appColors.errorBackground.toFlutterColor();

  /// Info state background color
  Color get infoBackground => appColors.infoBackground.toFlutterColor();

  /// Text color for success backgrounds
  Color get onSuccessBackground => appColors.onSuccessBackground.toFlutterColor();

  /// Text color for warning backgrounds
  Color get onWarningBackground => appColors.onWarningBackground.toFlutterColor();

  /// Text color for error backgrounds
  Color get onErrorBackground => appColors.onErrorBackground.toFlutterColor();

  /// Text color for info backgrounds
  Color get onInfoBackground => appColors.onInfoBackground.toFlutterColor();

  // Convenience getters for opacity variants

  /// Surface primary with 50% opacity
  Color get surfacePrimaryOpacity50 => appColors.surfacePrimaryOpacity50.toFlutterColor();

  /// Surface primary with 75% opacity
  Color get surfacePrimaryOpacity75 => appColors.surfacePrimaryOpacity75.toFlutterColor();

  /// On surface primary with 60% opacity
  Color get onSurfacePrimaryOpacity60 => appColors.onSurfacePrimaryOpacity60.toFlutterColor();

  /// On surface primary with 40% opacity
  Color get onSurfacePrimaryOpacity40 => appColors.onSurfacePrimaryOpacity40.toFlutterColor();

  // Convenience methods for dynamic color selection

  /// Gets task category color by status string
  /// 
  /// Supports: 'ongoing', 'inprocess', 'in_process', 'completed', 'canceled', 'cancelled'
  /// Returns ongoing task color as fallback for unknown statuses.
  Color getTaskCategoryColor(String taskStatus) {
    return appColors.getTaskCategoryColor(taskStatus).toFlutterColor();
  }

  /// Gets text color for task category by status string
  /// 
  /// Supports: 'ongoing', 'inprocess', 'in_process', 'completed', 'canceled', 'cancelled'
  /// Returns on ongoing task color as fallback for unknown statuses.
  Color getOnTaskCategoryColor(String taskStatus) {
    return appColors.getOnTaskCategoryColor(taskStatus).toFlutterColor();
  }

  /// Gets state background color by state string
  /// 
  /// Supports: 'success', 'warning', 'error', 'info'
  /// Returns info background color as fallback for unknown states.
  Color getStateBackgroundColor(String state) {
    return appColors.getStateBackgroundColor(state).toFlutterColor();
  }

  /// Gets text color for state background by state string
  /// 
  /// Supports: 'success', 'warning', 'error', 'info'
  /// Returns on info background color as fallback for unknown states.
  Color getOnStateBackgroundColor(String state) {
    return appColors.getOnStateBackgroundColor(state).toFlutterColor();
  }

  // Utility methods for color combinations

  /// Gets a color pair (background, foreground) for task categories
  /// 
  /// Returns a record with background and text colors for the specified task status.
  ({Color background, Color text}) getTaskColorPair(String taskStatus) {
    return (
      background: getTaskCategoryColor(taskStatus),
      text: getOnTaskCategoryColor(taskStatus),
    );
  }

  /// Gets a color pair (background, foreground) for state indicators
  /// 
  /// Returns a record with background and text colors for the specified state.
  ({Color background, Color text}) getStateColorPair(String state) {
    return (
      background: getStateBackgroundColor(state),
      text: getOnStateBackgroundColor(state),
    );
  }

  /// Gets appropriate text color for any given background color
  /// 
  /// This method calculates the relative luminance of the background color
  /// and returns either light or dark text for optimal contrast.
  Color getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    
    // Use dark text on light backgrounds, light text on dark backgrounds
    if (luminance > 0.5) {
      return onSurfacePrimary;
    } else {
      return surfacePrimary;
    }
  }

  /// Checks if the current color combination meets accessibility standards
  /// 
  /// Returns true if the contrast ratio between foreground and background
  /// meets WCAG AA standards (4.5:1 for normal text, 3:1 for large text).
  bool isAccessibleColorCombination(Color foreground, Color background, {bool isLargeText = false}) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    
    // Calculate contrast ratio
    final lighter = foregroundLuminance > backgroundLuminance ? foregroundLuminance : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance ? backgroundLuminance : foregroundLuminance;
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // Check against WCAG AA standards
    final requiredRatio = isLargeText ? 3.0 : 4.5;
    return contrastRatio >= requiredRatio;
  }
}