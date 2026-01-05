import 'package:flutter/material.dart';
import '../../utils/typedef.dart';
import '../entities/color_token.dart';
import '../enums/color_enums.dart';

/// Repository interface for color token management and validation
/// 
/// This interface defines the contract for accessing, validating, and managing
/// color tokens in the application's color system.
abstract class ColorRepository {
  /// Retrieves all color tokens for the specified theme mode
  /// 
  /// Returns a map of color token names to their ColorToken definitions.
  /// The tokens returned should be appropriate for the given theme mode.
  ResultFuture<Map<String, ColorToken>> getColorTokens(ThemeMode mode);

  /// Validates that all color tokens meet the required standards
  /// 
  /// This includes checking for:
  /// - Valid color values
  /// - Proper semantic naming
  /// - Required token completeness
  /// - Color role consistency
  ResultVoid validateColorTokens(Map<String, ColorToken> tokens);

  /// Checks if the color combination meets WCAG AA accessibility standards
  /// 
  /// Validates the contrast ratio between foreground and background colors
  /// to ensure they meet accessibility requirements (≥4.5:1 for normal text,
  /// ≥3:1 for large text).
  ResultFuture<bool> checkAccessibilityCompliance(
    ColorToken foreground,
    ColorToken background,
  );

  /// Calculates the contrast ratio between two color tokens
  /// 
  /// Returns the contrast ratio as a double value where higher values
  /// indicate better contrast. Used for accessibility validation.
  ResultFuture<double> calculateContrastRatio(
    ColorToken foreground,
    ColorToken background,
  );

  /// Retrieves a specific color token by name
  /// 
  /// Returns null if the token doesn't exist.
  ResultFuture<ColorToken?> getColorToken(String tokenName, ThemeMode mode);

  /// Checks if a color token exists for the given name and theme mode
  ResultFuture<bool> hasColorToken(String tokenName, ThemeMode mode);

  /// Retrieves all color tokens that match the specified role
  /// 
  /// Useful for finding all surface colors, all text colors, etc.
  ResultFuture<List<ColorToken>> getColorTokensByRole(
    ColorRole role,
    ThemeMode mode,
  );

  /// Validates that required color tokens are present
  /// 
  /// Checks that all tokens in the requiredTokenNames list exist
  /// in the provided token map.
  ResultVoid validateRequiredTokens(
    Map<String, ColorToken> tokens,
    List<String> requiredTokenNames,
  );

  /// Retrieves the default color token registry
  /// 
  /// Returns the built-in color tokens that serve as the foundation
  /// for the application's color system.
  ResultFuture<Map<String, ColorToken>> getDefaultColorTokens();

  /// Validates color token naming conventions
  /// 
  /// Ensures that color token names follow semantic naming patterns
  /// and don't use appearance-based names.
  ResultVoid validateTokenNaming(Map<String, ColorToken> tokens);

  /// Checks for circular dependencies in color token definitions
  /// 
  /// Validates that color tokens don't reference each other in a way
  /// that creates circular dependencies.
  ResultVoid validateTokenDependencies(Map<String, ColorToken> tokens);
}