import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/domain/enums/task_enums.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_form/task_form_bloc.dart';
import '../bloc/task_form/task_form_event.dart';
import '../bloc/task_form/task_form_state.dart';

/// TaskForm screen using reusable widgets for consistent UI.
///
/// Follows SOLID principles by delegating UI concerns to specialized widgets.
class TaskFormScreen extends StatefulWidget {
  final TaskEntity? task; // null for create, TaskEntity for edit
  final String? taskId; // Task ID for edit mode

  const TaskFormScreen({
    super.key,
    this.task,
    this.taskId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with task or taskId for edit mode
    if (widget.task != null) {
      context.read<TaskFormBloc>().add(TaskFormInitialized(task: widget.task));
    } else if (widget.taskId != null) {
      // Load task by ID for edit mode
      context.read<TaskFormBloc>().add(TaskFormLoadById(widget.taskId!));
    } else {
      // New task mode
      context.read<TaskFormBloc>().add(const TaskFormInitialized());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            widget.task != null ? AppStrings.editTask : AppStrings.createTask),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<TaskFormBloc, TaskFormState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state.isValid && !state.isLoading
                    ? () {
                        context
                            .read<TaskFormBloc>()
                            .add(const TaskFormSubmitted());
                      }
                    : null,
                child: Text(
                  AppStrings.save,
                  style: TextStyle(
                    color: state.isValid && !state.isLoading
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<TaskFormBloc, TaskFormState>(
        listener: (context, state) {
          if (state.isSubmissionSuccess) {
            Navigator.of(context).pop(true); // Return true to indicate success
          }

          // Update controllers when state changes (for edit mode)
          if (_titleController.text != state.title) {
            _titleController.text = state.title;
          }
          if (_descriptionController.text != state.description) {
            _descriptionController.text = state.description;
          }
        },
        child: BlocBuilder<TaskFormBloc, TaskFormState>(
          builder: (context, state) {
            if (state.isLoading && widget.taskId != null) {
              // Show skeleton only when loading an existing task
              return _buildLoadingSkeleton();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Message using ErrorBanner widget
                    if (state.errorMessage != null)
                      ErrorBanner(message: state.errorMessage!),

                    // Title Field
                    CustomTextField(
                      label: AppStrings.taskTitleLabel,
                      controller: _titleController,
                      hint: AppStrings.taskTitleHint,
                      onChanged: (value) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormTitleChanged(value));
                      },
                      validator: ValidationUtils.validateTaskTitle,
                    ),
                    const SizedBox(height: AppSpacing.mdLg),

                    // Description Field
                    CustomTextField(
                      label: AppStrings.descriptionLabel,
                      controller: _descriptionController,
                      hint: AppStrings.descriptionHint,
                      maxLines: 3,
                      onChanged: (value) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormDescriptionChanged(value));
                      },
                      validator: ValidationUtils.validateTaskDescription,
                    ),
                    const SizedBox(height: AppSpacing.mdLg),

                    // Due Date and Time using reusable pickers
                    Row(
                      children: [
                        Expanded(
                          child: DatePickerField(
                            label: AppStrings.dueDateLabel,
                            value: state.dueDate,
                            onChanged: (date) {
                              context
                                  .read<TaskFormBloc>()
                                  .add(TaskFormDueDateChanged(date));
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TimePickerField(
                            label: AppStrings.dueTimeLabel,
                            value: state.dueTime,
                            onChanged: (time) {
                              context
                                  .read<TaskFormBloc>()
                                  .add(TaskFormDueTimeChanged(time));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.mdLg),

                    // Category Selection using SelectionChipGroup
                    const SectionTitle(title: AppStrings.categoryLabel),
                    SelectionChipGroup<TaskCategory>(
                      items: TaskCategory.values,
                      selectedItem: state.category,
                      labelBuilder: _getCategoryDisplayName,
                      colorBuilder: _getCategoryColor,
                      onSelected: (category) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormCategoryChanged(category));
                      },
                    ),
                    const SizedBox(height: AppSpacing.mdLg),

                    // Priority Selection using SelectionChipGroup
                    const SectionTitle(title: AppStrings.priorityLabel),
                    SelectionChipGroup<TaskPriority>(
                      items: TaskPriority.values,
                      selectedItem: state.priority,
                      labelBuilder: _getPriorityDisplayName,
                      colorBuilder: _getPriorityColor,
                      onSelected: (priority) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormPriorityChanged(priority));
                      },
                    ),
                    const SizedBox(height: AppSpacing.mdLg),

                    // Progress Slider (only for edit mode)
                    if (state.isEditing) ...[
                      const SectionTitle(title: AppStrings.progressLabel),
                      _buildProgressSlider(state),
                      const SizedBox(height: AppSpacing.mdLg),
                    ],

                    // Submit Button
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: state.isEditing
                            ? AppStrings.updateTask
                            : AppStrings.createTask,
                        onPressed: state.isValid && !state.isLoading
                            ? () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  context
                                      .read<TaskFormBloc>()
                                      .add(const TaskFormSubmitted());
                                }
                              }
                            : null,
                        isLoading: state.isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field skeleton
          SkeletonLoader(
            width: 80,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          SkeletonLoader(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          const SizedBox(height: AppSpacing.mdLg),

          // Description field skeleton
          SkeletonLoader(
            width: 100,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          SkeletonLoader(
            width: double.infinity,
            height: 96,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          const SizedBox(height: AppSpacing.mdLg),

          // Date and time skeleton
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 70,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonLoader(
                      width: double.infinity,
                      height: 48,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 70,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonLoader(
                      width: double.infinity,
                      height: 48,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.mdLg),

          // Category skeleton
          SkeletonLoader(
            width: 80,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SkeletonLoader(
                  width: 80,
                  height: 32,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.mdLg),

          // Priority skeleton
          SkeletonLoader(
            width: 80,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SkeletonLoader(
                  width: 70,
                  height: 32,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Button skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(TaskFormState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.progressLabel}: ${state.progressPercentage}%',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                '${state.progressPercentage}%',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Slider(
          value: state.progressPercentage.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: AppColors.primary,
          onChanged: (value) {
            context.read<TaskFormBloc>().add(
                  TaskFormProgressChanged(value.round()),
                );
          },
        ),
      ],
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return AppColors.ongoing;
      case TaskCategory.completed:
        return AppColors.completed;
      case TaskCategory.inProcess:
        return AppColors.inProcess;
      case TaskCategory.canceled:
        return AppColors.canceled;
    }
  }

  String _getCategoryDisplayName(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return AppStrings.ongoing;
      case TaskCategory.completed:
        return AppStrings.completed;
      case TaskCategory.inProcess:
        return AppStrings.inProcess;
      case TaskCategory.canceled:
        return AppStrings.canceled;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
      case TaskPriority.critical:
        return Colors.black;
    }
  }

  String _getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppStrings.low;
      case TaskPriority.medium:
        return AppStrings.medium;
      case TaskPriority.high:
        return AppStrings.high;
      case TaskPriority.urgent:
        return AppStrings.urgent;
      case TaskPriority.critical:
        return AppStrings.critical;
    }
  }
}
