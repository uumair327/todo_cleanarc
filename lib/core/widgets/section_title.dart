import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../theme/app_spacing.dart';

/// A consistent section title widget.
///
/// Simple, focused widget following Single Responsibility Principle.
class SectionTitle extends StatelessWidget {
  /// The title text to display
  final String title;

  /// Optional padding around the title
  final EdgeInsets padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: AppTheme.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
