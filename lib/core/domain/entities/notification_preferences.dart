import 'package:equatable/equatable.dart';

/// Entity representing user notification preferences
class NotificationPreferences extends Equatable {
  final bool enabled;
  final bool taskReminders;
  final bool dueDateAlerts;
  final bool dailySummary;
  final int reminderMinutesBefore;
  final String dailySummaryTime; // Format: "HH:mm"
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationPreferences({
    required this.enabled,
    required this.taskReminders,
    required this.dueDateAlerts,
    required this.dailySummary,
    required this.reminderMinutesBefore,
    required this.dailySummaryTime,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory NotificationPreferences.defaultPreferences() {
    return const NotificationPreferences(
      enabled: true,
      taskReminders: true,
      dueDateAlerts: true,
      dailySummary: false,
      reminderMinutesBefore: 30,
      dailySummaryTime: "09:00",
      soundEnabled: true,
      vibrationEnabled: true,
    );
  }

  NotificationPreferences copyWith({
    bool? enabled,
    bool? taskReminders,
    bool? dueDateAlerts,
    bool? dailySummary,
    int? reminderMinutesBefore,
    String? dailySummaryTime,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      taskReminders: taskReminders ?? this.taskReminders,
      dueDateAlerts: dueDateAlerts ?? this.dueDateAlerts,
      dailySummary: dailySummary ?? this.dailySummary,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        taskReminders,
        dueDateAlerts,
        dailySummary,
        reminderMinutesBefore,
        dailySummaryTime,
        soundEnabled,
        vibrationEnabled,
      ];
}
