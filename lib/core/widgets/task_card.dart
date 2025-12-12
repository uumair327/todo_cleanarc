import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final int progressPercentage;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.progressPercentage,
    this.dueDate,
    this.dueTime,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(category);
    final categoryLightColor = AppColors.getCategoryLightColor(category);
    
    return Dismissible(
      key: Key(title + DateTime.now().millisecondsSinceEpoch.toString()),
      background: _buildSwipeBackground(
        color: AppColors.completed,
        icon: Icons.check,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.error,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
        } else if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.taskCardMinHeight,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and category chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.h6.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    CategoryChip(
                      category: category,
                      size: CategoryChipSize.small,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Description
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                
                // Due date and time
                if (dueDate != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: AppDimensions.iconSizeSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _formatDueDateTime(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                
                // Progress bar and percentage
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '$progressPercentage%',
                                style: AppTypography.labelSmall.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          LinearProgressIndicator(
                            value: progressPercentage / 100,
                            backgroundColor: categoryLightColor,
                            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                            minHeight: AppDimensions.progressBarHeight,
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        iconSize: AppDimensions.iconSizeSmall,
                        color: AppColors.textSecondary,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Icon(
            icon,
            color: AppColors.textOnPrimary,
            size: AppDimensions.iconSizeLarge,
          ),
        ),
      ),
    );
  }

  String _formatDueDateTime() {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    
    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
    }
    
    if (dueTime != null) {
      final hour = dueTime!.hour;
      final minute = dueTime!.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final timeStr = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      return '$dateStr at $timeStr';
    }
    
    return dateStr;
  }
}

enum CategoryChipSize { small, medium, large }

class CategoryChip extends StatelessWidget {
  final String category;
  final CategoryChipSize size;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.size = CategoryChipSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(category);
    final categoryLightColor = AppColors.getCategoryLightColor(category);
    
    double fontSize;
    EdgeInsets padding;
    
    switch (size) {
      case CategoryChipSize.small:
        fontSize = 10;
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        );
        break;
      case CategoryChipSize.medium:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
        break;
      case CategoryChipSize.large:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
        break;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: categoryLightColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          _formatCategoryName(category),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: categoryColor,
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'ongoing':
        return 'Ongoing';
      case 'in_process':
      case 'inprocess':
        return 'In Process';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      default:
        return category;
    }
  }
}