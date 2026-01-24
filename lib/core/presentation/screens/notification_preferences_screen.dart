import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/injection_container.dart';
import '../bloc/notification_preferences_bloc.dart';
import '../bloc/notification_preferences_event.dart';
import '../bloc/notification_preferences_state.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationPreferencesBloc>()
        ..add(const LoadNotificationPreferences()),
      child: const _NotificationPreferencesView(),
    );
  }
}

class _NotificationPreferencesView extends StatelessWidget {
  const _NotificationPreferencesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocConsumer<NotificationPreferencesBloc, NotificationPreferencesState>(
        listener: (context, state) {
          if (state is NotificationPreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationPermissionsRequested) {
            final message = state.granted
                ? 'Notification permissions granted'
                : 'Notification permissions denied';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationPreferencesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationPreferencesLoaded) {
            return _buildPreferencesContent(context, state);
          }

          return const Center(child: Text('Failed to load preferences'));
        },
      ),
    );
  }

  Widget _buildPreferencesContent(
    BuildContext context,
    NotificationPreferencesLoaded state,
  ) {
    final prefs = state.preferences;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Permissions section
        if (!state.permissionsGranted)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions Required',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notification permissions are required to receive task reminders.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationPreferencesBloc>().add(
                            const RequestNotificationPermissions(),
                          );
                    },
                    child: const Text('Grant Permissions'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Master toggle
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Master switch for all notifications'),
          value: prefs.enabled,
          onChanged: (value) {
            context.read<NotificationPreferencesBloc>().add(
                  ToggleNotifications(value),
                );
          },
        ),
        const Divider(),

        // Task reminders section
        Text(
          'Task Reminders',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Task Reminders'),
          subtitle: const Text('Get notified before tasks are due'),
          value: prefs.taskReminders,
          onChanged: prefs.enabled
              ? (value) {
                  context.read<NotificationPreferencesBloc>().add(
                        ToggleTaskReminders(value),
                      );
                }
              : null,
        ),
        ListTile(
          title: const Text('Reminder Time'),
          subtitle: Text('${prefs.reminderMinutesBefore} minutes before due time'),
          trailing: const Icon(Icons.chevron_right),
          enabled: prefs.enabled && prefs.taskReminders,
          onTap: () => _showReminderTimePicker(context, prefs.reminderMinutesBefore),
        ),
        SwitchListTile(
          title: const Text('Due Date Alerts'),
          subtitle: const Text('Alert when tasks are due'),
          value: prefs.dueDateAlerts,
          onChanged: prefs.enabled
              ? (value) {
                  context.read<NotificationPreferencesBloc>().add(
                        ToggleDueDateAlerts(value),
                      );
                }
              : null,
        ),
        const Divider(),

        // Daily summary section
        Text(
          'Daily Summary',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Daily Summary'),
          subtitle: const Text('Daily overview of your tasks'),
          value: prefs.dailySummary,
          onChanged: prefs.enabled
              ? (value) {
                  context.read<NotificationPreferencesBloc>().add(
                        ToggleDailySummary(value),
                      );
                }
              : null,
        ),
        ListTile(
          title: const Text('Summary Time'),
          subtitle: Text('Daily at ${prefs.dailySummaryTime}'),
          trailing: const Icon(Icons.chevron_right),
          enabled: prefs.enabled && prefs.dailySummary,
          onTap: () => _showTimePicker(context, prefs.dailySummaryTime),
        ),
        const Divider(),

        // Sound and vibration section
        Text(
          'Notification Style',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Sound'),
          subtitle: const Text('Play sound for notifications'),
          value: prefs.soundEnabled,
          onChanged: prefs.enabled
              ? (value) {
                  context.read<NotificationPreferencesBloc>().add(
                        ToggleSound(value),
                      );
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Vibration'),
          subtitle: const Text('Vibrate for notifications'),
          value: prefs.vibrationEnabled,
          onChanged: prefs.enabled
              ? (value) {
                  context.read<NotificationPreferencesBloc>().add(
                        ToggleVibration(value),
                      );
                }
              : null,
        ),
      ],
    );
  }

  void _showReminderTimePicker(BuildContext context, int currentMinutes) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReminderOption(context, 5, currentMinutes),
            _buildReminderOption(context, 15, currentMinutes),
            _buildReminderOption(context, 30, currentMinutes),
            _buildReminderOption(context, 60, currentMinutes),
            _buildReminderOption(context, 120, currentMinutes),
            _buildReminderOption(context, 1440, currentMinutes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderOption(BuildContext context, int minutes, int currentMinutes) {
    final isSelected = minutes == currentMinutes;
    String label;
    if (minutes < 60) {
      label = '$minutes minutes';
    } else if (minutes == 60) {
      label = '1 hour';
    } else if (minutes < 1440) {
      label = '${minutes ~/ 60} hours';
    } else {
      label = '1 day';
    }

    return ListTile(
      title: Text(label),
      leading: Radio<int>(
        value: minutes,
        groupValue: currentMinutes,
        onChanged: (value) {
          if (value != null) {
            context.read<NotificationPreferencesBloc>().add(
                  UpdateReminderMinutes(value),
                );
            Navigator.pop(context);
          }
        },
      ),
      selected: isSelected,
      onTap: () {
        context.read<NotificationPreferencesBloc>().add(
              UpdateReminderMinutes(minutes),
            );
        Navigator.pop(context);
      },
    );
  }

  void _showTimePicker(BuildContext context, String currentTime) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null && context.mounted) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:'
          '${selectedTime.minute.toString().padLeft(2, '0')}';
      context.read<NotificationPreferencesBloc>().add(
            UpdateDailySummaryTime(timeString),
          );
    }
  }
}
