import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/domain/enums/task_enums.dart';
import '../../domain/entities/search_filter.dart';

class AdvancedFilterPanel extends StatefulWidget {
  final SearchFilter currentFilter;
  final Function(SearchFilter) onFilterChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onSaveSearch;

  const AdvancedFilterPanel({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onClearFilters,
    required this.onSaveSearch,
  });

  @override
  State<AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<AdvancedFilterPanel> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  void didUpdateWidget(AdvancedFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilter != widget.currentFilter) {
      _filter = widget.currentFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: widget.onSaveSearch,
                    icon: const Icon(Icons.bookmark_add, size: 18),
                    label: const Text('Save'),
                  ),
                  TextButton.icon(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateFilters(),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryFilter(),
          const SizedBox(height: AppSpacing.md),
          _buildPriorityFilter(),
          const SizedBox(height: AppSpacing.md),
          _buildProgressFilter(),
          const SizedBox(height: AppSpacing.md),
          _buildCompletionFilter(),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            'Start Date',
            _filter.startDate,
            (date) {
              setState(() {
                _filter = _filter.copyWith(startDate: date);
              });
              widget.onFilterChanged(_filter);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildDateButton(
            'End Date',
            _filter.endDate,
            (date) {
              setState(() {
                _filter = _filter.copyWith(endDate: date);
              });
              widget.onFilterChanged(_filter);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onDateSelected(null),
                child: const Icon(Icons.clear, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: AppTheme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: TaskCategory.values.map((category) {
            final isSelected = _filter.categories?.contains(category) ?? false;
            return FilterChip(
              label: Text(_getCategoryLabel(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final categories = List<TaskCategory>.from(_filter.categories ?? []);
                  if (selected) {
                    categories.add(category);
                  } else {
                    categories.remove(category);
                  }
                  _filter = _filter.copyWith(
                    categories: categories.isEmpty ? null : categories,
                  );
                });
                widget.onFilterChanged(_filter);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priorities', style: AppTheme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: TaskPriority.values.map((priority) {
            final isSelected = _filter.priorities?.contains(priority) ?? false;
            return FilterChip(
              label: Text(_getPriorityLabel(priority)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final priorities = List<TaskPriority>.from(_filter.priorities ?? []);
                  if (selected) {
                    priorities.add(priority);
                  } else {
                    priorities.remove(priority);
                  }
                  _filter = _filter.copyWith(
                    priorities: priorities.isEmpty ? null : priorities,
                  );
                });
                widget.onFilterChanged(_filter);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress Range', style: AppTheme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final progress = int.tryParse(value);
                  if (progress != null && progress >= 0 && progress <= 100) {
                    setState(() {
                      _filter = _filter.copyWith(minProgress: progress);
                    });
                    widget.onFilterChanged(_filter);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final progress = int.tryParse(value);
                  if (progress != null && progress >= 0 && progress <= 100) {
                    setState(() {
                      _filter = _filter.copyWith(maxProgress: progress);
                    });
                    widget.onFilterChanged(_filter);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionFilter() {
    return Row(
      children: [
        Text('Completion Status', style: AppTheme.textTheme.titleSmall),
        const SizedBox(width: AppSpacing.md),
        ChoiceChip(
          label: const Text('All'),
          selected: _filter.isCompleted == null,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(clearCompleted: true);
              });
              widget.onFilterChanged(_filter);
            }
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        ChoiceChip(
          label: const Text('Completed'),
          selected: _filter.isCompleted == true,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(isCompleted: true);
            });
            widget.onFilterChanged(_filter);
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        ChoiceChip(
          label: const Text('Incomplete'),
          selected: _filter.isCompleted == false,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(isCompleted: false);
            });
            widget.onFilterChanged(_filter);
          },
        ),
      ],
    );
  }

  String _getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return 'Ongoing';
      case TaskCategory.completed:
        return 'Completed';
      case TaskCategory.inProcess:
        return 'In Process';
      case TaskCategory.canceled:
        return 'Canceled';
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}
