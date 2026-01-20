import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glimfo_todo/core/theme/app_theme.dart';
import 'package:glimfo_todo/core/theme/app_typography.dart';
import 'package:glimfo_todo/core/theme/app_spacing.dart';
import 'package:glimfo_todo/core/utils/app_colors.dart';

import 'property_test_runner.dart';
import 'property_test_config.dart';

void main() {
  group('UI Theme Consistency Property Tests', () {
    
    /// **Feature: flutter-todo-app, Property 7: UI theme consistency**
    /// **Validates: Requirements 8.1, 8.3, 8.4**
    PropertyTestRunner.runProperty(
      description: 'Theme colors are consistent across all category types',
      property: () {
        // Test that category colors match the specification (Requirement 8.3)
        // Blue for Ongoing, Yellow for In Process, Green for Completed, Red for Canceled
        
        final ongoingColor = AppColors.getCategoryColor('ongoing');
        final inProcessColor = AppColors.getCategoryColor('in_process');
        final completedColor = AppColors.getCategoryColor('completed');
        final canceledColor = AppColors.getCategoryColor('canceled');
        
        // Verify colors match expected values from requirements
        final ongoingIsBlue = ongoingColor == const Color(0xFF2196F3);
        final inProcessIsYellow = inProcessColor == const Color(0xFFFFC107);
        final completedIsGreen = completedColor == const Color(0xFF4CAF50);
        final canceledIsRed = canceledColor == const Color(0xFFF44336);
        
        return ongoingIsBlue && inProcessIsYellow && completedIsGreen && canceledIsRed;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Typography styles maintain consistent font sizes and weights',
      property: () {
        // Verify typography consistency (Requirement 8.1)
        
        // Heading styles should have decreasing font sizes
        final h1Size = AppTypography.h1.fontSize ?? 0;
        final h2Size = AppTypography.h2.fontSize ?? 0;
        final h3Size = AppTypography.h3.fontSize ?? 0;
        final h4Size = AppTypography.h4.fontSize ?? 0;
        final h5Size = AppTypography.h5.fontSize ?? 0;
        final h6Size = AppTypography.h6.fontSize ?? 0;
        
        final headingSizesDescending = h1Size > h2Size && 
                                       h2Size > h3Size && 
                                       h3Size > h4Size && 
                                       h4Size > h5Size && 
                                       h5Size > h6Size;
        
        // Body text styles should have consistent hierarchy
        final bodyLargeSize = AppTypography.bodyLarge.fontSize ?? 0;
        final bodyMediumSize = AppTypography.bodyMedium.fontSize ?? 0;
        final bodySmallSize = AppTypography.bodySmall.fontSize ?? 0;
        
        final bodySizesDescending = bodyLargeSize >= bodyMediumSize && 
                                    bodyMediumSize >= bodySmallSize;
        
        // Label styles should have consistent hierarchy
        final labelLargeSize = AppTypography.labelLarge.fontSize ?? 0;
        final labelMediumSize = AppTypography.labelMedium.fontSize ?? 0;
        final labelSmallSize = AppTypography.labelSmall.fontSize ?? 0;
        
        final labelSizesDescending = labelLargeSize >= labelMediumSize && 
                                     labelMediumSize >= labelSmallSize;
        
        return headingSizesDescending && bodySizesDescending && labelSizesDescending;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Spacing values follow consistent base-8 system',
      property: () {
        // Verify spacing consistency (Requirement 8.4)
        
        // All spacing values should be multiples of the base unit (8.0)
        final base = AppSpacing.base;
        
        final spacingValues = [
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ];
        
        // Check that all spacing values are multiples of base or half-base
        for (final spacing in spacingValues) {
          final isMultipleOfHalfBase = (spacing % (base / 2)) == 0;
          if (!isMultipleOfHalfBase) return false;
        }
        
        // Verify spacing values are in ascending order
        for (int i = 0; i < spacingValues.length - 1; i++) {
          if (spacingValues[i] >= spacingValues[i + 1]) return false;
        }
        
        return true;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Border radius values maintain consistent rounded design',
      property: () {
        // Verify border radius consistency (Requirement 8.4)
        
        final radiusValues = [
          AppDimensions.radiusXs,
          AppDimensions.radiusSm,
          AppDimensions.radiusMd,
          AppDimensions.radiusLg,
          AppDimensions.radiusXl,
        ];
        
        // Verify radius values are in ascending order
        for (int i = 0; i < radiusValues.length - 1; i++) {
          if (radiusValues[i] >= radiusValues[i + 1]) return false;
        }
        
        // Verify all radius values are positive
        for (final radius in radiusValues) {
          if (radius <= 0) return false;
        }
        
        // Verify round radius is larger than all others
        final allSmallerThanRound = radiusValues.every(
          (radius) => radius < AppDimensions.radiusRound
        );
        
        return allSmallerThanRound;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Theme applies consistent colors to Material components',
      property: () {
        // Verify theme color consistency (Requirement 8.1)
        
        final theme = AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;
        
        // Primary colors should match AppColors
        final primaryMatches = colorScheme.primary == AppColors.primary;
        final secondaryMatches = colorScheme.secondary == AppColors.secondary;
        final surfaceMatches = colorScheme.surface == AppColors.surface;
        final errorMatches = colorScheme.error == AppColors.error;
        
        // Text colors should be consistent
        final onPrimaryMatches = colorScheme.onPrimary == AppColors.textOnPrimary;
        final onSurfaceMatches = colorScheme.onSurface == AppColors.textPrimary;
        
        return primaryMatches && 
               secondaryMatches && 
               surfaceMatches && 
               errorMatches &&
               onPrimaryMatches && 
               onSurfaceMatches;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Card theme uses rounded corners and soft shadows',
      property: () {
        // Verify card styling consistency (Requirement 8.4)
        
        final theme = AppTheme.lightTheme;
        final cardTheme = theme.cardTheme;
        
        // Card should have elevation (soft shadow)
        final hasElevation = (cardTheme.elevation ?? 0) > 0;
        
        // Card should have rounded corners
        final shape = cardTheme.shape;
        final hasRoundedCorners = shape is RoundedRectangleBorder;
        
        // Card should use surface color
        final usesSurfaceColor = cardTheme.color == AppColors.surface;
        
        // Card should have shadow color
        final hasShadowColor = cardTheme.shadowColor == AppColors.shadow;
        
        return hasElevation && 
               hasRoundedCorners && 
               usesSurfaceColor && 
               hasShadowColor;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Input decoration theme maintains consistent styling',
      property: () {
        // Verify input field styling consistency (Requirement 8.4, 8.5)
        
        final theme = AppTheme.lightTheme;
        final inputTheme = theme.inputDecorationTheme;
        
        // Input should have filled background
        final isFilled = inputTheme.filled ?? false;
        
        // Input should use surface color
        final usesSurfaceColor = inputTheme.fillColor == AppColors.surface;
        
        // Borders should have rounded corners
        final border = inputTheme.border;
        final hasRoundedBorder = border is OutlineInputBorder;
        
        // Focus border should use primary color
        final focusedBorder = inputTheme.focusedBorder;
        final usesPrimaryOnFocus = focusedBorder is OutlineInputBorder && 
                                   focusedBorder.borderSide.color == AppColors.primary;
        
        // Error border should use error color
        final errorBorder = inputTheme.errorBorder;
        final usesErrorColor = errorBorder is OutlineInputBorder && 
                               errorBorder.borderSide.color == AppColors.error;
        
        return isFilled && 
               usesSurfaceColor && 
               hasRoundedBorder && 
               usesPrimaryOnFocus && 
               usesErrorColor;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Button theme maintains consistent styling and dimensions',
      property: () {
        // Verify button styling consistency (Requirement 8.4, 8.5)
        
        final theme = AppTheme.lightTheme;
        
        // Elevated button should use primary color
        final elevatedButtonStyle = theme.elevatedButtonTheme.style;
        final elevatedBgColor = elevatedButtonStyle?.backgroundColor?.resolve({});
        final usesPrimaryColor = elevatedBgColor == AppColors.primary;
        
        // Elevated button should have rounded corners
        final elevatedShape = elevatedButtonStyle?.shape?.resolve({});
        final hasRoundedShape = elevatedShape is RoundedRectangleBorder;
        
        // Elevated button should have minimum height
        final elevatedMinSize = elevatedButtonStyle?.minimumSize?.resolve({});
        final hasMinHeight = (elevatedMinSize?.height ?? 0) >= AppDimensions.buttonHeight;
        
        // Text button should use primary color for text
        final textButtonStyle = theme.textButtonTheme.style;
        final textButtonColor = textButtonStyle?.foregroundColor?.resolve({});
        final textUsesPrimaryColor = textButtonColor == AppColors.primary;
        
        // Outlined button should have border with primary color
        final outlinedButtonStyle = theme.outlinedButtonTheme.style;
        final outlinedBorderSide = outlinedButtonStyle?.side?.resolve({});
        final outlinedUsesPrimaryBorder = outlinedBorderSide?.color == AppColors.primary;
        
        return usesPrimaryColor && 
               hasRoundedShape && 
               hasMinHeight && 
               textUsesPrimaryColor && 
               outlinedUsesPrimaryBorder;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Category light colors are lighter variants of base colors',
      property: () {
        // Verify category color relationships (Requirement 8.3)
        
        final categories = ['ongoing', 'in_process', 'completed', 'canceled'];
        
        for (final category in categories) {
          final baseColor = AppColors.getCategoryColor(category);
          final lightColor = AppColors.getCategoryLightColor(category);
          
          // Light color should have higher luminance than base color
          final baseLuminance = baseColor.computeLuminance();
          final lightLuminance = lightColor.computeLuminance();
          
          if (lightLuminance <= baseLuminance) return false;
        }
        
        return true;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );

    PropertyTestRunner.runProperty(
      description: 'Icon sizes maintain consistent hierarchy',
      property: () {
        // Verify icon size consistency (Requirement 8.4)
        
        final iconSizeSmall = AppDimensions.iconSizeSmall;
        final iconSize = AppDimensions.iconSize;
        final iconSizeLarge = AppDimensions.iconSizeLarge;
        
        // Icon sizes should be in ascending order
        final sizesAscending = iconSizeSmall < iconSize && iconSize < iconSizeLarge;
        
        // All icon sizes should be positive
        final allPositive = iconSizeSmall > 0 && iconSize > 0 && iconSizeLarge > 0;
        
        // Theme icon size should match standard icon size
        final theme = AppTheme.lightTheme;
        final themeIconSize = theme.iconTheme.size ?? 0;
        final themeMatchesStandard = themeIconSize == iconSize;
        
        return sizesAscending && allPositive && themeMatchesStandard;
      },
      iterations: PropertyTestConfig.getSettingsFor('ui_consistency').iterations,
      seed: PropertyTestConfig.getSettingsFor('ui_consistency').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 7,
      propertyText: 'UI theme consistency',
      validates: 'Requirements 8.1, 8.3, 8.4',
    );
  });
}
