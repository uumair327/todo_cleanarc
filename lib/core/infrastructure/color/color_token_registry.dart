import '../../domain/entities/color_token.dart';
import '../../domain/enums/color_enums.dart';
import '../../domain/value_objects/app_color.dart';

/// Registry containing all predefined color tokens for the application
/// 
/// This class serves as the central repository for all semantic color definitions,
/// providing both light and dark theme variants for each color token.
class ColorTokenRegistry {
  static final Map<String, ColorToken> _tokens = {
    // Surface colors - Primary backgrounds and containers
    'surfacePrimary': ColorToken(
      name: 'surfacePrimary',
      lightValue: AppColor.fromHex('#FFFFFF', 'surfacePrimary'),
      darkValue: AppColor.fromHex('#121212', 'surfacePrimary'),
      role: ColorRole.surface,
    ),
    'surfaceSecondary': ColorToken(
      name: 'surfaceSecondary',
      lightValue: AppColor.fromHex('#FAFAFA', 'surfaceSecondary'),
      darkValue: AppColor.fromHex('#1E1E1E', 'surfaceSecondary'),
      role: ColorRole.surface,
    ),
    'surfaceTertiary': ColorToken(
      name: 'surfaceTertiary',
      lightValue: AppColor.fromHex('#F5F5F5', 'surfaceTertiary'),
      darkValue: AppColor.fromHex('#2A2A2A', 'surfaceTertiary'),
      role: ColorRole.surface,
    ),

    // Task category colors - Semantic colors for different task states
    'ongoingTask': ColorToken(
      name: 'ongoingTask',
      lightValue: AppColor.fromHex('#2196F3', 'ongoingTask'), // Blue
      darkValue: AppColor.fromHex('#64B5F6', 'ongoingTask'), // Light Blue
      role: ColorRole.primary,
    ),
    'inProcessTask': ColorToken(
      name: 'inProcessTask',
      lightValue: AppColor.fromHex('#FFC107', 'inProcessTask'), // Amber
      darkValue: AppColor.fromHex('#FFD54F', 'inProcessTask'), // Light Amber
      role: ColorRole.secondary,
    ),
    'completedTask': ColorToken(
      name: 'completedTask',
      lightValue: AppColor.fromHex('#4CAF50', 'completedTask'), // Green
      darkValue: AppColor.fromHex('#81C784', 'completedTask'), // Light Green
      role: ColorRole.success,
    ),
    'canceledTask': ColorToken(
      name: 'canceledTask',
      lightValue: AppColor.fromHex('#F44336', 'canceledTask'), // Red
      darkValue: AppColor.fromHex('#E57373', 'canceledTask'), // Light Red
      role: ColorRole.error,
    ),

    // State background colors - For status indicators and notifications
    'successBackground': ColorToken(
      name: 'successBackground',
      lightValue: AppColor.fromHex('#E8F5E8', 'successBackground'), // Very light green
      darkValue: AppColor.fromHex('#1B5E20', 'successBackground'), // Dark green
      role: ColorRole.surface,
    ),
    'warningBackground': ColorToken(
      name: 'warningBackground',
      lightValue: AppColor.fromHex('#FFF8E1', 'warningBackground'), // Very light amber
      darkValue: AppColor.fromHex('#E65100', 'warningBackground'), // Dark orange
      role: ColorRole.surface,
    ),
    'errorBackground': ColorToken(
      name: 'errorBackground',
      lightValue: AppColor.fromHex('#FFEBEE', 'errorBackground'), // Very light red
      darkValue: AppColor.fromHex('#B71C1C', 'errorBackground'), // Dark red
      role: ColorRole.surface,
    ),
    'infoBackground': ColorToken(
      name: 'infoBackground',
      lightValue: AppColor.fromHex('#E3F2FD', 'infoBackground'), // Very light blue
      darkValue: AppColor.fromHex('#0D47A1', 'infoBackground'), // Dark blue
      role: ColorRole.surface,
    ),

    // Text colors for different surfaces
    'onSurfacePrimary': ColorToken(
      name: 'onSurfacePrimary',
      lightValue: AppColor.fromHex('#000000', 'onSurfacePrimary'),
      darkValue: AppColor.fromHex('#FFFFFF', 'onSurfacePrimary'),
      role: ColorRole.onSurface,
    ),
    'onSurfaceSecondary': ColorToken(
      name: 'onSurfaceSecondary',
      lightValue: AppColor.fromHex('#424242', 'onSurfaceSecondary'),
      darkValue: AppColor.fromHex('#E0E0E0', 'onSurfaceSecondary'),
      role: ColorRole.onSurface,
    ),

    // Text colors for task categories
    'onOngoingTask': ColorToken(
      name: 'onOngoingTask',
      lightValue: AppColor.fromHex('#FFFFFF', 'onOngoingTask'),
      darkValue: AppColor.fromHex('#000000', 'onOngoingTask'),
      role: ColorRole.onPrimary,
    ),
    'onInProcessTask': ColorToken(
      name: 'onInProcessTask',
      lightValue: AppColor.fromHex('#000000', 'onInProcessTask'),
      darkValue: AppColor.fromHex('#000000', 'onInProcessTask'),
      role: ColorRole.onSecondary,
    ),
    'onCompletedTask': ColorToken(
      name: 'onCompletedTask',
      lightValue: AppColor.fromHex('#FFFFFF', 'onCompletedTask'),
      darkValue: AppColor.fromHex('#000000', 'onCompletedTask'),
      role: ColorRole.onSuccess,
    ),
    'onCanceledTask': ColorToken(
      name: 'onCanceledTask',
      lightValue: AppColor.fromHex('#FFFFFF', 'onCanceledTask'),
      darkValue: AppColor.fromHex('#000000', 'onCanceledTask'),
      role: ColorRole.onError,
    ),

    // Text colors for state backgrounds
    'onSuccessBackground': ColorToken(
      name: 'onSuccessBackground',
      lightValue: AppColor.fromHex('#1B5E20', 'onSuccessBackground'),
      darkValue: AppColor.fromHex('#E8F5E8', 'onSuccessBackground'),
      role: ColorRole.onSuccess,
    ),
    'onWarningBackground': ColorToken(
      name: 'onWarningBackground',
      lightValue: AppColor.fromHex('#E65100', 'onWarningBackground'),
      darkValue: AppColor.fromHex('#FFF8E1', 'onWarningBackground'),
      role: ColorRole.onWarning,
    ),
    'onErrorBackground': ColorToken(
      name: 'onErrorBackground',
      lightValue: AppColor.fromHex('#B71C1C', 'onErrorBackground'),
      darkValue: AppColor.fromHex('#FFEBEE', 'onErrorBackground'),
      role: ColorRole.onError,
    ),
    'onInfoBackground': ColorToken(
      name: 'onInfoBackground',
      lightValue: AppColor.fromHex('#0D47A1', 'onInfoBackground'),
      darkValue: AppColor.fromHex('#E3F2FD', 'onInfoBackground'),
      role: ColorRole.onInfo,
    ),

    // Opacity variants for common use cases
    'surfacePrimaryOpacity50': ColorToken(
      name: 'surfacePrimaryOpacity50',
      lightValue: AppColor.fromHex('#FFFFFF', 'surfacePrimaryOpacity50', opacity: 0.5),
      darkValue: AppColor.fromHex('#121212', 'surfacePrimaryOpacity50', opacity: 0.5),
      role: ColorRole.surface,
    ),
    'surfacePrimaryOpacity75': ColorToken(
      name: 'surfacePrimaryOpacity75',
      lightValue: AppColor.fromHex('#FFFFFF', 'surfacePrimaryOpacity75', opacity: 0.75),
      darkValue: AppColor.fromHex('#121212', 'surfacePrimaryOpacity75', opacity: 0.75),
      role: ColorRole.surface,
    ),
    'onSurfacePrimaryOpacity60': ColorToken(
      name: 'onSurfacePrimaryOpacity60',
      lightValue: AppColor.fromHex('#000000', 'onSurfacePrimaryOpacity60', opacity: 0.6),
      darkValue: AppColor.fromHex('#FFFFFF', 'onSurfacePrimaryOpacity60', opacity: 0.6),
      role: ColorRole.onSurface,
    ),
    'onSurfacePrimaryOpacity40': ColorToken(
      name: 'onSurfacePrimaryOpacity40',
      lightValue: AppColor.fromHex('#000000', 'onSurfacePrimaryOpacity40', opacity: 0.4),
      darkValue: AppColor.fromHex('#FFFFFF', 'onSurfacePrimaryOpacity40', opacity: 0.4),
      role: ColorRole.onSurface,
    ),
  };

  /// Returns all available color tokens
  Map<String, ColorToken> getAllTokens() => Map.unmodifiable(_tokens);

  /// Returns a specific color token by name
  ColorToken? getToken(String name) => _tokens[name];

  /// Checks if a color token exists
  bool hasToken(String name) => _tokens.containsKey(name);

  /// Returns all color tokens that match the specified role
  List<ColorToken> getTokensByRole(ColorRole role) {
    return _tokens.values.where((token) => token.role == role).toList();
  }

  /// Returns all surface color tokens
  List<ColorToken> getSurfaceTokens() => getTokensByRole(ColorRole.surface);

  /// Returns all text color tokens (onSurface, onPrimary, etc.)
  List<ColorToken> getTextTokens() {
    return _tokens.values.where((token) => 
      token.role == ColorRole.onSurface ||
      token.role == ColorRole.onPrimary ||
      token.role == ColorRole.onSecondary ||
      token.role == ColorRole.onError ||
      token.role == ColorRole.onSuccess ||
      token.role == ColorRole.onWarning ||
      token.role == ColorRole.onInfo
    ).toList();
  }

  /// Returns all task category color tokens
  List<ColorToken> getTaskCategoryTokens() {
    return [
      'ongoingTask',
      'inProcessTask', 
      'completedTask',
      'canceledTask'
    ].map((name) => _tokens[name]!).toList();
  }

  /// Returns all state background color tokens
  List<ColorToken> getStateBackgroundTokens() {
    return [
      'successBackground',
      'warningBackground',
      'errorBackground',
      'infoBackground'
    ].map((name) => _tokens[name]!).toList();
  }

  /// Returns all opacity variant tokens
  List<ColorToken> getOpacityVariantTokens() {
    return _tokens.values.where((token) => 
      token.name.toLowerCase().contains('opacity')
    ).toList();
  }

  /// Validates that all required tokens are present
  bool validateCompleteness() {
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
      'onSurfacePrimary',
      'onSurfaceSecondary',
    ];

    return requiredTokens.every((token) => _tokens.containsKey(token));
  }

  /// Returns the total number of color tokens
  int get tokenCount => _tokens.length;

  /// Returns all token names
  List<String> get tokenNames => _tokens.keys.toList();
}