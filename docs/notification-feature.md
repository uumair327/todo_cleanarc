# Notification System Documentation

## Overview

The notification system provides comprehensive push notification capabilities for the Flutter Todo App, including task reminders, due date alerts, and daily summaries.

## Features

### 1. Task Reminders
- Automatic notifications before tasks are due
- Configurable reminder time (5 minutes to 1 day before)
- Smart scheduling based on task due date and time
- Automatic cancellation when tasks are completed or deleted

### 2. Due Date Alerts
- Notifications when tasks are due
- Immediate alerts for overdue tasks
- Integration with task status

### 3. Daily Summary
- Daily overview of pending tasks
- Configurable time for daily notifications
- Summary of tasks due today

### 4. Notification Preferences
- Master enable/disable switch
- Individual toggles for each notification type
- Sound and vibration controls
- Customizable reminder timing

## Architecture

### Domain Layer

#### Entities
- `NotificationPreferences`: User notification settings
- `TaskReminder`: Scheduled reminder information

### Service Layer

#### NotificationService
Abstract interface defining notification operations:
- `initialize()`: Initialize notification system
- `requestPermissions()`: Request notification permissions
- `scheduleTaskReminder()`: Schedule a task reminder
- `cancelTaskReminder()`: Cancel a specific reminder
- `scheduleDailySummary()`: Schedule daily summary
- `showNotification()`: Show immediate notification
- `updatePreferences()`: Update user preferences

#### NotificationServiceImpl
Concrete implementation using:
- `flutter_local_notifications`: Local notification handling
- `permission_handler`: Permission management
- `timezone`: Timezone-aware scheduling
- `shared_preferences`: Preference storage

#### TaskNotificationManager
High-level manager for task-related notifications:
- Integrates with task lifecycle
- Handles task creation/update/deletion
- Manages notification scheduling based on preferences

### Presentation Layer

#### NotificationPreferencesBloc
State management for notification preferences:
- Load and update preferences
- Request permissions
- Toggle individual settings
- Update reminder timing

#### NotificationPreferencesScreen
UI for managing notification settings:
- Master enable/disable toggle
- Task reminder settings
- Daily summary configuration
- Sound and vibration controls
- Permission request UI

## Usage

### Initialization

The notification system is automatically initialized during app startup in the dependency injection container:

```dart
// In injection_container.dart
await notificationService.initialize();
```

### Scheduling Task Notifications

When creating or updating a task:

```dart
final taskNotificationManager = sl<TaskNotificationManager>();
await taskNotificationManager.scheduleTaskNotification(task);
```

### Updating Preferences

Users can update preferences through the settings screen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NotificationPreferencesScreen(),
  ),
);
```

### Canceling Notifications

When a task is completed or deleted:

```dart
await taskNotificationManager.cancelTaskNotification(taskId);
```

## Platform Configuration

### Android

Required permissions in `AndroidManifest.xml`:
- `POST_NOTIFICATIONS`: Show notifications (Android 13+)
- `VIBRATE`: Vibration support
- `RECEIVE_BOOT_COMPLETED`: Reschedule after reboot
- `SCHEDULE_EXACT_ALARM`: Exact timing for reminders
- `USE_EXACT_ALARM`: Alternative exact alarm permission

### iOS

Required configuration in `Info.plist`:
- `UIBackgroundModes`: Background fetch and remote notifications
- `BGTaskSchedulerPermittedIdentifiers`: Background task scheduling

## Notification Channels

### Android Channels

1. **Task Reminders** (`task_reminders`)
   - Importance: High
   - Sound: Enabled (configurable)
   - Vibration: Enabled (configurable)

2. **Daily Summary** (`daily_summary`)
   - Importance: Default
   - Sound: Enabled (configurable)
   - Vibration: Enabled (configurable)

3. **General** (`general`)
   - Importance: Default
   - For miscellaneous notifications

## Notification Payload

Notifications include JSON payload for handling taps:

```json
{
  "taskId": "uuid",
  "type": "task_reminder" | "daily_summary"
}
```

## Preferences Storage

Preferences are stored in SharedPreferences:
- Key: `notification_preferences`
- Format: JSON
- Default values provided if not set

Scheduled reminders are also stored:
- Key: `scheduled_reminders`
- Format: JSON array
- Used for tracking active reminders

## Testing

### Manual Testing

1. **Permission Request**
   - Open notification settings
   - Tap "Grant Permissions"
   - Verify permission dialog appears

2. **Task Reminder**
   - Create a task with due date/time
   - Set reminder to 1 minute before
   - Wait for notification

3. **Daily Summary**
   - Enable daily summary
   - Set time to 1 minute from now
   - Wait for notification

4. **Preference Updates**
   - Toggle various settings
   - Verify changes persist after app restart

### Automated Testing

Unit tests should cover:
- Preference serialization/deserialization
- Reminder scheduling logic
- Permission handling
- Notification cancellation

Integration tests should verify:
- End-to-end notification flow
- Task lifecycle integration
- Preference persistence

## Troubleshooting

### Notifications Not Appearing

1. Check permissions are granted
2. Verify notifications are enabled in preferences
3. Check device notification settings
4. Ensure task has valid due date/time
5. Verify reminder time is in the future

### Notifications Not Canceling

1. Check task ID matches
2. Verify cancellation is called
3. Check for errors in logs

### Daily Summary Not Working

1. Verify daily summary is enabled
2. Check time is set correctly
3. Ensure app has background permissions
4. Check device battery optimization settings

## Future Enhancements

Potential improvements:
1. Push notifications via Firebase Cloud Messaging
2. Notification grouping and stacking
3. Rich notifications with actions (Complete, Snooze)
4. Notification history
5. Smart notification timing based on user behavior
6. Notification templates
7. Multi-language support for notification text
8. Notification analytics

## Dependencies

- `flutter_local_notifications: ^17.2.3`: Local notification handling
- `timezone: ^0.9.4`: Timezone-aware scheduling
- `permission_handler: ^11.3.1`: Permission management
- `shared_preferences: ^2.2.3`: Preference storage

## Related Files

### Domain
- `lib/core/domain/entities/notification_preferences.dart`
- `lib/core/domain/entities/task_reminder.dart`

### Services
- `lib/core/services/notification_service.dart`
- `lib/core/services/notification_service_impl.dart`
- `lib/core/services/task_notification_manager.dart`

### Presentation
- `lib/core/presentation/bloc/notification_preferences_bloc.dart`
- `lib/core/presentation/bloc/notification_preferences_event.dart`
- `lib/core/presentation/bloc/notification_preferences_state.dart`
- `lib/core/presentation/screens/notification_preferences_screen.dart`

### Configuration
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
