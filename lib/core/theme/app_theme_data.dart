import 'package:flutter/material.dart';
import '../infrastructure/color/color_token_registry.dart';
import 'app_color_extension.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Provides Material 3 theme configurations with integrated semantic color system
///
/// This class creates ThemeData instances that integrate Flutter's Material 3 design
/// system with the application's semantic color tokens, ensuring consistent theming
/// across all components while maintaining type safety and performance.
class AppThemeData {
  /// Creates a light theme with the provided color extension
  static ThemeData lightTheme(AppColorExtension colorExtension) {
    // Create Material 3 ColorScheme from semantic colors
    final colorScheme = ColorScheme.light(
      // Primary colors - using ongoing task as the primary brand color
      primary: colorExtension.ongoingTask.toFlutterColor(),
      onPrimary: colorExtension.onOngoingTask.toFlutterColor(),
      primaryContainer:
          colorExtension.ongoingTask.withOpacity(0.12).toFlutterColor(),
      onPrimaryContainer: colorExtension.ongoingTask.toFlutterColor(),

      // Secondary colors - using in-process task color
      secondary: colorExtension.inProcessTask.toFlutterColor(),
      onSecondary: colorExtension.onInProcessTask.toFlutterColor(),
      secondaryContainer:
          colorExtension.inProcessTask.withOpacity(0.12).toFlutterColor(),
      onSecondaryContainer: colorExtension.inProcessTask.toFlutterColor(),

      // Tertiary colors - using completed task color
      tertiary: colorExtension.completedTask.toFlutterColor(),
      onTertiary: colorExtension.onCompletedTask.toFlutterColor(),
      tertiaryContainer:
          colorExtension.completedTask.withOpacity(0.12).toFlutterColor(),
      onTertiaryContainer: colorExtension.completedTask.toFlutterColor(),

      // Error colors - using canceled task color
      error: colorExtension.canceledTask.toFlutterColor(),
      onError: colorExtension.onCanceledTask.toFlutterColor(),
      errorContainer: colorExtension.errorBackground.toFlutterColor(),
      onErrorContainer: colorExtension.onErrorBackground.toFlutterColor(),

      // Surface colors - using semantic surface hierarchy
      surface: colorExtension.surfacePrimary.toFlutterColor(),
      onSurface: colorExtension.onSurfacePrimary.toFlutterColor(),
      surfaceContainerLowest: colorExtension.surfacePrimary.toFlutterColor(),
      surfaceContainerLow: colorExtension.surfaceSecondary.toFlutterColor(),
      surfaceContainer: colorExtension.surfaceSecondary.toFlutterColor(),
      surfaceContainerHigh: colorExtension.surfaceTertiary.toFlutterColor(),
      surfaceContainerHighest: colorExtension.surfaceTertiary.toFlutterColor(),
      onSurfaceVariant: colorExtension.onSurfaceSecondary.toFlutterColor(),

      // Outline colors - using opacity variants for subtle borders
      outline: colorExtension.onSurfacePrimaryOpacity40.toFlutterColor(),
      outlineVariant: colorExtension.onSurfacePrimaryOpacity40
          .withOpacity(0.2)
          .toFlutterColor(),

      // Shadow and scrim
      shadow:
          colorExtension.onSurfacePrimary.withOpacity(0.15).toFlutterColor(),
      scrim: colorExtension.onSurfacePrimary.withOpacity(0.8).toFlutterColor(),

      // Inverse colors for high contrast elements
      inverseSurface: colorExtension.onSurfacePrimary.toFlutterColor(),
      onInverseSurface: colorExtension.surfacePrimary.toFlutterColor(),
      inversePrimary: colorExtension.surfacePrimary.toFlutterColor(),

      // Surface tint for Material 3 elevation
      surfaceTint: colorExtension.ongoingTask.toFlutterColor(),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [colorExtension],

      // Typography - inherit from existing app theme
      textTheme: _getTextTheme(colorScheme),

      // Component themes that integrate with semantic colors
      appBarTheme: _getAppBarTheme(colorScheme, colorExtension),
      elevatedButtonTheme: _getElevatedButtonTheme(colorScheme),
      filledButtonTheme: _getFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _getOutlinedButtonTheme(colorScheme),
      textButtonTheme: _getTextButtonTheme(colorScheme),
      floatingActionButtonTheme: _getFloatingActionButtonTheme(colorScheme),
      cardTheme: _getCardTheme(colorScheme),
      chipTheme: _getChipTheme(colorScheme),
      inputDecorationTheme: _getInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _getBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _getNavigationBarTheme(colorScheme),
      dividerTheme: _getDividerTheme(colorScheme),
      iconTheme: _getIconTheme(colorScheme),
      listTileTheme: _getListTileTheme(colorScheme),
      switchTheme: _getSwitchTheme(colorScheme),
      checkboxTheme: _getCheckboxTheme(colorScheme),
      radioTheme: _getRadioTheme(colorScheme),
      sliderTheme: _getSliderTheme(colorScheme),
      progressIndicatorTheme: _getProgressIndicatorTheme(colorScheme),
      snackBarTheme: _getSnackBarTheme(colorScheme, colorExtension),
      dialogTheme: _getDialogTheme(colorScheme),
      bottomSheetTheme: _getBottomSheetTheme(colorScheme),
      popupMenuTheme: _getPopupMenuTheme(colorScheme),
      tooltipTheme: _getTooltipTheme(colorScheme),
    );
  }

  /// Creates a dark theme with the provided color extension
  static ThemeData darkTheme(AppColorExtension colorExtension) {
    // Create Material 3 ColorScheme from semantic colors
    final colorScheme = ColorScheme.dark(
      // Primary colors - using ongoing task as the primary brand color
      primary: colorExtension.ongoingTask.toFlutterColor(),
      onPrimary: colorExtension.onOngoingTask.toFlutterColor(),
      primaryContainer:
          colorExtension.ongoingTask.withOpacity(0.24).toFlutterColor(),
      onPrimaryContainer: colorExtension.ongoingTask.toFlutterColor(),

      // Secondary colors - using in-process task color
      secondary: colorExtension.inProcessTask.toFlutterColor(),
      onSecondary: colorExtension.onInProcessTask.toFlutterColor(),
      secondaryContainer:
          colorExtension.inProcessTask.withOpacity(0.24).toFlutterColor(),
      onSecondaryContainer: colorExtension.inProcessTask.toFlutterColor(),

      // Tertiary colors - using completed task color
      tertiary: colorExtension.completedTask.toFlutterColor(),
      onTertiary: colorExtension.onCompletedTask.toFlutterColor(),
      tertiaryContainer:
          colorExtension.completedTask.withOpacity(0.24).toFlutterColor(),
      onTertiaryContainer: colorExtension.completedTask.toFlutterColor(),

      // Error colors - using canceled task color
      error: colorExtension.canceledTask.toFlutterColor(),
      onError: colorExtension.onCanceledTask.toFlutterColor(),
      errorContainer: colorExtension.errorBackground.toFlutterColor(),
      onErrorContainer: colorExtension.onErrorBackground.toFlutterColor(),

      // Surface colors - using semantic surface hierarchy
      surface: colorExtension.surfacePrimary.toFlutterColor(),
      onSurface: colorExtension.onSurfacePrimary.toFlutterColor(),
      surfaceContainerLowest: colorExtension.surfacePrimary.toFlutterColor(),
      surfaceContainerLow: colorExtension.surfaceSecondary.toFlutterColor(),
      surfaceContainer: colorExtension.surfaceSecondary.toFlutterColor(),
      surfaceContainerHigh: colorExtension.surfaceTertiary.toFlutterColor(),
      surfaceContainerHighest: colorExtension.surfaceTertiary.toFlutterColor(),
      onSurfaceVariant: colorExtension.onSurfaceSecondary.toFlutterColor(),

      // Outline colors - using opacity variants for subtle borders
      outline: colorExtension.onSurfacePrimaryOpacity60.toFlutterColor(),
      outlineVariant: colorExtension.onSurfacePrimaryOpacity40.toFlutterColor(),

      // Shadow and scrim
      shadow: colorExtension.onSurfacePrimary.withOpacity(0.3).toFlutterColor(),
      scrim: colorExtension.onSurfacePrimary.withOpacity(0.9).toFlutterColor(),

      // Inverse colors for high contrast elements
      inverseSurface: colorExtension.onSurfacePrimary.toFlutterColor(),
      onInverseSurface: colorExtension.surfacePrimary.toFlutterColor(),
      inversePrimary: colorExtension.surfacePrimary.toFlutterColor(),

      // Surface tint for Material 3 elevation
      surfaceTint: colorExtension.ongoingTask.toFlutterColor(),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [colorExtension],

      // Typography - inherit from existing app theme
      textTheme: _getTextTheme(colorScheme),

      // Component themes that integrate with semantic colors
      appBarTheme: _getAppBarTheme(colorScheme, colorExtension),
      elevatedButtonTheme: _getElevatedButtonTheme(colorScheme),
      filledButtonTheme: _getFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _getOutlinedButtonTheme(colorScheme),
      textButtonTheme: _getTextButtonTheme(colorScheme),
      floatingActionButtonTheme: _getFloatingActionButtonTheme(colorScheme),
      cardTheme: _getCardTheme(colorScheme),
      chipTheme: _getChipTheme(colorScheme),
      inputDecorationTheme: _getInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _getBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _getNavigationBarTheme(colorScheme),
      dividerTheme: _getDividerTheme(colorScheme),
      iconTheme: _getIconTheme(colorScheme),
      listTileTheme: _getListTileTheme(colorScheme),
      switchTheme: _getSwitchTheme(colorScheme),
      checkboxTheme: _getCheckboxTheme(colorScheme),
      radioTheme: _getRadioTheme(colorScheme),
      sliderTheme: _getSliderTheme(colorScheme),
      progressIndicatorTheme: _getProgressIndicatorTheme(colorScheme),
      snackBarTheme: _getSnackBarTheme(colorScheme, colorExtension),
      dialogTheme: _getDialogTheme(colorScheme),
      bottomSheetTheme: _getBottomSheetTheme(colorScheme),
      popupMenuTheme: _getPopupMenuTheme(colorScheme),
      tooltipTheme: _getTooltipTheme(colorScheme),
    );
  }

  /// Creates an AppColorExtension from color tokens for the specified theme mode
  static AppColorExtension createColorExtension(ThemeMode themeMode) {
    final registry = ColorTokenRegistry();

    return AppColorExtension(
      surfacePrimary:
          registry.getToken('surfacePrimary')!.getValueForTheme(themeMode),
      surfaceSecondary:
          registry.getToken('surfaceSecondary')!.getValueForTheme(themeMode),
      surfaceTertiary:
          registry.getToken('surfaceTertiary')!.getValueForTheme(themeMode),
      ongoingTask:
          registry.getToken('ongoingTask')!.getValueForTheme(themeMode),
      inProcessTask:
          registry.getToken('inProcessTask')!.getValueForTheme(themeMode),
      completedTask:
          registry.getToken('completedTask')!.getValueForTheme(themeMode),
      canceledTask:
          registry.getToken('canceledTask')!.getValueForTheme(themeMode),
      successBackground:
          registry.getToken('successBackground')!.getValueForTheme(themeMode),
      warningBackground:
          registry.getToken('warningBackground')!.getValueForTheme(themeMode),
      errorBackground:
          registry.getToken('errorBackground')!.getValueForTheme(themeMode),
      infoBackground:
          registry.getToken('infoBackground')!.getValueForTheme(themeMode),
      onSurfacePrimary:
          registry.getToken('onSurfacePrimary')!.getValueForTheme(themeMode),
      onSurfaceSecondary:
          registry.getToken('onSurfaceSecondary')!.getValueForTheme(themeMode),
      onOngoingTask:
          registry.getToken('onOngoingTask')!.getValueForTheme(themeMode),
      onInProcessTask:
          registry.getToken('onInProcessTask')!.getValueForTheme(themeMode),
      onCompletedTask:
          registry.getToken('onCompletedTask')!.getValueForTheme(themeMode),
      onCanceledTask:
          registry.getToken('onCanceledTask')!.getValueForTheme(themeMode),
      onSuccessBackground:
          registry.getToken('onSuccessBackground')!.getValueForTheme(themeMode),
      onWarningBackground:
          registry.getToken('onWarningBackground')!.getValueForTheme(themeMode),
      onErrorBackground:
          registry.getToken('onErrorBackground')!.getValueForTheme(themeMode),
      onInfoBackground:
          registry.getToken('onInfoBackground')!.getValueForTheme(themeMode),
      surfacePrimaryOpacity50: registry
          .getToken('surfacePrimaryOpacity50')!
          .getValueForTheme(themeMode),
      surfacePrimaryOpacity75: registry
          .getToken('surfacePrimaryOpacity75')!
          .getValueForTheme(themeMode),
      onSurfacePrimaryOpacity60: registry
          .getToken('onSurfacePrimaryOpacity60')!
          .getValueForTheme(themeMode),
      onSurfacePrimaryOpacity40: registry
          .getToken('onSurfacePrimaryOpacity40')!
          .getValueForTheme(themeMode),
    );
  }

  // Private helper methods for component themes

  static TextTheme _getTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(color: colorScheme.onSurface),
      displayMedium: TextStyle(color: colorScheme.onSurface),
      displaySmall: TextStyle(color: colorScheme.onSurface),
      headlineLarge: TextStyle(color: colorScheme.onSurface),
      headlineMedium: TextStyle(color: colorScheme.onSurface),
      headlineSmall: TextStyle(color: colorScheme.onSurface),
      titleLarge: TextStyle(color: colorScheme.onSurface),
      titleMedium: TextStyle(color: colorScheme.onSurface),
      titleSmall: TextStyle(color: colorScheme.onSurface),
      bodyLarge: TextStyle(color: colorScheme.onSurface),
      bodyMedium: TextStyle(color: colorScheme.onSurface),
      bodySmall: TextStyle(color: colorScheme.onSurfaceVariant),
      labelLarge: TextStyle(color: colorScheme.onSurface),
      labelMedium: TextStyle(color: colorScheme.onSurfaceVariant),
      labelSmall: TextStyle(color: colorScheme.onSurfaceVariant),
    );
  }

  static AppBarTheme _getAppBarTheme(
      ColorScheme colorScheme, AppColorExtension colorExtension) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: AppTypography.h4.fontSize,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppDimensions.iconSize,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppDimensions.iconSize,
      ),
    );
  }

  static ElevatedButtonThemeData _getElevatedButtonTheme(
      ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  static FilledButtonThemeData _getFilledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  static OutlinedButtonThemeData _getOutlinedButtonTheme(
      ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  static TextButtonThemeData _getTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  static FloatingActionButtonThemeData _getFloatingActionButtonTheme(
      ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: const CircleBorder(),
    );
  }

  static CardThemeData _getCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      margin: const EdgeInsets.all(AppSpacing.xs),
    );
  }

  static ChipThemeData _getChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.secondaryContainer,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      deleteIconColor: colorScheme.onSurfaceVariant,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mdSm, vertical: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }

  static InputDecorationTheme _getInputDecorationTheme(
      ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.mdSm),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      errorStyle: TextStyle(color: colorScheme.error),
      helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    );
  }

  static BottomNavigationBarThemeData _getBottomNavigationBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 3,
      type: BottomNavigationBarType.fixed,
    );
  }

  static NavigationBarThemeData _getNavigationBarTheme(
      ColorScheme colorScheme) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      indicatorColor: colorScheme.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: colorScheme.onSurface);
        }
        return TextStyle(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  static DividerThemeData _getDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static IconThemeData _getIconTheme(ColorScheme colorScheme) {
    return IconThemeData(
      color: colorScheme.onSurfaceVariant,
      size: AppDimensions.iconSize,
    );
  }

  static ListTileThemeData _getListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      tileColor: colorScheme.surface,
      selectedTileColor: colorScheme.secondaryContainer,
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      selectedColor: colorScheme.onSecondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }

  static SwitchThemeData _getSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceContainerHighest;
      }),
    );
  }

  static CheckboxThemeData _getCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static RadioThemeData _getRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
    );
  }

  static SliderThemeData _getSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(color: colorScheme.onInverseSurface),
    );
  }

  static ProgressIndicatorThemeData _getProgressIndicatorTheme(
      ColorScheme colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
    );
  }

  static SnackBarThemeData _getSnackBarTheme(
      ColorScheme colorScheme, AppColorExtension colorExtension) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    );
  }

  static DialogThemeData _getDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 6,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static BottomSheetThemeData _getBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 1,
      modalElevation: 1,
      shadowColor: colorScheme.shadow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  static PopupMenuThemeData _getPopupMenuTheme(ColorScheme colorScheme) {
    return PopupMenuThemeData(
      color: colorScheme.surfaceContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 3,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      textStyle: TextStyle(color: colorScheme.onSurface),
    );
  }

  static TooltipThemeData _getTooltipTheme(ColorScheme colorScheme) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      textStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.all(0),
      verticalOffset: 24,
      preferBelow: true,
    );
  }
}
