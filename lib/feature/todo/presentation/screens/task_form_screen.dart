import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/domain/enums/task_enums.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_form/task_form_bloc.dart';
import '../bloc/task_form/task_form_event.dart';
import '../bloc/task_form/task_form_state.dart';

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
                        : Colors.white.withOpacity(0.5),
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
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Message
                    if (state.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    // Title Field
                    _buildSectionTitle(AppStrings.taskTitleLabel),
                    CustomTextField(
                      controller: _titleController,
                      hint: AppStrings.taskTitleHint,
                      onChanged: (value) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormTitleChanged(value));
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.titleRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    _buildSectionTitle(AppStrings.descriptionLabel),
                    CustomTextField(
                      controller: _descriptionController,
                      hint: AppStrings.descriptionHint,
                      maxLines: 3,
                      onChanged: (value) {
                        context
                            .read<TaskFormBloc>()
                            .add(TaskFormDescriptionChanged(value));
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.descriptionRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Due Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(AppStrings.dueDateLabel),
                              _buildDateSelector(state),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(AppStrings.dueTimeLabel),
                              _buildTimeSelector(state),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Category Selection
                    _buildSectionTitle(AppStrings.categoryLabel),
                    _buildCategorySelector(state),
                    const SizedBox(height: 20),

                    // Priority Selection
                    _buildSectionTitle(AppStrings.priorityLabel),
                    _buildPrioritySelector(state),
                    const SizedBox(height: 20),

                    // Progress Slider (only for edit mode)
                    if (state.isEditing) ...[
                      _buildSectionTitle(AppStrings.progressLabel),
                      _buildProgressSlider(state),
                      const SizedBox(height: 20),
                    ],

                    // Submit Button
                    const SizedBox(height: 32),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTheme.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateSelector(TaskFormState state) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: state.dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (date != null && mounted) {
          context.read<TaskFormBloc>().add(TaskFormDueDateChanged(date));
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              '${state.dueDate.day}/${state.dueDate.month}/${state.dueDate.year}',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(TaskFormState state) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: state.dueTime,
        );
        if (time != null && mounted) {
          context.read<TaskFormBloc>().add(TaskFormDueTimeChanged(time));
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              state.dueTime.format(context),
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(TaskFormState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskCategory.values.map((category) {
        final isSelected = state.category == category;
        final color = _getCategoryColor(category);

        return InkWell(
          onTap: () {
            context.read<TaskFormBloc>().add(TaskFormCategoryChanged(category));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getCategoryDisplayName(category),
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(TaskFormState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskPriority.values.map((priority) {
        final isSelected = state.priority == priority;
        final color = _getPriorityColor(priority);

        return InkWell(
          onTap: () {
            context.read<TaskFormBloc>().add(TaskFormPriorityChanged(priority));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getPriorityDisplayName(priority),
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 8),
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
