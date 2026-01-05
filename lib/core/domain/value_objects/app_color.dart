import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A value object representing a color with semantic meaning in the application
/// 
/// This class encapsulates color values with their semantic names and opacity,
/// providing a type-safe way to work with colors throughout the application.
class AppColor extends Equatable {
  /// The ARGB color value
  final int value;
  
  /// The semantic name describing the color's purpose
  final String semanticName;
  
  /// The opacity level (0.0 to 1.0)
  final double opacity;

  const AppColor({
    required this.value,
    required this.semanticName,
    this.opacity = 1.0,
  }) : assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');

  /// Creates a new AppColor with the specified opacity
  AppColor withOpacity(double opacity) {
    return AppColor(
      value: value,
      semanticName: semanticName,
      opacity: opacity,
    );
  }

  /// Creates a new AppColor with a modified semantic name
  AppColor withSemanticName(String semanticName) {
    return AppColor(
      value: value,
      semanticName: semanticName,
      opacity: opacity,
    );
  }

  /// Converts this AppColor to a Flutter Color object
  Color toFlutterColor() {
    if (opacity == 1.0) {
      return Color(value);
    }
    return Color(value).withValues(alpha: opacity);
  }

  /// Creates an AppColor from a Flutter Color
  factory AppColor.fromFlutterColor(Color color, String semanticName) {
    // Extract ARGB components and reconstruct the value
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final value = (a << 24) | (r << 16) | (g << 8) | b;
    
    return AppColor(
      value: value,
      semanticName: semanticName,
      opacity: color.a,
    );
  }

  /// Creates an AppColor from a hex string
  factory AppColor.fromHex(String hex, String semanticName, {double opacity = 1.0}) {
    // Remove # if present
    hex = hex.replaceAll('#', '');
    
    // Add alpha channel if not present
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    
    final value = int.parse(hex, radix: 16);
    return AppColor(
      value: value,
      semanticName: semanticName,
      opacity: opacity,
    );
  }

  /// Returns the hex representation of this color
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Returns the RGB values as a map
  Map<String, int> toRgb() {
    return {
      'r': (value >> 16) & 0xFF,
      'g': (value >> 8) & 0xFF,
      'b': value & 0xFF,
    };
  }

  /// Returns the alpha value (0-255)
  int get alpha => (value >> 24) & 0xFF;

  /// Returns the red value (0-255)
  int get red => (value >> 16) & 0xFF;

  /// Returns the green value (0-255)
  int get green => (value >> 8) & 0xFF;

  /// Returns the blue value (0-255)
  int get blue => value & 0xFF;

  @override
  List<Object?> get props => [value, semanticName, opacity];

  @override
  String toString() => 'AppColor(semanticName: $semanticName, value: ${toHex()}, opacity: $opacity)';
}