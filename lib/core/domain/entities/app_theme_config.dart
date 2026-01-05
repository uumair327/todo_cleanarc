import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'color_token.dart';

/// Represents a complete theme configuration with all color tokens
/// 
/// This entity encapsulates all the information needed to define a complete
/// theme including its name, mode, color tokens, and system integration settings.
class AppThemeConfig extends Equatable {
  /// The display name of the theme (e.g., 'Light', 'Dark', 'High Contrast')
  final String name;
  
  /// The theme mode this configuration represents
  final ThemeMode mode;
  
  /// Map of color token names to their ColorToken definitions
  final Map<String, ColorToken> colorTokens;
  
  /// Whether this theme should be used as the system default
  final bool isSystemDefault;
  
  /// Optional description of the theme
  final String? description;
  
  /// Version identifier for theme compatibility
  final String version;

  const AppThemeConfig({
    required this.name,
    required this.mode,
    required this.colorTokens,
    this.isSystemDefault = false,
    this.description,
    this.version = '1.0.0',
  });

  /// Gets a color token by name, throws if not found
  ColorToken getColorToken(String tokenName) {
    final token = colorTokens[tokenName];
    if (token == null) {
      throw ArgumentError('Color token "$tokenName" not found in theme "$name"');
    }
    return token;
  }

  /// Gets a color token by name, returns null if not found
  ColorToken? getColorTokenOrNull(String tokenName) {
    return colorTokens[tokenName];
  }

  /// Checks if a color token exists in this theme
  bool hasColorToken(String tokenName) {
    return colorTokens.containsKey(tokenName);
  }

  /// Returns all color token names in this theme
  List<String> get colorTokenNames => colorTokens.keys.toList();

  /// Returns the number of color tokens in this theme
  int get colorTokenCount => colorTokens.length;

  /// Creates a new AppThemeConfig with additional color tokens
  AppThemeConfig withAdditionalTokens(Map<String, ColorToken> additionalTokens) {
    final newTokens = Map<String, ColorToken>.from(colorTokens);
    newTokens.addAll(additionalTokens);
    
    return AppThemeConfig(
      name: name,
      mode: mode,
      colorTokens: newTokens,
      isSystemDefault: isSystemDefault,
      description: description,
      version: version,
    );
  }

  /// Creates a new AppThemeConfig with a modified token
  AppThemeConfig withUpdatedToken(String tokenName, ColorToken token) {
    final newTokens = Map<String, ColorToken>.from(colorTokens);
    newTokens[tokenName] = token;
    
    return AppThemeConfig(
      name: name,
      mode: mode,
      colorTokens: newTokens,
      isSystemDefault: isSystemDefault,
      description: description,
      version: version,
    );
  }

  /// Creates a new AppThemeConfig with modified system default setting
  AppThemeConfig withSystemDefault(bool isSystemDefault) {
    return AppThemeConfig(
      name: name,
      mode: mode,
      colorTokens: colorTokens,
      isSystemDefault: isSystemDefault,
      description: description,
      version: version,
    );
  }

  /// Creates a new AppThemeConfig with modified description
  AppThemeConfig withDescription(String? description) {
    return AppThemeConfig(
      name: name,
      mode: mode,
      colorTokens: colorTokens,
      isSystemDefault: isSystemDefault,
      description: description,
      version: version,
    );
  }

  /// Validates that all required color tokens are present
  bool validateRequiredTokens(List<String> requiredTokenNames) {
    return requiredTokenNames.every((tokenName) => hasColorToken(tokenName));
  }

  /// Returns a list of missing required tokens
  List<String> getMissingTokens(List<String> requiredTokenNames) {
    return requiredTokenNames.where((tokenName) => !hasColorToken(tokenName)).toList();
  }

  @override
  List<Object?> get props => [name, mode, colorTokens, isSystemDefault, description, version];

  @override
  String toString() => 'AppThemeConfig(name: $name, mode: $mode, tokens: $colorTokenCount, isSystemDefault: $isSystemDefault)';
}