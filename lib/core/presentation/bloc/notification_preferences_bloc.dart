import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_logger.dart';
import '../../services/notification_service.dart';
import 'notification_preferences_event.dart';
import 'notification_preferences_state.dart';

class NotificationPreferencesBloc
    extends Bloc<NotificationPreferencesEvent, NotificationPreferencesState> {
  final NotificationService _notificationService;
  final AppLogger _logger;

  NotificationPreferencesBloc({
    required NotificationService notificationService,
    required AppLogger logger,
  })  : _notificationService = notificationService,
        _logger = logger,
        super(const NotificationPreferencesInitial()) {
    on<LoadNotificationPreferences>(_onLoadPreferences);
    on<UpdateNotificationPreferences>(_onUpdatePreferences);
    on<RequestNotificationPermissions>(_onRequestPermissions);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleTaskReminders>(_onToggleTaskReminders);
    on<ToggleDueDateAlerts>(_onToggleDueDateAlerts);
    on<ToggleDailySummary>(_onToggleDailySummary);
    on<UpdateReminderMinutes>(_onUpdateReminderMinutes);
    on<UpdateDailySummaryTime>(_onUpdateDailySummaryTime);
    on<ToggleSound>(_onToggleSound);
    on<ToggleVibration>(_onToggleVibration);
  }

  Future<void> _onLoadPreferences(
    LoadNotificationPreferences event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    emit(const NotificationPreferencesLoading());

    final prefsResult = await _notificationService.getPreferences();
    final permissionsGranted = await _notificationService.areNotificationsEnabled();

    prefsResult.fold(
      (failure) {
        _logger.error('Failed to load notification preferences: ${failure.message}');
        emit(NotificationPreferencesError(failure.message));
      },
      (preferences) {
        emit(NotificationPreferencesLoaded(
          preferences: preferences,
          permissionsGranted: permissionsGranted,
        ));
      },
    );
  }

  Future<void> _onUpdatePreferences(
    UpdateNotificationPreferences event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      emit(const NotificationPreferencesLoading());

      final result = await _notificationService.updatePreferences(event.preferences);

      result.fold(
        (failure) {
          _logger.error('Failed to update notification preferences: ${failure.message}');
          emit(NotificationPreferencesError(failure.message));
        },
        (_) {
          emit(currentState.copyWith(preferences: event.preferences));
        },
      );
    }
  }

  Future<void> _onRequestPermissions(
    RequestNotificationPermissions event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    final result = await _notificationService.requestPermissions();

    result.fold(
      (failure) {
        _logger.error('Failed to request permissions: ${failure.message}');
        emit(NotificationPreferencesError(failure.message));
      },
      (granted) {
        emit(NotificationPermissionsRequested(granted));
        add(const LoadNotificationPreferences());
      },
    );
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(enabled: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onToggleTaskReminders(
    ToggleTaskReminders event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(taskReminders: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onToggleDueDateAlerts(
    ToggleDueDateAlerts event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(dueDateAlerts: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onToggleDailySummary(
    ToggleDailySummary event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(dailySummary: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onUpdateReminderMinutes(
    UpdateReminderMinutes event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(
        reminderMinutesBefore: event.minutes,
      );
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onUpdateDailySummaryTime(
    UpdateDailySummaryTime event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(
        dailySummaryTime: event.time,
      );
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(soundEnabled: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }

  Future<void> _onToggleVibration(
    ToggleVibration event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    if (state is NotificationPreferencesLoaded) {
      final currentState = state as NotificationPreferencesLoaded;
      final updatedPrefs = currentState.preferences.copyWith(vibrationEnabled: event.enabled);
      add(UpdateNotificationPreferences(updatedPrefs));
    }
  }
}
