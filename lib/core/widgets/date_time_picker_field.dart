import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Date picker field with consistent styling.
///
/// Follows Single Responsibility Principle - handles only date selection UI.
class DatePickerField extends StatelessWidget {
  /// Current date value
  final DateTime value;

  /// Label for the field
  final String? label;

  /// First selectable date
  final DateTime? firstDate;

  /// Last selectable date
  final DateTime? lastDate;

  /// Callback when date changes
  final ValueChanged<DateTime>? onChanged;

  /// Whether the field is enabled
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.value,
    this.label,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showDatePicker(context) : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: _buildInputDecorator(
        context,
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: AppDimensions.iconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.mdSm),
            Text(
              _formatDate(value),
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color:
                    enabled ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputDecorator(BuildContext context, {required Widget child}) {
    return InputDecorator(
      decoration: InputDecoration(
        label: _buildLabel(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: child,
    );
  }

  Widget? _buildLabel() {
    if (label == null) return null;

    if (label!.contains('*')) {
      final parts = label!.split('*');
      return RichText(
        text: TextSpan(
          text: parts[0],
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '*',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts.sublist(1).join('*'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      );
    }

    return Text(
      label!,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2030),
    );

    if (date != null && onChanged != null) {
      onChanged!(date);
    }
  }
}

/// Time picker field with consistent styling.
///
/// Follows Single Responsibility Principle - handles only time selection UI.
class TimePickerField extends StatelessWidget {
  /// Current time value
  final TimeOfDay value;

  /// Label for the field
  final String? label;

  /// Callback when time changes
  final ValueChanged<TimeOfDay>? onChanged;

  /// Whether the field is enabled
  final bool enabled;

  const TimePickerField({
    super.key,
    required this.value,
    this.label,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showTimePicker(context) : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: _buildInputDecorator(
        context,
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: AppDimensions.iconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.mdSm),
            Text(
              value.format(context),
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color:
                    enabled ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputDecorator(BuildContext context, {required Widget child}) {
    return InputDecorator(
      decoration: InputDecoration(
        label: _buildLabel(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: child,
    );
  }

  Widget? _buildLabel() {
    if (label == null) return null;

    if (label!.contains('*')) {
      final parts = label!.split('*');
      return RichText(
        text: TextSpan(
          text: parts[0],
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '*',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts.sublist(1).join('*'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      );
    }

    return Text(
      label!,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: value,
    );

    if (time != null && onChanged != null) {
      onChanged!(time);
    }
  }
}
