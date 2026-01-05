import 'package:flutter/material.dart';
import '../domain/value_objects/app_color.dart';
import '../utils/typedef.dart';

/// Abstract service for resolving semantic colors and validating color combinations
/// 
/// This service provides semantic color resolution capabilities and validates
/// color combinations for accessibility compliance.
abstract class ColorResolverService {
  /// Resolves a semantic color by name for the given theme mode
  /// 
  /// Returns the appropriate color value based on the semantic name
  /// and current theme mode (light/dark).
  ResultFuture<AppColor> resolveSemanticColor(String semanticName, ThemeMode mode);
  
  /// Resolves a color by category for the given theme mode
  /// 
  /// Categories include task states like 'ongoing', 'completed', 'canceled'.
  /// Returns the appropriate color for the category and theme mode.
  ResultFuture<AppColor> resolveCategoryColor(String category, ThemeMode mode);
  
  /// Resolves a state color for the given theme mode
  /// 
  /// States include 'success', 'warning', 'error', 'info'.
  /// Returns the appropriate color for the state and theme mode.
  ResultFuture<AppColor> resolveStateColor(String state, ThemeMode mode);
  
  /// Validates that a color combination meets accessibility standards
  /// 
  /// Checks the contrast ratio between foreground and background colors
  /// to ensure WCAG AA compliance (≥4.5:1 for normal text).
  ResultVoid validateColorCombination(AppColor foreground, AppColor background);
  
  /// Resolves the complete color palette for the given theme mode
  /// 
  /// Returns all available colors organized by their semantic names.
  /// Useful for theme previews and color selection interfaces.
  ResultFuture<Map<String, AppColor>> resolveColorPalette(ThemeMode mode);
  
  /// Gets the appropriate "on" color for a surface color
  /// 
  /// Returns the text/content color that should be used on top of
  /// the given surface color for optimal readability.
  ResultFuture<AppColor> resolveOnColor(String surfaceColorName, ThemeMode mode);
  
  /// Resolves opacity variants for a base color
  /// 
  /// Returns pre-defined opacity variants (e.g., 0.1, 0.2, 0.5, 0.8)
  /// instead of calculating them at runtime for better performance.
  ResultFuture<Map<String, AppColor>> resolveOpacityVariants(String colorName, ThemeMode mode);
  
  /// Validates that all required colors are available for a theme mode
  /// 
  /// Ensures that all essential color tokens are present and valid
  /// for the specified theme mode.
  ResultVoid validateColorCompleteness(ThemeMode mode);
  
  /// Clears the color resolution cache
  /// 
  /// Forces fresh resolution of colors on the next request.
  /// Useful when color definitions have been updated.
  void clearCache();
}