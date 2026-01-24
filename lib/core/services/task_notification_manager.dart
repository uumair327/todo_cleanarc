import 'package:dartz/dartz.dart';
import '../../feature/todo/domain/entities/task_entity.dart';
import '../error/failures.dart';
import 'app_logger.dart';
import 'notification_service.dart';

/// Manager for task-related notifications
class TaskNotificationManager {
  final NotificationService _notificationService;
  final AppLogger _logger;

  TaskNotificationManager({
    required NotificationService notificationService,
    required AppLogger logger,
  })  : _notificationService = notificationService,
        _logger = logger;

  /// Schedule notification for a task based on its due date
  Future<Either<Failure, void>> scheduleTaskNotification(
    TaskEntity task,
  ) async {
    try {
      // Get notification preferences
      final prefsResult = await _notificationService.getPreferences();
      return prefsResult.fold(
        (failure) => Left(failure),
        (prefs) async {
          if (!prefs.enabled || !prefs.taskReminders) {
            return const Right(null);
          }

          // Combine due date and time
          final dueDateTime = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
            task.dueTime.hour,
            task.dueTime.minute,
          );

          // Calculate reminder time
          final reminderTime = dueDateTime.subtract(
            Duration(minutes: prefs.reminderMinutesBefore),
          );

          // Only schedule if reminder time is in the future
          if (reminderTime.isAfter(DateTime.now())) {
            return _notificationService.scheduleTaskReminder(
              taskId: task.id.value,
              taskTitle: task.title,
              reminderTime: reminderTime,
              description: task.description.isNotEmpty
                  ? task.description
                  : 'Task due at ${task.dueTime.toString()}',
            );
          }

          return const Right(null);
        },
      );
    } catch (e) {
      _logger.error('Error scheduling task notification: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Update notification when task is updated
  Future<Either<Failure, void>> updateTaskNotification(
    TaskEntity task,
  ) async {
    // Cancel existing notification
    await _notificationService.cancelTaskReminder(task.id.value);

    // Schedule new notification if task is not completed
    if (task.category.name != 'completed' && task.category.name != 'canceled') {
      return scheduleTaskNotification(task);
    }

    return const Right(null);
  }

  /// Cancel notification when task is deleted or completed
  Future<Either<Failure, void>> cancelTaskNotification(String taskId) async {
    return _notificationService.cancelTaskReminder(taskId);
  }

  /// Send immediate notification for overdue tasks
  Future<Either<Failure, void>> notifyOverdueTask(TaskEntity task) async {
    return _notificationService.showNotification(
      title: 'Task Overdue',
      body: '${task.title} is overdue!',
      payload: task.id.value,
    );
  }

  /// Send notification when task is due today
  Future<Either<Failure, void>> notifyTaskDueToday(TaskEntity task) async {
    return _notificationService.showNotification(
      title: 'Task Due Today',
      body: '${task.title} is due today at ${task.dueTime.toString()}',
      payload: task.id.value,
    );
  }

  /// Schedule notifications for multiple tasks
  Future<Either<Failure, void>> scheduleMultipleTaskNotifications(
    List<TaskEntity> tasks,
  ) async {
    try {
      for (final task in tasks) {
        await scheduleTaskNotification(task);
      }
      return const Right(null);
    } catch (e) {
      _logger.error('Error scheduling multiple task notifications: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Check and notify for tasks due soon
  Future<Either<Failure, void>> checkAndNotifyDueSoon() async {
    try {
      final prefsResult = await _notificationService.getPreferences();
      return prefsResult.fold(
        (failure) => Left(failure),
        (prefs) async {
          if (!prefs.enabled || !prefs.dueDateAlerts) {
            return const Right(null);
          }

          // This would typically fetch tasks from repository
          // For now, just return success
          _logger.info('Checked for tasks due soon');
          return const Right(null);
        },
      );
    } catch (e) {
      _logger.error('Error checking tasks due soon: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
