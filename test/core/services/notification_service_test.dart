import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_cleanarc/core/services/notification_service_impl.dart';
import 'package:todo_cleanarc/core/services/app_logger.dart';
import 'package:todo_cleanarc/core/domain/entities/notification_preferences.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  SharedPreferences,
  AppLogger,
])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationServiceImpl notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockSharedPreferences mockPrefs;
  late MockAppLogger mockLogger;

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPrefs = MockSharedPreferences();
    mockLogger = MockAppLogger();

    notificationService = NotificationServiceImpl(
      notificationsPlugin: mockNotificationsPlugin,
      prefs: mockPrefs,
      logger: mockLogger,
    );
  });

  group('NotificationService', () {
    test('should initialize successfully', () async {
      // Arrange
      when(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);

      // Act
      final result = await notificationService.initialize();

      // Assert
      expect(result.isRight(), true);
      verify(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
    });

    test('should return default preferences when none exist', () async {
      // Arrange
      when(mockPrefs.getString('notification_preferences')).thenReturn(null);

      // Act
      final result = await notificationService.getPreferences();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (prefs) {
          expect(prefs.enabled, true);
          expect(prefs.taskReminders, true);
          expect(prefs.dueDateAlerts, true);
          expect(prefs.reminderMinutesBefore, 30);
        },
      );
    });

    test('should update preferences successfully', () async {
      // Arrange
      final preferences = NotificationPreferences.defaultPreferences()
          .copyWith(enabled: false);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.getString('notification_preferences')).thenReturn(null);

      // Act
      final result = await notificationService.updatePreferences(preferences);

      // Assert
      expect(result.isRight(), true);
      verify(mockPrefs.setString('notification_preferences', any)).called(1);
    });

    test('should cancel all notifications', () async {
      // Arrange
      when(mockNotificationsPlugin.cancelAll()).thenAnswer((_) async => {});
      when(mockPrefs.remove('scheduled_reminders')).thenAnswer((_) async => true);

      // Act
      final result = await notificationService.cancelAllNotifications();

      // Assert
      expect(result.isRight(), true);
      verify(mockNotificationsPlugin.cancelAll()).called(1);
      verify(mockPrefs.remove('scheduled_reminders')).called(1);
    });
  });
}
