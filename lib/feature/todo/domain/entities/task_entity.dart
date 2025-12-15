import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/domain/enums/task_enums.dart';

/// Pure Dart time representation for domain layer.
/// Avoids Flutter dependency (TimeOfDay).
class DomainTime extends Equatable {
  final int hour;
  final int minute;

  const DomainTime({required this.hour, required this.minute});

  @override
  List<Object> get props => [hour, minute];

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class TaskEntity extends Equatable {
  final TaskId id;
  final UserId userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final DomainTime dueTime;
  final TaskCategory category;
  final TaskPriority priority;
  final int progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.category,
    required this.priority,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  TaskEntity copyWith({
    TaskId? id,
    UserId? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    DomainTime? dueTime,
    TaskCategory? category,
    TaskPriority? priority,
    int? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object> get props => [
        id,
        userId,
        title,
        description,
        dueDate,
        dueTime,
        category,
        priority,
        progressPercentage,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}