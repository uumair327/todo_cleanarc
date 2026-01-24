import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../theme/app_spacing.dart';

/// Error banner widget for displaying error messages.
///
/// Provides consistent error styling across the application.
class ErrorBanner extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional callback when the banner is dismissed
  final VoidCallback? onDismiss;

  /// Whether to show a close button
  final bool showCloseButton;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdSm),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppDimensions.iconSize,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (showCloseButton && onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: AppDimensions.iconSizeSmall),
              color: AppColors.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
