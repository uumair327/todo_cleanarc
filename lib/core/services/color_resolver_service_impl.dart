import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../domain/entities/color_token.dart';
import '../domain/enums/color_enums.dart';
import '../domain/repositories/color_repository.dart';
import '../domain/value_objects/app_color.dart';
import '../error/failures.dart';
import '../utils/typedef.dart';
import 'color_resolver_service.dart';

/// Implementation of ColorResolverService with caching and validation
/// 
/// This service provides semantic color resolution with performance optimizations
/// through caching and comprehensive validation for accessibility compliance.
class ColorResolverServiceImpl implements ColorResolverService {
  final ColorRepository _colorRepository;
  
  // Caching for performance optimization
  final Map<String, Map<String, AppColor>> _semanticColorCache = {};
  final Map<String, Map<String, AppColor>> _categoryColorCache = {};
  final Map<String, Map<String, AppColor>> _stateColorCache = {};
  final Map<String, Map<String, AppColor>> _paletteCache = {};
  final Map<String, Map<String, Map<String, AppColor>>> _opacityVariantsCache = {};
  
  // Color combination validation cache
  final Map<String, bool> _validationCache = {};

  ColorResolverServiceImpl({
    required ColorRepository colorRepository,
  }) : _colorRepository = colorRepository;

  @override
  ResultFuture<AppColor> resolveSemanticColor(String semanticName, ThemeMode mode) async {
    try {
      final cacheKey = _getCacheKey(mode);
      
      // Check cache first
      final cachedColor = _semanticColorCache[cacheKey]?[semanticName];
      if (cachedColor != null) {
        return Right(cachedColor);
      }

      // Get color token from repository
      final tokenResult = await _colorRepository.getColorToken(semanticName, mode);
      return tokenResult.fold(
        (failure) => Left(failure),
        (token) {
          if (token == null) {
            return Left(ValidationFailure('Semantic color "$semanticName" not found'));
          }
          
          final resolvedColor = token.getValueForTheme(mode);
          
          // Cache the resolved color
          _cacheSemanticColor(cacheKey, semanticName, resolvedColor);
          
          return Right(resolvedColor);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve semantic color: $e'));
    }
  }

  @override
  ResultFuture<AppColor> resolveCategoryColor(String category, ThemeMode mode) async {
    try {
      final cacheKey = _getCacheKey(mode);
      
      // Check cache first
      final cachedColor = _categoryColorCache[cacheKey]?[category];
      if (cachedColor != null) {
        return Right(cachedColor);
      }

      // Map category names to token names
      final categoryTokenMap = {
        'ongoing': 'ongoingTask',
        'inProcess': 'inProcessTask',
        'completed': 'completedTask',
        'canceled': 'canceledTask',
      };

      final tokenName = categoryTokenMap[category];
      if (tokenName == null) {
        return Left(ValidationFailure('Unknown category: $category'));
      }

      // Resolve the color using semantic resolution
      final colorResult = await resolveSemanticColor(tokenName, mode);
      return colorResult.fold(
        (failure) => Left(failure),
        (color) {
          // Cache the category color
          _cacheCategoryColor(cacheKey, category, color);
          return Right(color);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve category color: $e'));
    }
  }

  @override
  ResultFuture<AppColor> resolveStateColor(String state, ThemeMode mode) async {
    try {
      final cacheKey = _getCacheKey(mode);
      
      // Check cache first
      final cachedColor = _stateColorCache[cacheKey]?[state];
      if (cachedColor != null) {
        return Right(cachedColor);
      }

      // Map state names to token names
      final stateTokenMap = {
        'success': 'successBackground',
        'warning': 'warningBackground',
        'error': 'errorBackground',
        'info': 'infoBackground',
      };

      final tokenName = stateTokenMap[state];
      if (tokenName == null) {
        return Left(ValidationFailure('Unknown state: $state'));
      }

      // Resolve the color using semantic resolution
      final colorResult = await resolveSemanticColor(tokenName, mode);
      return colorResult.fold(
        (failure) => Left(failure),
        (color) {
          // Cache the state color
          _cacheStateColor(cacheKey, state, color);
          return Right(color);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve state color: $e'));
    }
  }

  @override
  ResultVoid validateColorCombination(AppColor foreground, AppColor background) async {
    try {
      final validationKey = '${foreground.toHex()}_${background.toHex()}';
      
      // Check validation cache first
      final cachedResult = _validationCache[validationKey];
      if (cachedResult != null) {
        return cachedResult 
          ? const Right(null) 
          : Left(ValidationFailure('Color combination fails accessibility standards'));
      }

      // Create temporary color tokens for validation
      final fgToken = ColorToken.uniform(
        name: 'temp_fg',
        color: foreground,
        role: ColorRole.onSurface,
      );
      
      final bgToken = ColorToken.uniform(
        name: 'temp_bg',
        color: background,
        role: ColorRole.surface,
      );

      // Check accessibility compliance
      final complianceResult = await _colorRepository.checkAccessibilityCompliance(fgToken, bgToken);
      return complianceResult.fold(
        (failure) => Left(failure),
        (isCompliant) {
          // Cache the validation result
          _validationCache[validationKey] = isCompliant;
          
          return isCompliant 
            ? const Right(null)
            : Left(ValidationFailure('Color combination fails WCAG AA accessibility standards'));
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Color combination validation failed: $e'));
    }
  }

  @override
  ResultFuture<Map<String, AppColor>> resolveColorPalette(ThemeMode mode) async {
    try {
      final cacheKey = _getCacheKey(mode);
      
      // Check cache first
      final cachedPalette = _paletteCache[cacheKey];
      if (cachedPalette != null) {
        return Right(Map.from(cachedPalette));
      }

      // Get all color tokens from repository
      final tokensResult = await _colorRepository.getColorTokens(mode);
      return tokensResult.fold(
        (failure) => Left(failure),
        (tokens) {
          final palette = <String, AppColor>{};
          
          // Resolve all tokens to colors
          for (final entry in tokens.entries) {
            palette[entry.key] = entry.value.getValueForTheme(mode);
          }
          
          // Cache the palette
          _paletteCache[cacheKey] = palette;
          
          return Right(palette);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve color palette: $e'));
    }
  }

  @override
  ResultFuture<AppColor> resolveOnColor(String surfaceColorName, ThemeMode mode) async {
    try {
      // Map surface colors to their "on" variants
      final onColorMap = {
        'surfacePrimary': 'onSurfacePrimary',
        'surfaceSecondary': 'onSurfaceSecondary',
        'surfaceTertiary': 'onSurfaceTertiary',
        'successBackground': 'onSuccessBackground',
        'warningBackground': 'onWarningBackground',
        'errorBackground': 'onErrorBackground',
        'infoBackground': 'onInfoBackground',
      };

      final onColorName = onColorMap[surfaceColorName];
      if (onColorName != null) {
        return await resolveSemanticColor(onColorName, mode);
      }

      // If no specific "on" color exists, calculate a contrasting color
      final surfaceColorResult = await resolveSemanticColor(surfaceColorName, mode);
      return surfaceColorResult.fold(
        (failure) => Left(failure),
        (surfaceColor) {
          final contrastingColor = _calculateContrastingColor(surfaceColor);
          return Right(contrastingColor);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve on color: $e'));
    }
  }

  @override
  ResultFuture<Map<String, AppColor>> resolveOpacityVariants(String colorName, ThemeMode mode) async {
    try {
      final cacheKey = _getCacheKey(mode);
      
      // Check cache first
      final cachedVariants = _opacityVariantsCache[cacheKey]?[colorName];
      if (cachedVariants != null) {
        return Right(Map.from(cachedVariants));
      }

      // Get the base color
      final baseColorResult = await resolveSemanticColor(colorName, mode);
      return baseColorResult.fold(
        (failure) => Left(failure),
        (baseColor) {
          final variants = <String, AppColor>{};
          
          // Pre-defined opacity levels for performance
          final opacityLevels = {
            'opacity10': 0.1,
            'opacity20': 0.2,
            'opacity30': 0.3,
            'opacity50': 0.5,
            'opacity70': 0.7,
            'opacity80': 0.8,
            'opacity90': 0.9,
          };

          for (final entry in opacityLevels.entries) {
            variants[entry.key] = baseColor.withOpacity(entry.value);
          }
          
          // Cache the variants
          _cacheOpacityVariants(cacheKey, colorName, variants);
          
          return Right(variants);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resolve opacity variants: $e'));
    }
  }

  @override
  ResultVoid validateColorCompleteness(ThemeMode mode) async {
    try {
      // Define required color tokens for completeness
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

      // Get all available tokens
      final tokensResult = await _colorRepository.getColorTokens(mode);
      return tokensResult.fold(
        (failure) => Left(failure),
        (tokens) async {
          // Validate that all required tokens are present
          final validationResult = await _colorRepository.validateRequiredTokens(tokens, requiredTokens);
          if (validationResult.isLeft()) {
            return validationResult;
          }

          // Validate token naming conventions
          final namingResult = await _colorRepository.validateTokenNaming(tokens);
          if (namingResult.isLeft()) {
            return namingResult;
          }

          // Validate token dependencies
          return await _colorRepository.validateTokenDependencies(tokens);
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Color completeness validation failed: $e'));
    }
  }

  @override
  void clearCache() {
    _semanticColorCache.clear();
    _categoryColorCache.clear();
    _stateColorCache.clear();
    _paletteCache.clear();
    _opacityVariantsCache.clear();
    _validationCache.clear();
  }

  /// Gets the cache key for a theme mode
  String _getCacheKey(ThemeMode mode) {
    return mode.name;
  }

  /// Caches a semantic color
  void _cacheSemanticColor(String cacheKey, String semanticName, AppColor color) {
    _semanticColorCache[cacheKey] ??= {};
    _semanticColorCache[cacheKey]![semanticName] = color;
  }

  /// Caches a category color
  void _cacheCategoryColor(String cacheKey, String category, AppColor color) {
    _categoryColorCache[cacheKey] ??= {};
    _categoryColorCache[cacheKey]![category] = color;
  }

  /// Caches a state color
  void _cacheStateColor(String cacheKey, String state, AppColor color) {
    _stateColorCache[cacheKey] ??= {};
    _stateColorCache[cacheKey]![state] = color;
  }

  /// Caches opacity variants for a color
  void _cacheOpacityVariants(String cacheKey, String colorName, Map<String, AppColor> variants) {
    _opacityVariantsCache[cacheKey] ??= {};
    _opacityVariantsCache[cacheKey]![colorName] = variants;
  }

  /// Calculates a contrasting color for the given color
  AppColor _calculateContrastingColor(AppColor color) {
    // Calculate relative luminance to determine if we need light or dark text
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    
    // Use dark text on light surfaces, light text on dark surfaces
    if (luminance > 0.5) {
      return AppColor.fromHex('#000000', 'contrastingText');
    } else {
      return AppColor.fromHex('#FFFFFF', 'contrastingText');
    }
  }
}