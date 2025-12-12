import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../../../core/domain/enums/task_enums.dart';

class TaskFormState extends Equatable {
  final bool isEditing;
  final TaskEntity? originalTask;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final TaskCategory category;
  final TaskPriority priority;
  final int progressPercentage;
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;
  final bool isSubmissionSuccess;

  const TaskFormState({
    this.isEditing = false,
    this.originalTask,
    this.title = '',
    this.description = '',
    DateTime? dueDate,
    TimeOfDay? dueTime,
    this.category = TaskCategory.ongoing,
    this.priority = TaskPriority.medium,
    this.progressPercentage = 0,
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
    this.isSubmissionSuccess = false,
  })  : dueDate = dueDate ?? DateTime.now(),
        dueTime = dueTime ?? const TimeOfDay(hour: 9, minute: 0);

  @override
  List<Object?> get props => [
        isEditing,
        originalTask,
        title,
        description,
        dueDate,
        dueTime,
        category,
        priority,
        progressPercentage,
        isLoading,
        isValid,
        errorMessage,
        isSubmissionSuccess,
      ];

  TaskFormState copyWith({
    bool? isEditing,
    TaskEntity? originalTask,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    TaskCategory? category,
    TaskPriority? priority,
    int? progressPercentage,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool? isSubmissionSuccess,
    bool clearError = false,
  }) {
    return TaskFormState(
      isEditing: isEditing ?? this.isEditing,
      originalTask: originalTask ?? this.originalTask,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmissionSuccess: isSubmissionSuccess ?? this.isSubmissionSuccess,
    );
  }

  bool get _isTitleValid => title.trim().isNotEmpty;
  bool get _isDescriptionValid => description.trim().isNotEmpty;
  bool get _isProgressValid => progressPercentage >= 0 && progressPercentage <= 100;

  TaskFormState validateForm() {
    final isFormValid = _isTitleValid && _isDescriptionValid && _isProgressValid;
    return copyWith(isValid: isFormValid);
  }
}