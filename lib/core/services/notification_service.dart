import 'package:dartz/dartz.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/entities/task_reminder.dart';
import '../error/failures.dart';

/// Abstract interface for notification service
abstract class NotificationService {
  /// Initialize the notification service
  Future<Either<Failure, void>> initialize();

  /// Request notification permissions
  Future<Either<Failure, bool>> requestPermissions();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Schedule a task reminder notification
  Future<Either<Failure, void>> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
    String? description,
  });

  /// Cancel a specific task reminder
  Future<Either<Failure, void>> cancelTaskReminder(String taskId);

  /// Cancel all scheduled notifications
  Future<Either<Failure, void>> cancelAllNotifications();

  /// Schedule daily summary notification
  Future<Either<Failure, void>> scheduleDailySummary({
    required String time, // Format: "HH:mm"
  });

  /// Cancel daily summary notification
  Future<Either<Failure, void>> cancelDailySummary();

  /// Show immediate notification
  Future<Either<Failure, void>> showNotification({
    required String title,
    required String body,
    String? payload,
  });

  /// Get all scheduled reminders
  Future<Either<Failure, List<TaskReminder>>> getScheduledReminders();

  /// Update notification preferences
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences preferences,
  );

  /// Get current notification preferences
  Future<Either<Failure, NotificationPreferences>> getPreferences();
}
