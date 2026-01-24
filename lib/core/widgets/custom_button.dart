import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Button style variants following the design system.
enum ButtonVariant { 
  /// Filled button with primary color (default)
  primary, 
  /// Filled button with secondary color
  secondary, 
  /// Button with border and no fill
  outlined, 
  /// Text-only button with no border or fill
  text 
}

/// Button size variants.
enum ButtonSize { 
  /// Small button (32px height)
  small, 
  /// Medium button (40px height, default)
  medium, 
  /// Large button (48px height)
  large 
}

/// A customizable button widget following the app's design system.
///
/// This widget provides a consistent button implementation across the app
/// with support for different variants, sizes, loading states, and icons.
///
/// **Features:**
/// - Multiple style variants (primary, secondary, outlined, text)
/// - Three size options (small, medium, large)
/// - Loading state with spinner
/// - Optional leading icon
/// - Full-width or auto-width
/// - Custom colors support
///
/// **Usage Examples:**
/// ```dart
/// // Primary button (default)
/// CustomButton(
///   text: 'Save Task',
///   onPressed: () => saveTask(),
/// )
///
/// // Outlined button with icon
/// CustomButton(
///   text: 'Delete',
///   variant: ButtonVariant.outlined,
///   icon: Icon(Icons.delete),
///   onPressed: () => deleteTask(),
/// )
///
/// // Loading state
/// CustomButton(
///   text: 'Saving...',
///   isLoading: true,
///   onPressed: () => saveTask(),
/// )
///
/// // Small text button
/// CustomButton(
///   text: 'Cancel',
///   variant: ButtonVariant.text,
///   size: ButtonSize.small,
///   isFullWidth: false,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class CustomButton extends StatelessWidget {
  /// The text to display on the button.
  final String text;
  
  /// Callback when the button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;
  
  /// The visual style variant of the button.
  final ButtonVariant variant;
  
  /// The size of the button.
  final ButtonSize size;
  
  /// Optional icon to display before the text.
  final Widget? icon;
  
  /// Whether to show a loading spinner instead of the icon.
  final bool isLoading;
  
  /// Whether the button should take full width of its parent.
  final bool isFullWidth;
  
  /// Custom background color (overrides variant color).
  final Color? backgroundColor;
  
  /// Custom foreground/text color (overrides variant color).
  final Color? foregroundColor;
  
  /// Custom padding (overrides size padding).
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonChild = _buildButtonChild();

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      case ButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }
  }

  ButtonStyle _getButtonStyle() {
    final (height, textStyle, buttonPadding) = _getSizeProperties();

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
          elevation: 2.0,
          shadowColor: AppColors.shadow,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          textStyle: textStyle,
          padding: padding ?? buttonPadding,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
          foregroundColor: foregroundColor ?? AppColors.textPrimary,
          elevation: 1.0,
          shadowColor: AppColors.shadowLight,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          textStyle: textStyle,
          padding: padding ?? buttonPadding,
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primary,
          side: BorderSide(
            color: backgroundColor ?? AppColors.primary,
            width: 1.5,
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          textStyle: textStyle,
          padding: padding ?? buttonPadding,
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primary,
          textStyle: textStyle,
          padding: padding ?? buttonPadding,
        );
    }
  }

  (double, TextStyle, EdgeInsets) _getSizeProperties() {
    switch (size) {
      case ButtonSize.small:
        return (
          36.0, // height
          AppTypography.labelMedium,
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        );
      case ButtonSize.medium:
        return (
          48.0, // height
          AppTypography.button,
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        );
      case ButtonSize.large:
        return (
          56.0, // height
          AppTypography.buttonLarge,
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppDimensions.iconSizeSmall,
            height: AppDimensions.iconSizeSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.primary
                    ? AppColors.textOnPrimary
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

// Specialized button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class OutlinedCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  const OutlinedCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class TextCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final ButtonSize size;

  const TextCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.text,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: false,
    );
  }
}

// Floating Action Button variant
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
      mini: mini,
      elevation: 2.0,
      child: icon,
    );
  }
}
