import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_preferences.dart';

abstract class NotificationPreferencesEvent extends Equatable {
  const NotificationPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationPreferences extends NotificationPreferencesEvent {
  const LoadNotificationPreferences();
}

class UpdateNotificationPreferences extends NotificationPreferencesEvent {
  final NotificationPreferences preferences;

  const UpdateNotificationPreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class RequestNotificationPermissions extends NotificationPreferencesEvent {
  const RequestNotificationPermissions();
}

class ToggleNotifications extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleTaskReminders extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleTaskReminders(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDueDateAlerts extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleDueDateAlerts(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDailySummary extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleDailySummary(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateReminderMinutes extends NotificationPreferencesEvent {
  final int minutes;

  const UpdateReminderMinutes(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class UpdateDailySummaryTime extends NotificationPreferencesEvent {
  final String time;

  const UpdateDailySummaryTime(this.time);

  @override
  List<Object?> get props => [time];
}

class ToggleSound extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleSound(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleVibration extends NotificationPreferencesEvent {
  final bool enabled;

  const ToggleVibration(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
