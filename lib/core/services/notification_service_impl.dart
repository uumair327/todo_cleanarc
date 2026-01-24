import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/entities/task_reminder.dart';
import '../error/failures.dart';
import 'app_logger.dart';
import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final SharedPreferences _prefs;
  final AppLogger _logger;

  static const String _prefsKey = 'notification_preferences';
  static const String _remindersKey = 'scheduled_reminders';
  static const int _dailySummaryId = 999999;

  NotificationServiceImpl({
    required FlutterLocalNotificationsPlugin notificationsPlugin,
    required SharedPreferences prefs,
    required AppLogger logger,
  })  : _notificationsPlugin = notificationsPlugin,
        _prefs = prefs,
        _logger = logger;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _logger.info('Notification service initialized successfully');
        return const Right(null);
      } else {
        return Left(CacheFailure(message: 'Failed to initialize notifications'));
      }
    } catch (e) {
      _logger.error('Error initializing notification service: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific task
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        _logger.info('Notification permissions granted');
        return const Right(true);
      } else if (status.isDenied) {
        _logger.warning('Notification permissions denied');
        return const Right(false);
      } else if (status.isPermanentlyDenied) {
        _logger.warning('Notification permissions permanently denied');
        return const Right(false);
      }
      
      return const Right(false);
    } catch (e) {
      _logger.error('Error requesting notification permissions: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      _logger.error('Error checking notification status: $e');
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
    String? description,
  }) async {
    try {
      final prefs = await getPreferences();
      return prefs.fold(
        (failure) => Left(failure),
        (preferences) async {
          if (!preferences.enabled || !preferences.taskReminders) {
            return const Right(null);
          }

          final notificationId = taskId.hashCode;
          final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

          final androidDetails = AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: preferences.vibrationEnabled,
            playSound: preferences.soundEnabled,
          );

          final iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: preferences.soundEnabled,
          );

          final notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'Task Reminder: $taskTitle',
            description ?? 'Your task is due soon',
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: jsonEncode({'taskId': taskId, 'type': 'task_reminder'}),
          );

          // Save reminder info
          await _saveReminder(TaskReminder(
            id: const Uuid().v4(),
            taskId: taskId,
            taskTitle: taskTitle,
            scheduledTime: reminderTime,
            isActive: true,
            createdAt: DateTime.now(),
          ));

          _logger.info('Scheduled task reminder for: $taskTitle at $reminderTime');
          return const Right(null);
        },
      );
    } catch (e) {
      _logger.error('Error scheduling task reminder: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTaskReminder(String taskId) async {
    try {
      final notificationId = taskId.hashCode;
      await _notificationsPlugin.cancel(notificationId);
      await _removeReminder(taskId);
      
      _logger.info('Cancelled task reminder for: $taskId');
      return const Right(null);
    } catch (e) {
      _logger.error('Error cancelling task reminder: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      await _prefs.remove(_remindersKey);
      
      _logger.info('Cancelled all notifications');
      return const Right(null);
    } catch (e) {
      _logger.error('Error cancelling all notifications: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleDailySummary({
    required String time,
  }) async {
    try {
      final prefs = await getPreferences();
      return prefs.fold(
        (failure) => Left(failure),
        (preferences) async {
          if (!preferences.enabled || !preferences.dailySummary) {
            return const Right(null);
          }

          final timeParts = time.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final now = tz.TZDateTime.now(tz.local);
          var scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          // If the time has passed today, schedule for tomorrow
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final androidDetails = AndroidNotificationDetails(
            'daily_summary',
            'Daily Summary',
            channelDescription: 'Daily task summary notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            enableVibration: preferences.vibrationEnabled,
            playSound: preferences.soundEnabled,
          );

          final iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: preferences.soundEnabled,
          );

          final notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          await _notificationsPlugin.zonedSchedule(
            _dailySummaryId,
            'Daily Task Summary',
            'Check your tasks for today',
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: jsonEncode({'type': 'daily_summary'}),
          );

          _logger.info('Scheduled daily summary at $time');
          return const Right(null);
        },
      );
    } catch (e) {
      _logger.error('Error scheduling daily summary: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelDailySummary() async {
    try {
      await _notificationsPlugin.cancel(_dailySummaryId);
      _logger.info('Cancelled daily summary');
      return const Right(null);
    } catch (e) {
      _logger.error('Error cancelling daily summary: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final prefs = await getPreferences();
      return prefs.fold(
        (failure) => Left(failure),
        (preferences) async {
          if (!preferences.enabled) {
            return const Right(null);
          }

          const androidDetails = AndroidNotificationDetails(
            'general',
            'General Notifications',
            channelDescription: 'General app notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );

          const iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

          const notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          await _notificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch % 100000,
            title,
            body,
            notificationDetails,
            payload: payload,
          );

          _logger.info('Showed notification: $title');
          return const Right(null);
        },
      );
    } catch (e) {
      _logger.error('Error showing notification: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskReminder>>> getScheduledReminders() async {
    try {
      final remindersJson = _prefs.getString(_remindersKey);
      if (remindersJson == null) {
        return const Right([]);
      }

      final List<dynamic> remindersList = jsonDecode(remindersJson);
      final reminders = remindersList
          .map((json) => _reminderFromJson(json as Map<String, dynamic>))
          .toList();

      return Right(reminders);
    } catch (e) {
      _logger.error('Error getting scheduled reminders: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final json = _preferencesToJson(preferences);
      await _prefs.setString(_prefsKey, jsonEncode(json));

      // Update scheduled notifications based on new preferences
      if (!preferences.enabled) {
        await cancelAllNotifications();
      } else {
        if (!preferences.dailySummary) {
          await cancelDailySummary();
        } else {
          await scheduleDailySummary(time: preferences.dailySummaryTime);
        }
      }

      _logger.info('Updated notification preferences');
      return const Right(null);
    } catch (e) {
      _logger.error('Error updating notification preferences: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    try {
      final prefsJson = _prefs.getString(_prefsKey);
      if (prefsJson == null) {
        return Right(NotificationPreferences.defaultPreferences());
      }

      final json = jsonDecode(prefsJson) as Map<String, dynamic>;
      final preferences = _preferencesFromJson(json);
      return Right(preferences);
    } catch (e) {
      _logger.error('Error getting notification preferences: $e');
      return Right(NotificationPreferences.defaultPreferences());
    }
  }

  // Helper methods for serialization
  Map<String, dynamic> _preferencesToJson(NotificationPreferences prefs) {
    return {
      'enabled': prefs.enabled,
      'taskReminders': prefs.taskReminders,
      'dueDateAlerts': prefs.dueDateAlerts,
      'dailySummary': prefs.dailySummary,
      'reminderMinutesBefore': prefs.reminderMinutesBefore,
      'dailySummaryTime': prefs.dailySummaryTime,
      'soundEnabled': prefs.soundEnabled,
      'vibrationEnabled': prefs.vibrationEnabled,
    };
  }

  NotificationPreferences _preferencesFromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool,
      taskReminders: json['taskReminders'] as bool,
      dueDateAlerts: json['dueDateAlerts'] as bool,
      dailySummary: json['dailySummary'] as bool,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int,
      dailySummaryTime: json['dailySummaryTime'] as String,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
    );
  }

  Map<String, dynamic> _reminderToJson(TaskReminder reminder) {
    return {
      'id': reminder.id,
      'taskId': reminder.taskId,
      'taskTitle': reminder.taskTitle,
      'scheduledTime': reminder.scheduledTime.toIso8601String(),
      'isActive': reminder.isActive,
      'createdAt': reminder.createdAt.toIso8601String(),
    };
  }

  TaskReminder _reminderFromJson(Map<String, dynamic> json) {
    return TaskReminder(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Future<void> _saveReminder(TaskReminder reminder) async {
    final reminders = await getScheduledReminders();
    reminders.fold(
      (failure) => null,
      (list) async {
        final updatedList = [...list, reminder];
        final json = updatedList.map(_reminderToJson).toList();
        await _prefs.setString(_remindersKey, jsonEncode(json));
      },
    );
  }

  Future<void> _removeReminder(String taskId) async {
    final reminders = await getScheduledReminders();
    reminders.fold(
      (failure) => null,
      (list) async {
        final updatedList = list.where((r) => r.taskId != taskId).toList();
        final json = updatedList.map(_reminderToJson).toList();
        await _prefs.setString(_remindersKey, jsonEncode(json));
      },
    );
  }
}
