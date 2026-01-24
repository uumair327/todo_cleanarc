import 'package:equatable/equatable.dart';

/// Entity representing a scheduled task reminder
class TaskReminder extends Equatable {
  final String id;
  final String taskId;
  final String taskTitle;
  final DateTime scheduledTime;
  final bool isActive;
  final DateTime createdAt;

  const TaskReminder({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.scheduledTime,
    required this.isActive,
    required this.createdAt,
  });

  TaskReminder copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    DateTime? scheduledTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TaskReminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskTitle,
        scheduledTime,
        isActive,
        createdAt,
      ];
}
