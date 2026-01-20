import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../value_objects/app_color.dart';
import '../enums/color_enums.dart';

/// Represents a semantic color token that can have different values for light and dark themes
/// 
/// A ColorToken encapsulates the concept of a semantic color that adapts to different
/// theme modes while maintaining its semantic meaning throughout the application.
class ColorToken extends Equatable {
  /// The semantic name of the color token (e.g., 'surfacePrimary', 'ongoingTask')
  final String name;
  
  /// The color value to use in light theme mode
  final AppColor lightValue;
  
  /// The color value to use in dark theme mode
  final AppColor darkValue;
  
  /// The semantic role this color plays in the design system
  final ColorRole role;

  const ColorToken({
    required this.name,
    required this.lightValue,
    required this.darkValue,
    required this.role,
  });

  /// Returns the appropriate color value for the given theme mode
  AppColor getValueForTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightValue;
      case ThemeMode.dark:
        return darkValue;
      case ThemeMode.system:
        // For system mode, we'll default to light and let the system handle detection
        // This will be properly handled by the theme provider service
        return lightValue;
    }
  }

  /// Returns the appropriate color value for the given brightness
  AppColor getValueForBrightness(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return lightValue;
      case Brightness.dark:
        return darkValue;
    }
  }

  /// Creates a new ColorToken with modified light value
  ColorToken withLightValue(AppColor lightValue) {
    return ColorToken(
      name: name,
      lightValue: lightValue,
      darkValue: darkValue,
      role: role,
    );
  }

  /// Creates a new ColorToken with modified dark value
  ColorToken withDarkValue(AppColor darkValue) {
    return ColorToken(
      name: name,
      lightValue: lightValue,
      darkValue: darkValue,
      role: role,
    );
  }

  /// Creates a new ColorToken with modified role
  ColorToken withRole(ColorRole role) {
    return ColorToken(
      name: name,
      lightValue: lightValue,
      darkValue: darkValue,
      role: role,
    );
  }

  /// Creates a ColorToken with the same color for both light and dark themes
  factory ColorToken.uniform({
    required String name,
    required AppColor color,
    required ColorRole role,
  }) {
    return ColorToken(
      name: name,
      lightValue: color,
      darkValue: color,
      role: role,
    );
  }

  /// Creates a ColorToken from hex values
  factory ColorToken.fromHex({
    required String name,
    required String lightHex,
    required String darkHex,
    required ColorRole role,
  }) {
    return ColorToken(
      name: name,
      lightValue: AppColor.fromHex(lightHex, name),
      darkValue: AppColor.fromHex(darkHex, name),
      role: role,
    );
  }

  @override
  List<Object?> get props => [name, lightValue, darkValue, role];

  @override
  String toString() => 'ColorToken(name: $name, role: $role, light: ${lightValue.toHex()}, dark: ${darkValue.toHex()})';
}