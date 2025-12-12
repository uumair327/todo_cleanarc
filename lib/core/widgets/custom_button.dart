import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, outlined, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
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
            borderRadius: BorderRadius.circular(8.0),
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
            borderRadius: BorderRadius.circular(8.0),
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
            borderRadius: BorderRadius.circular(8.0),
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
            width: 16,
            height: 16,
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