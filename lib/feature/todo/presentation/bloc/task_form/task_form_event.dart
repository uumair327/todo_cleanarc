import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../../../core/domain/enums/task_enums.dart';


abstract class TaskFormEvent extends Equatable {
  const TaskFormEvent();

  @override
  List<Object?> get props => [];
}

class TaskFormInitialized extends TaskFormEvent {
  final TaskEntity? task; // null for create, TaskEntity for edit

  const TaskFormInitialized({this.task});

  @override
  List<Object?> get props => [task];
}

class TaskFormLoadById extends TaskFormEvent {
  final String taskId;

  const TaskFormLoadById(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskFormTitleChanged extends TaskFormEvent {
  final String title;

  const TaskFormTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class TaskFormDescriptionChanged extends TaskFormEvent {
  final String description;

  const TaskFormDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class TaskFormDueDateChanged extends TaskFormEvent {
  final DateTime dueDate;

  const TaskFormDueDateChanged(this.dueDate);

  @override
  List<Object?> get props => [dueDate];
}

class TaskFormDueTimeChanged extends TaskFormEvent {
  final TimeOfDay dueTime;

  const TaskFormDueTimeChanged(this.dueTime);

  @override
  List<Object?> get props => [dueTime];
}

class TaskFormCategoryChanged extends TaskFormEvent {
  final TaskCategory category;

  const TaskFormCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class TaskFormPriorityChanged extends TaskFormEvent {
  final TaskPriority priority;

  const TaskFormPriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class TaskFormProgressChanged extends TaskFormEvent {
  final int progressPercentage;

  const TaskFormProgressChanged(this.progressPercentage);

  @override
  List<Object?> get props => [progressPercentage];
}

class TaskFormSubmitted extends TaskFormEvent {
  const TaskFormSubmitted();
}

class TaskFormReset extends TaskFormEvent {
  const TaskFormReset();
}