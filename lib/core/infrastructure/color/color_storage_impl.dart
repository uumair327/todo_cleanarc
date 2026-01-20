import 'dart:math' as dart_math;
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/color_token.dart';
import '../../domain/enums/color_enums.dart';
import '../../domain/repositories/color_repository.dart';
import '../../domain/value_objects/app_color.dart';
import '../../error/failures.dart';
import '../../utils/typedef.dart';
import 'color_token_registry.dart';

/// Implementation of ColorRepository that provides predefined color tokens
/// and validates accessibility compliance according to WCAG AA standards.
class ColorStorageImpl implements ColorRepository {
  final ColorTokenRegistry _registry = ColorTokenRegistry();

  @override
  ResultFuture<Map<String, ColorToken>> getColorTokens(ThemeMode mode) async {
    try {
      return Right(_registry.getAllTokens());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load color tokens: $e'));
    }
  }

  @override
  ResultVoid validateColorTokens(Map<String, ColorToken> tokens) async {
    try {
      // Check for required tokens
      final requiredTokens = [
        'surfacePrimary',
        'surfaceSecondary',
        'surfaceTertiary',
        'ongoingTask',
        'inProcessTask',
        'completedTask',
        'canceledTask',
        'successBackground',
        'warningBackground',
        'errorBackground',
        'infoBackground',
      ];

      for (final tokenName in requiredTokens) {
        if (!tokens.containsKey(tokenName)) {
          return Left(ValidationFailure('Missing required color token: $tokenName'));
        }
      }

      // Validate semantic naming
      final result = await validateTokenNaming(tokens);
      if (result.isLeft()) {
        return result;
      }

      // Validate token dependencies
      return await validateTokenDependencies(tokens);
    } catch (e) {
      return Left(ValidationFailure('Color token validation failed: $e'));
    }
  }

  @override
  ResultFuture<bool> checkAccessibilityCompliance(
    ColorToken foreground,
    ColorToken background,
  ) async {
    try {
      final contrastResult = await calculateContrastRatio(foreground, background);
      return contrastResult.fold(
        (failure) => Left(failure),
        (ratio) => Right(ratio >= 4.5), // WCAG AA standard for normal text
      );
    } catch (e) {
      return Left(ValidationFailure('Accessibility compliance check failed: $e'));
    }
  }

  @override
  ResultFuture<double> calculateContrastRatio(
    ColorToken foreground,
    ColorToken background,
  ) async {
    try {
      // Calculate for light theme (we can extend this for dark theme if needed)
      final fgColor = foreground.lightValue;
      final bgColor = background.lightValue;

      final fgLuminance = _calculateRelativeLuminance(fgColor);
      final bgLuminance = _calculateRelativeLuminance(bgColor);

      // Ensure the lighter color is in the numerator
      final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
      final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

      final ratio = (lighter + 0.05) / (darker + 0.05);
      return Right(ratio);
    } catch (e) {
      return Left(ValidationFailure('Contrast ratio calculation failed: $e'));
    }
  }

  @override
  ResultFuture<ColorToken?> getColorToken(String tokenName, ThemeMode mode) async {
    try {
      final token = _registry.getToken(tokenName);
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get color token $tokenName: $e'));
    }
  }

  @override
  ResultFuture<bool> hasColorToken(String tokenName, ThemeMode mode) async {
    try {
      final hasToken = _registry.hasToken(tokenName);
      return Right(hasToken);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check color token existence: $e'));
    }
  }

  @override
  ResultFuture<List<ColorToken>> getColorTokensByRole(
    ColorRole role,
    ThemeMode mode,
  ) async {
    try {
      final tokens = _registry.getTokensByRole(role);
      return Right(tokens);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get color tokens by role: $e'));
    }
  }

  @override
  ResultVoid validateRequiredTokens(
    Map<String, ColorToken> tokens,
    List<String> requiredTokenNames,
  ) async {
    try {
      for (final tokenName in requiredTokenNames) {
        if (!tokens.containsKey(tokenName)) {
          return Left(ValidationFailure('Missing required color token: $tokenName'));
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Required token validation failed: $e'));
    }
  }

  @override
  ResultFuture<Map<String, ColorToken>> getDefaultColorTokens() async {
    try {
      return Right(_registry.getAllTokens());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get default color tokens: $e'));
    }
  }

  @override
  ResultVoid validateTokenNaming(Map<String, ColorToken> tokens) async {
    try {
      final invalidNames = <String>[];
      
      // Check for appearance-based names that should be avoided
      final forbiddenPatterns = [
        'white', 'black', 'red', 'green', 'blue', 'yellow', 'purple', 'orange',
        'light', 'dark', 'bright', 'pale', 'deep'
      ];

      for (final entry in tokens.entries) {
        final tokenName = entry.key.toLowerCase();
        for (final pattern in forbiddenPatterns) {
          if (tokenName.contains(pattern)) {
            invalidNames.add(entry.key);
            break;
          }
        }
      }

      if (invalidNames.isNotEmpty) {
        return Left(ValidationFailure(
          'Color tokens use appearance-based names instead of semantic names: ${invalidNames.join(', ')}'
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Token naming validation failed: $e'));
    }
  }

  @override
  ResultVoid validateTokenDependencies(Map<String, ColorToken> tokens) async {
    try {
      // For now, we don't have circular dependencies in our token system
      // This is a placeholder for future complex token relationships
      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Token dependency validation failed: $e'));
    }
  }

  /// Calculates the relative luminance of a color according to WCAG guidelines
  double _calculateRelativeLuminance(AppColor color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearizes a color component for luminance calculation
  double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return ((component + 0.055) / 1.055).pow(2.4);
    }
  }
}

/// Extension to add pow method to double
extension DoubleExtension on double {
  double pow(double exponent) {
    return dart_math.pow(this, exponent).toDouble();
  }
}