import 'package:flutter/material.dart';
import '../domain/value_objects/app_color.dart';
import '../services/theme_provider_service.dart';

/// Theme extension that provides semantic color access throughout the application
/// 
/// This extension integrates with Flutter's Material 3 theming system while
/// providing type-safe access to all semantic colors defined in the color system.
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  // Surface colors - Primary backgrounds and containers
  final AppColor surfacePrimary;
  final AppColor surfaceSecondary;
  final AppColor surfaceTertiary;

  // Task category colors - Semantic colors for different task states
  final AppColor ongoingTask;
  final AppColor inProcessTask;
  final AppColor completedTask;
  final AppColor canceledTask;

  // State background colors - For status indicators and notifications
  final AppColor successBackground;
  final AppColor warningBackground;
  final AppColor errorBackground;
  final AppColor infoBackground;

  // Text colors for different surfaces
  final AppColor onSurfacePrimary;
  final AppColor onSurfaceSecondary;

  // Text colors for task categories
  final AppColor onOngoingTask;
  final AppColor onInProcessTask;
  final AppColor onCompletedTask;
  final AppColor onCanceledTask;

  // Text colors for state backgrounds
  final AppColor onSuccessBackground;
  final AppColor onWarningBackground;
  final AppColor onErrorBackground;
  final AppColor onInfoBackground;

  // Opacity variants for common use cases
  final AppColor surfacePrimaryOpacity50;
  final AppColor surfacePrimaryOpacity75;
  final AppColor onSurfacePrimaryOpacity60;
  final AppColor onSurfacePrimaryOpacity40;

  const AppColorExtension({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.ongoingTask,
    required this.inProcessTask,
    required this.completedTask,
    required this.canceledTask,
    required this.successBackground,
    required this.warningBackground,
    required this.errorBackground,
    required this.infoBackground,
    required this.onSurfacePrimary,
    required this.onSurfaceSecondary,
    required this.onOngoingTask,
    required this.onInProcessTask,
    required this.onCompletedTask,
    required this.onCanceledTask,
    required this.onSuccessBackground,
    required this.onWarningBackground,
    required this.onErrorBackground,
    required this.onInfoBackground,
    required this.surfacePrimaryOpacity50,
    required this.surfacePrimaryOpacity75,
    required this.onSurfacePrimaryOpacity60,
    required this.onSurfacePrimaryOpacity40,
  });

  /// Creates an AppColorExtension from a ThemeProviderService
  /// 
  /// This factory method integrates with the dependency injection system
  /// to create color extensions that are automatically updated when themes change.
  factory AppColorExtension.fromThemeProvider(ThemeProviderService themeProvider) {
    return AppColorExtension(
      surfacePrimary: themeProvider.getColor('surfacePrimary'),
      surfaceSecondary: themeProvider.getColor('surfaceSecondary'),
      surfaceTertiary: themeProvider.getColor('surfaceTertiary'),
      ongoingTask: themeProvider.getColor('ongoingTask'),
      inProcessTask: themeProvider.getColor('inProcessTask'),
      completedTask: themeProvider.getColor('completedTask'),
      canceledTask: themeProvider.getColor('canceledTask'),
      successBackground: themeProvider.getColor('successBackground'),
      warningBackground: themeProvider.getColor('warningBackground'),
      errorBackground: themeProvider.getColor('errorBackground'),
      infoBackground: themeProvider.getColor('infoBackground'),
      onSurfacePrimary: themeProvider.getColor('onSurfacePrimary'),
      onSurfaceSecondary: themeProvider.getColor('onSurfaceSecondary'),
      onOngoingTask: themeProvider.getColor('onOngoingTask'),
      onInProcessTask: themeProvider.getColor('onInProcessTask'),
      onCompletedTask: themeProvider.getColor('onCompletedTask'),
      onCanceledTask: themeProvider.getColor('onCanceledTask'),
      onSuccessBackground: themeProvider.getColor('onSuccessBackground'),
      onWarningBackground: themeProvider.getColor('onWarningBackground'),
      onErrorBackground: themeProvider.getColor('onErrorBackground'),
      onInfoBackground: themeProvider.getColor('onInfoBackground'),
      surfacePrimaryOpacity50: themeProvider.getColor('surfacePrimaryOpacity50'),
      surfacePrimaryOpacity75: themeProvider.getColor('surfacePrimaryOpacity75'),
      onSurfacePrimaryOpacity60: themeProvider.getColor('onSurfacePrimaryOpacity60'),
      onSurfacePrimaryOpacity40: themeProvider.getColor('onSurfacePrimaryOpacity40'),
    );
  }

  @override
  AppColorExtension copyWith({
    AppColor? surfacePrimary,
    AppColor? surfaceSecondary,
    AppColor? surfaceTertiary,
    AppColor? ongoingTask,
    AppColor? inProcessTask,
    AppColor? completedTask,
    AppColor? canceledTask,
    AppColor? successBackground,
    AppColor? warningBackground,
    AppColor? errorBackground,
    AppColor? infoBackground,
    AppColor? onSurfacePrimary,
    AppColor? onSurfaceSecondary,
    AppColor? onOngoingTask,
    AppColor? onInProcessTask,
    AppColor? onCompletedTask,
    AppColor? onCanceledTask,
    AppColor? onSuccessBackground,
    AppColor? onWarningBackground,
    AppColor? onErrorBackground,
    AppColor? onInfoBackground,
    AppColor? surfacePrimaryOpacity50,
    AppColor? surfacePrimaryOpacity75,
    AppColor? onSurfacePrimaryOpacity60,
    AppColor? onSurfacePrimaryOpacity40,
  }) {
    return AppColorExtension(
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      ongoingTask: ongoingTask ?? this.ongoingTask,
      inProcessTask: inProcessTask ?? this.inProcessTask,
      completedTask: completedTask ?? this.completedTask,
      canceledTask: canceledTask ?? this.canceledTask,
      successBackground: successBackground ?? this.successBackground,
      warningBackground: warningBackground ?? this.warningBackground,
      errorBackground: errorBackground ?? this.errorBackground,
      infoBackground: infoBackground ?? this.infoBackground,
      onSurfacePrimary: onSurfacePrimary ?? this.onSurfacePrimary,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
      onOngoingTask: onOngoingTask ?? this.onOngoingTask,
      onInProcessTask: onInProcessTask ?? this.onInProcessTask,
      onCompletedTask: onCompletedTask ?? this.onCompletedTask,
      onCanceledTask: onCanceledTask ?? this.onCanceledTask,
      onSuccessBackground: onSuccessBackground ?? this.onSuccessBackground,
      onWarningBackground: onWarningBackground ?? this.onWarningBackground,
      onErrorBackground: onErrorBackground ?? this.onErrorBackground,
      onInfoBackground: onInfoBackground ?? this.onInfoBackground,
      surfacePrimaryOpacity50: surfacePrimaryOpacity50 ?? this.surfacePrimaryOpacity50,
      surfacePrimaryOpacity75: surfacePrimaryOpacity75 ?? this.surfacePrimaryOpacity75,
      onSurfacePrimaryOpacity60: onSurfacePrimaryOpacity60 ?? this.onSurfacePrimaryOpacity60,
      onSurfacePrimaryOpacity40: onSurfacePrimaryOpacity40 ?? this.onSurfacePrimaryOpacity40,
    );
  }

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) {
      return this;
    }

    return AppColorExtension(
      surfacePrimary: _lerpAppColor(surfacePrimary, other.surfacePrimary, t),
      surfaceSecondary: _lerpAppColor(surfaceSecondary, other.surfaceSecondary, t),
      surfaceTertiary: _lerpAppColor(surfaceTertiary, other.surfaceTertiary, t),
      ongoingTask: _lerpAppColor(ongoingTask, other.ongoingTask, t),
      inProcessTask: _lerpAppColor(inProcessTask, other.inProcessTask, t),
      completedTask: _lerpAppColor(completedTask, other.completedTask, t),
      canceledTask: _lerpAppColor(canceledTask, other.canceledTask, t),
      successBackground: _lerpAppColor(successBackground, other.successBackground, t),
      warningBackground: _lerpAppColor(warningBackground, other.warningBackground, t),
      errorBackground: _lerpAppColor(errorBackground, other.errorBackground, t),
      infoBackground: _lerpAppColor(infoBackground, other.infoBackground, t),
      onSurfacePrimary: _lerpAppColor(onSurfacePrimary, other.onSurfacePrimary, t),
      onSurfaceSecondary: _lerpAppColor(onSurfaceSecondary, other.onSurfaceSecondary, t),
      onOngoingTask: _lerpAppColor(onOngoingTask, other.onOngoingTask, t),
      onInProcessTask: _lerpAppColor(onInProcessTask, other.onInProcessTask, t),
      onCompletedTask: _lerpAppColor(onCompletedTask, other.onCompletedTask, t),
      onCanceledTask: _lerpAppColor(onCanceledTask, other.onCanceledTask, t),
      onSuccessBackground: _lerpAppColor(onSuccessBackground, other.onSuccessBackground, t),
      onWarningBackground: _lerpAppColor(onWarningBackground, other.onWarningBackground, t),
      onErrorBackground: _lerpAppColor(onErrorBackground, other.onErrorBackground, t),
      onInfoBackground: _lerpAppColor(onInfoBackground, other.onInfoBackground, t),
      surfacePrimaryOpacity50: _lerpAppColor(surfacePrimaryOpacity50, other.surfacePrimaryOpacity50, t),
      surfacePrimaryOpacity75: _lerpAppColor(surfacePrimaryOpacity75, other.surfacePrimaryOpacity75, t),
      onSurfacePrimaryOpacity60: _lerpAppColor(onSurfacePrimaryOpacity60, other.onSurfacePrimaryOpacity60, t),
      onSurfacePrimaryOpacity40: _lerpAppColor(onSurfacePrimaryOpacity40, other.onSurfacePrimaryOpacity40, t),
    );
  }

  /// Helper method to interpolate between two AppColor instances
  AppColor _lerpAppColor(AppColor a, AppColor b, double t) {
    final colorA = a.toFlutterColor();
    final colorB = b.toFlutterColor();
    final lerpedColor = Color.lerp(colorA, colorB, t)!;
    
    return AppColor.fromFlutterColor(
      lerpedColor,
      t < 0.5 ? a.semanticName : b.semanticName,
    );
  }

  /// Convenience method to get task category color by task status
  AppColor getTaskCategoryColor(String taskStatus) {
    switch (taskStatus.toLowerCase()) {
      case 'ongoing':
        return ongoingTask;
      case 'inprocess':
      case 'in_process':
        return inProcessTask;
      case 'completed':
        return completedTask;
      case 'canceled':
      case 'cancelled':
        return canceledTask;
      default:
        return ongoingTask; // Default fallback
    }
  }

  /// Convenience method to get text color for task category
  AppColor getOnTaskCategoryColor(String taskStatus) {
    switch (taskStatus.toLowerCase()) {
      case 'ongoing':
        return onOngoingTask;
      case 'inprocess':
      case 'in_process':
        return onInProcessTask;
      case 'completed':
        return onCompletedTask;
      case 'canceled':
      case 'cancelled':
        return onCanceledTask;
      default:
        return onOngoingTask; // Default fallback
    }
  }

  /// Convenience method to get state background color
  AppColor getStateBackgroundColor(String state) {
    switch (state.toLowerCase()) {
      case 'success':
        return successBackground;
      case 'warning':
        return warningBackground;
      case 'error':
        return errorBackground;
      case 'info':
        return infoBackground;
      default:
        return infoBackground; // Default fallback
    }
  }

  /// Convenience method to get text color for state background
  AppColor getOnStateBackgroundColor(String state) {
    switch (state.toLowerCase()) {
      case 'success':
        return onSuccessBackground;
      case 'warning':
        return onWarningBackground;
      case 'error':
        return onErrorBackground;
      case 'info':
        return onInfoBackground;
      default:
        return onInfoBackground; // Default fallback
    }
  }
}