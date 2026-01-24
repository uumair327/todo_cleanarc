import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_preferences.dart';

abstract class NotificationPreferencesState extends Equatable {
  const NotificationPreferencesState();

  @override
  List<Object?> get props => [];
}

class NotificationPreferencesInitial extends NotificationPreferencesState {
  const NotificationPreferencesInitial();
}

class NotificationPreferencesLoading extends NotificationPreferencesState {
  const NotificationPreferencesLoading();
}

class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferences preferences;
  final bool permissionsGranted;

  const NotificationPreferencesLoaded({
    required this.preferences,
    required this.permissionsGranted,
  });

  @override
  List<Object?> get props => [preferences, permissionsGranted];

  NotificationPreferencesLoaded copyWith({
    NotificationPreferences? preferences,
    bool? permissionsGranted,
  }) {
    return NotificationPreferencesLoaded(
      preferences: preferences ?? this.preferences,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
    );
  }
}

class NotificationPreferencesError extends NotificationPreferencesState {
  final String message;

  const NotificationPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationPermissionsRequested extends NotificationPreferencesState {
  final bool granted;

  const NotificationPermissionsRequested(this.granted);

  @override
  List<Object?> get props => [granted];
}
