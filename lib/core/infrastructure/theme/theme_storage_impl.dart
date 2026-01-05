import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_theme_config.dart';
import '../../domain/entities/color_token.dart';
import '../../domain/entities/theme_state.dart';
import '../../domain/enums/color_enums.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/value_objects/app_color.dart';
import '../../error/failures.dart';
import '../../utils/typedef.dart';
import '../color/color_token_registry.dart';

/// Implementation of ThemeRepository that uses SharedPreferences for persistence
/// and provides system theme detection capabilities.
class ThemeStorageImpl implements ThemeRepository {
  static const String _currentThemeKey = 'current_theme';
  static const String _systemThemeEnabledKey = 'system_theme_enabled';
  static const String _customThemesKey = 'custom_themes';

  final ColorTokenRegistry _colorRegistry = ColorTokenRegistry();
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the storage (must be called before using other methods)
  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ThemeStorageImpl must be initialized before use');
    }
  }

  @override
  ResultFuture<AppThemeConfig> getCurrentTheme() async {
    try {
      _ensureInitialized();
      
      final themeJson = _prefs.getString(_currentThemeKey);
      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
        final theme = _themeFromMap(themeMap);
        return Right(theme);
      }
      
      // Return default theme if none is saved
      final defaultTheme = await getDefaultTheme();
      return defaultTheme;
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get current theme: $e'));
    }
  }

  @override
  ResultVoid saveTheme(AppThemeConfig theme) async {
    try {
      _ensureInitialized();
      
      final themeMap = _themeToMap(theme);
      final themeJson = jsonEncode(themeMap);
      await _prefs.setString(_currentThemeKey, themeJson);
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save theme: $e'));
    }
  }

  @override
  ResultFuture<List<AppThemeConfig>> getAvailableThemes() async {
    try {
      _ensureInitialized();
      
      final themes = <AppThemeConfig>[];
      
      // Add built-in themes
      themes.addAll(await _getBuiltInThemes());
      
      // Add custom themes
      final customThemesJson = _prefs.getString(_customThemesKey);
      if (customThemesJson != null) {
        final customThemesList = jsonDecode(customThemesJson) as List<dynamic>;
        for (final themeMap in customThemesList) {
          themes.add(_themeFromMap(themeMap as Map<String, dynamic>));
        }
      }
      
      return Right(themes);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get available themes: $e'));
    }
  }

  @override
  ResultVoid addCustomTheme(AppThemeConfig theme) async {
    try {
      _ensureInitialized();
      
      final customThemesJson = _prefs.getString(_customThemesKey) ?? '[]';
      final customThemesList = jsonDecode(customThemesJson) as List<dynamic>;
      
      // Check if theme already exists
      final existingIndex = customThemesList.indexWhere(
        (themeMap) => themeMap['name'] == theme.name
      );
      
      if (existingIndex != -1) {
        return Left(ValidationFailure('Theme with name "${theme.name}" already exists'));
      }
      
      customThemesList.add(_themeToMap(theme));
      await _prefs.setString(_customThemesKey, jsonEncode(customThemesList));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add custom theme: $e'));
    }
  }

  @override
  ResultVoid removeCustomTheme(String themeName) async {
    try {
      _ensureInitialized();
      
      final customThemesJson = _prefs.getString(_customThemesKey) ?? '[]';
      final customThemesList = jsonDecode(customThemesJson) as List<dynamic>;
      
      customThemesList.removeWhere((themeMap) => themeMap['name'] == themeName);
      await _prefs.setString(_customThemesKey, jsonEncode(customThemesList));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to remove custom theme: $e'));
    }
  }

  @override
  ResultVoid updateCustomTheme(AppThemeConfig theme) async {
    try {
      _ensureInitialized();
      
      final customThemesJson = _prefs.getString(_customThemesKey) ?? '[]';
      final customThemesList = jsonDecode(customThemesJson) as List<dynamic>;
      
      final existingIndex = customThemesList.indexWhere(
        (themeMap) => themeMap['name'] == theme.name
      );
      
      if (existingIndex == -1) {
        return Left(ValidationFailure('Theme with name "${theme.name}" not found'));
      }
      
      customThemesList[existingIndex] = _themeToMap(theme);
      await _prefs.setString(_customThemesKey, jsonEncode(customThemesList));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update custom theme: $e'));
    }
  }

  @override
  Stream<ThemeMode> watchSystemTheme() {
    // Create a stream that listens to system theme changes
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _getCurrentSystemThemeMode();
    }).distinct();
  }

  @override
  ResultFuture<ThemeMode> getSystemThemeMode() async {
    try {
      final systemTheme = _getCurrentSystemThemeMode();
      return Right(systemTheme);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get system theme mode: $e'));
    }
  }

  @override
  ResultFuture<bool> getSystemThemeEnabled() async {
    try {
      _ensureInitialized();
      
      final enabled = _prefs.getBool(_systemThemeEnabledKey) ?? true;
      return Right(enabled);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get system theme enabled: $e'));
    }
  }

  @override
  ResultVoid setSystemThemeEnabled(bool enabled) async {
    try {
      _ensureInitialized();
      
      await _prefs.setBool(_systemThemeEnabledKey, enabled);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to set system theme enabled: $e'));
    }
  }

  @override
  ResultFuture<ThemeState> getThemeState() async {
    try {
      final currentThemeResult = await getCurrentTheme();
      final availableThemesResult = await getAvailableThemes();
      final systemThemeEnabledResult = await getSystemThemeEnabled();

      return currentThemeResult.fold(
        (failure) => Left(failure),
        (currentTheme) => availableThemesResult.fold(
          (failure) => Left(failure),
          (availableThemes) => systemThemeEnabledResult.fold(
            (failure) => Left(failure),
            (systemThemeEnabled) => Right(ThemeState(
              currentTheme: currentTheme,
              availableThemes: availableThemes,
              isSystemThemeEnabled: systemThemeEnabled,
            )),
          ),
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get theme state: $e'));
    }
  }

  @override
  ResultVoid saveThemeState(ThemeState state) async {
    try {
      final saveThemeResult = await saveTheme(state.currentTheme);
      if (saveThemeResult.isLeft()) {
        return saveThemeResult;
      }

      final setSystemThemeResult = await setSystemThemeEnabled(state.isSystemThemeEnabled);
      if (setSystemThemeResult.isLeft()) {
        return setSystemThemeResult;
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save theme state: $e'));
    }
  }

  @override
  ResultVoid resetToDefaults() async {
    try {
      _ensureInitialized();
      
      await _prefs.remove(_currentThemeKey);
      await _prefs.remove(_systemThemeEnabledKey);
      await _prefs.remove(_customThemesKey);
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to reset to defaults: $e'));
    }
  }

  @override
  ResultVoid validateTheme(AppThemeConfig theme) async {
    try {
      // Check that theme has a valid name
      if (theme.name.isEmpty) {
        return Left(ValidationFailure('Theme name cannot be empty'));
      }

      // Check that theme has required color tokens
      final requiredTokens = [
        'surfacePrimary',
        'surfaceSecondary',
        'ongoingTask',
        'completedTask',
      ];

      for (final tokenName in requiredTokens) {
        if (!theme.colorTokens.containsKey(tokenName)) {
          return Left(ValidationFailure('Theme missing required color token: $tokenName'));
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Theme validation failed: $e'));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> exportTheme(AppThemeConfig theme) async {
    try {
      final themeMap = _themeToMap(theme);
      return Right(themeMap);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to export theme: $e'));
    }
  }

  @override
  ResultFuture<AppThemeConfig> importTheme(Map<String, dynamic> themeData) async {
    try {
      final theme = _themeFromMap(themeData);
      return Right(theme);
    } catch (e) {
      return Left(ValidationFailure('Failed to import theme: $e'));
    }
  }

  @override
  ResultFuture<bool> themeExists(String themeName) async {
    try {
      final availableThemesResult = await getAvailableThemes();
      return availableThemesResult.fold(
        (failure) => Left(failure),
        (themes) => Right(themes.any((theme) => theme.name == themeName)),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check theme existence: $e'));
    }
  }

  @override
  ResultFuture<AppThemeConfig> getDefaultTheme() async {
    try {
      final colorTokens = _colorRegistry.getAllTokens();
      
      final defaultTheme = AppThemeConfig(
        name: 'Default',
        mode: ThemeMode.system,
        colorTokens: colorTokens,
        isSystemDefault: true,
      );
      
      return Right(defaultTheme);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get default theme: $e'));
    }
  }

  /// Gets the current system theme mode by checking platform brightness
  ThemeMode _getCurrentSystemThemeMode() {
    try {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      // Fallback to light mode if detection fails
      return ThemeMode.light;
    }
  }

  /// Gets the built-in themes
  Future<List<AppThemeConfig>> _getBuiltInThemes() async {
    final colorTokens = _colorRegistry.getAllTokens();
    
    return [
      AppThemeConfig(
        name: 'Light',
        mode: ThemeMode.light,
        colorTokens: colorTokens,
        isSystemDefault: false,
      ),
      AppThemeConfig(
        name: 'Dark',
        mode: ThemeMode.dark,
        colorTokens: colorTokens,
        isSystemDefault: false,
      ),
      AppThemeConfig(
        name: 'System',
        mode: ThemeMode.system,
        colorTokens: colorTokens,
        isSystemDefault: true,
      ),
    ];
  }

  /// Converts a theme to a map for JSON serialization
  Map<String, dynamic> _themeToMap(AppThemeConfig theme) {
    return {
      'name': theme.name,
      'mode': theme.mode.name,
      'isSystemDefault': theme.isSystemDefault,
      'colorTokens': theme.colorTokens.map((key, token) => MapEntry(key, {
        'name': token.name,
        'lightValue': {
          'value': token.lightValue.value,
          'semanticName': token.lightValue.semanticName,
          'opacity': token.lightValue.opacity,
        },
        'darkValue': {
          'value': token.darkValue.value,
          'semanticName': token.darkValue.semanticName,
          'opacity': token.darkValue.opacity,
        },
        'role': token.role.name,
      })),
    };
  }

  /// Converts a map to a theme from JSON deserialization
  AppThemeConfig _themeFromMap(Map<String, dynamic> map) {
    final colorTokensMap = map['colorTokens'] as Map<String, dynamic>;
    final colorTokens = <String, ColorToken>{};

    for (final entry in colorTokensMap.entries) {
      final tokenMap = entry.value as Map<String, dynamic>;
      final lightValueMap = tokenMap['lightValue'] as Map<String, dynamic>;
      final darkValueMap = tokenMap['darkValue'] as Map<String, dynamic>;

      colorTokens[entry.key] = ColorToken(
        name: tokenMap['name'] as String,
        lightValue: AppColor(
          value: lightValueMap['value'] as int,
          semanticName: lightValueMap['semanticName'] as String,
          opacity: (lightValueMap['opacity'] as num).toDouble(),
        ),
        darkValue: AppColor(
          value: darkValueMap['value'] as int,
          semanticName: darkValueMap['semanticName'] as String,
          opacity: (darkValueMap['opacity'] as num).toDouble(),
        ),
        role: ColorRole.values.firstWhere(
          (role) => role.name == tokenMap['role'],
        ),
      );
    }

    return AppThemeConfig(
      name: map['name'] as String,
      mode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['mode'],
      ),
      colorTokens: colorTokens,
      isSystemDefault: map['isSystemDefault'] as bool? ?? false,
    );
  }
}