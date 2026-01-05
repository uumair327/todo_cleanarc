import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../domain/entities/app_theme_config.dart';
import '../domain/entities/theme_state.dart';
import '../domain/repositories/theme_repository.dart';
import '../domain/value_objects/app_color.dart';
import '../error/failures.dart';
import '../utils/typedef.dart';
import 'theme_provider_service.dart';

/// Implementation of ThemeProviderService with dependency injection and caching
/// 
/// This service manages theme state, provides colors through dependency injection,
/// and implements performance optimizations through caching.
class ThemeProviderServiceImpl implements ThemeProviderService {
  final ThemeRepository _themeRepository;
  
  // Theme state management
  final StreamController<ThemeState> _themeController = StreamController<ThemeState>.broadcast();
  ThemeState _currentThemeState;
  
  // System theme watching
  StreamSubscription<ThemeMode>? _systemThemeSubscription;
  
  // Color caching for performance
  final Map<String, Map<String, AppColor>> _colorCache = {};
  
  // Initialization state
  bool _initialized = false;

  ThemeProviderServiceImpl({
    required ThemeRepository themeRepository,
    required AppThemeConfig initialTheme,
  })  : _themeRepository = themeRepository,
        _currentThemeState = ThemeState.initial(initialTheme);

  @override
  Stream<ThemeState> get themeStream => _themeController.stream;

  @override
  ThemeState get currentTheme => _currentThemeState;

  @override
  ResultVoid initialize() async {
    try {
      if (_initialized) {
        return const Right(null);
      }

      // Load current theme state from repository
      final themeStateResult = await _themeRepository.getThemeState();
      await themeStateResult.fold(
        (failure) async {
          // If loading fails, use default theme
          final defaultThemeResult = await _themeRepository.getDefaultTheme();
          await defaultThemeResult.fold(
            (failure) async => Left(failure),
            (defaultTheme) async {
              _currentThemeState = ThemeState.initial(defaultTheme);
              return const Right(null);
            },
          );
        },
        (themeState) async {
          _currentThemeState = themeState;
          return const Right(null);
        },
      );

      // Set up system theme watching if enabled
      if (_currentThemeState.isSystemThemeEnabled) {
        await _setupSystemThemeWatching();
      }

      // Pre-populate color cache for current theme
      await _populateColorCache(_currentThemeState.currentTheme.mode);

      _initialized = true;
      _themeController.add(_currentThemeState);
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to initialize theme provider: $e'));
    }
  }

  @override
  ResultVoid setTheme(String themeName) async {
    try {
      _ensureInitialized();

      // Find the theme in available themes
      final theme = _currentThemeState.findThemeByName(themeName);
      if (theme == null) {
        return Left(ValidationFailure('Theme "$themeName" not found'));
      }

      // Update theme state to loading
      _currentThemeState = _currentThemeState.toLoading();
      _themeController.add(_currentThemeState);

      // Validate the theme
      final validationResult = await _themeRepository.validateTheme(theme);
      if (validationResult.isLeft()) {
        _currentThemeState = _currentThemeState.withError('Theme validation failed');
        _themeController.add(_currentThemeState);
        return validationResult;
      }

      // Save the theme
      final saveResult = await _themeRepository.saveTheme(theme);
      if (saveResult.isLeft()) {
        _currentThemeState = _currentThemeState.withError('Failed to save theme');
        _themeController.add(_currentThemeState);
        return saveResult;
      }

      // Update current theme state
      _currentThemeState = _currentThemeState.withCurrentTheme(theme);
      
      // Clear and repopulate color cache for new theme
      _clearColorCache();
      await _populateColorCache(theme.mode);

      // Set up or tear down system theme watching based on theme mode
      if (theme.mode == ThemeMode.system && _currentThemeState.isSystemThemeEnabled) {
        await _setupSystemThemeWatching();
      } else {
        await _tearDownSystemThemeWatching();
      }

      _themeController.add(_currentThemeState);
      return const Right(null);
    } catch (e) {
      _currentThemeState = _currentThemeState.withError('Failed to set theme: $e');
      _themeController.add(_currentThemeState);
      return Left(CacheFailure(message: 'Failed to set theme: $e'));
    }
  }

  @override
  ResultVoid toggleSystemTheme(bool enabled) async {
    try {
      _ensureInitialized();

      // Save system theme preference
      final saveResult = await _themeRepository.setSystemThemeEnabled(enabled);
      if (saveResult.isLeft()) {
        return saveResult;
      }

      // Update theme state
      _currentThemeState = _currentThemeState.withSystemThemeEnabled(enabled);

      // Set up or tear down system theme watching
      if (enabled && _currentThemeState.currentTheme.mode == ThemeMode.system) {
        await _setupSystemThemeWatching();
      } else {
        await _tearDownSystemThemeWatching();
      }

      _themeController.add(_currentThemeState);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to toggle system theme: $e'));
    }
  }

  @override
  ResultVoid addCustomTheme(AppThemeConfig theme) async {
    try {
      _ensureInitialized();

      // Validate the theme
      final validationResult = await _themeRepository.validateTheme(theme);
      if (validationResult.isLeft()) {
        return validationResult;
      }

      // Add the theme to repository
      final addResult = await _themeRepository.addCustomTheme(theme);
      if (addResult.isLeft()) {
        return addResult;
      }

      // Update available themes in current state
      final availableThemesResult = await _themeRepository.getAvailableThemes();
      return availableThemesResult.fold(
        (failure) => Left(failure),
        (availableThemes) {
          _currentThemeState = _currentThemeState.withAvailableThemes(availableThemes);
          _themeController.add(_currentThemeState);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add custom theme: $e'));
    }
  }

  @override
  AppColor getColor(String tokenName) {
    _ensureInitialized();

    final themeMode = _currentThemeState.currentTheme.mode;
    final cacheKey = _getCacheKey(themeMode);
    
    // Try to get from cache first
    final cachedColor = _colorCache[cacheKey]?[tokenName];
    if (cachedColor != null) {
      return cachedColor;
    }

    // Get from theme configuration
    final colorToken = _currentThemeState.currentTheme.getColorTokenOrNull(tokenName);
    if (colorToken == null) {
      throw ArgumentError('Color token "$tokenName" not found in current theme');
    }

    final resolvedColor = colorToken.getValueForTheme(themeMode);
    
    // Cache the resolved color
    _cacheColor(cacheKey, tokenName, resolvedColor);
    
    return resolvedColor;
  }

  @override
  AppColor getOnColor(String surfaceTokenName) {
    _ensureInitialized();

    // Map surface tokens to their corresponding "on" tokens
    final onTokenMap = {
      'surfacePrimary': 'onSurfacePrimary',
      'surfaceSecondary': 'onSurfaceSecondary',
      'surfaceTertiary': 'onSurfaceTertiary',
      'successBackground': 'onSuccessBackground',
      'warningBackground': 'onWarningBackground',
      'errorBackground': 'onErrorBackground',
      'infoBackground': 'onInfoBackground',
    };

    final onTokenName = onTokenMap[surfaceTokenName];
    if (onTokenName == null) {
      // If no specific "on" token exists, try to find a generic one
      // or return a default based on the surface color brightness
      final surfaceColor = getColor(surfaceTokenName);
      return _getContrastingColor(surfaceColor);
    }

    return getColor(onTokenName);
  }

  @override
  Map<String, AppColor> getAllColors() {
    _ensureInitialized();

    final themeMode = _currentThemeState.currentTheme.mode;
    final cacheKey = _getCacheKey(themeMode);
    
    // Return cached colors if available
    final cachedColors = _colorCache[cacheKey];
    if (cachedColors != null && cachedColors.isNotEmpty) {
      return Map.from(cachedColors);
    }

    // Resolve all colors from current theme
    final allColors = <String, AppColor>{};
    for (final entry in _currentThemeState.currentTheme.colorTokens.entries) {
      final resolvedColor = entry.value.getValueForTheme(themeMode);
      allColors[entry.key] = resolvedColor;
    }

    // Cache all colors
    _colorCache[cacheKey] = allColors;
    
    return allColors;
  }

  @override
  void dispose() {
    _systemThemeSubscription?.cancel();
    _themeController.close();
    _colorCache.clear();
  }

  /// Ensures the service is initialized before use
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ThemeProviderService must be initialized before use');
    }
  }

  /// Sets up system theme watching
  Future<void> _setupSystemThemeWatching() async {
    await _tearDownSystemThemeWatching(); // Clean up existing subscription
    
    _systemThemeSubscription = _themeRepository.watchSystemTheme().listen(
      (systemThemeMode) async {
        if (_currentThemeState.currentTheme.mode == ThemeMode.system) {
          // Clear and repopulate cache for new system theme
          _clearColorCache();
          await _populateColorCache(systemThemeMode);
          
          // Notify listeners of theme change
          _themeController.add(_currentThemeState);
        }
      },
      onError: (error) {
        _currentThemeState = _currentThemeState.withError('System theme watching failed: $error');
        _themeController.add(_currentThemeState);
      },
    );
  }

  /// Tears down system theme watching
  Future<void> _tearDownSystemThemeWatching() async {
    await _systemThemeSubscription?.cancel();
    _systemThemeSubscription = null;
  }

  /// Populates the color cache for the given theme mode
  Future<void> _populateColorCache(ThemeMode themeMode) async {
    try {
      final cacheKey = _getCacheKey(themeMode);
      final colors = <String, AppColor>{};
      
      for (final entry in _currentThemeState.currentTheme.colorTokens.entries) {
        final resolvedColor = entry.value.getValueForTheme(themeMode);
        colors[entry.key] = resolvedColor;
      }
      
      _colorCache[cacheKey] = colors;
    } catch (e) {
      // Cache population failure shouldn't break the service
      // Colors will be resolved on-demand instead
    }
  }

  /// Clears the color cache
  void _clearColorCache() {
    _colorCache.clear();
  }

  /// Caches a single color
  void _cacheColor(String cacheKey, String tokenName, AppColor color) {
    _colorCache[cacheKey] ??= {};
    _colorCache[cacheKey]![tokenName] = color;
  }

  /// Gets the cache key for a theme mode
  String _getCacheKey(ThemeMode themeMode) {
    return '${_currentThemeState.currentTheme.name}_${themeMode.name}';
  }

  /// Gets a contrasting color for the given surface color
  /// This is a fallback when no specific "on" color is defined
  AppColor _getContrastingColor(AppColor surfaceColor) {
    // Calculate relative luminance to determine if we need light or dark text
    final r = surfaceColor.red / 255.0;
    final g = surfaceColor.green / 255.0;
    final b = surfaceColor.blue / 255.0;
    
    final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    
    // Use dark text on light surfaces, light text on dark surfaces
    if (luminance > 0.5) {
      return AppColor.fromHex('#000000', 'contrastingText');
    } else {
      return AppColor.fromHex('#FFFFFF', 'contrastingText');
    }
  }
}