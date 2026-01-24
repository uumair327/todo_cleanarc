import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../theme/app_spacing.dart';

/// A generic chip group selector following Open/Closed Principle.
///
/// Can be used to select from any list of items (categories, priorities, etc.)
/// with customizable label and color builders.
class SelectionChipGroup<T> extends StatelessWidget {
  /// List of items to display as chips
  final List<T> items;

  /// Currently selected item
  final T? selectedItem;

  /// Callback when an item is selected
  final ValueChanged<T>? onSelected;

  /// Function to build the display label for each item
  final String Function(T item) labelBuilder;

  /// Function to build the color for each item
  final Color Function(T item) colorBuilder;

  /// Spacing between chips
  final double spacing;

  /// Run spacing between chip rows
  final double runSpacing;

  const SelectionChipGroup({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.colorBuilder,
    this.selectedItem,
    this.onSelected,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) => _buildChip(item)).toList(),
    );
  }

  Widget _buildChip(T item) {
    final isSelected = selectedItem == item;
    final color = colorBuilder(item);

    return InkWell(
      onTap: onSelected != null ? () => onSelected!(item) : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          labelBuilder(item),
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// A single selection chip used internally by SelectionChipGroup
class SelectionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionChip({
    super.key,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
