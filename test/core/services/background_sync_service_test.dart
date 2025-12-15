import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/core/services/background_sync_service.dart';
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/core/network/network_info.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'background_sync_service_test.mocks.dart';

@GenerateMocks([TaskRepository, AuthRepository, NetworkInfo])
void main() {
  late BackgroundSyncService syncService;
  late MockTaskRepository mockTaskRepository;
  late MockAuthRepository mockAuthRepository;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockAuthRepository = MockAuthRepository();
    mockNetworkInfo = MockNetworkInfo();
    
    syncService = BackgroundSyncService(
      taskRepository: mockTaskRepository,
      authRepository: mockAuthRepository,
      networkInfo: mockNetworkInfo,
    );
    
    // Reset service state
    syncService.resetRetryCount();
  });

  tearDown(() {
    syncService.dispose();
  });

  group('BackgroundSyncService', () {
    test('should start and stop periodic sync', () async {
      // Arrange - Set up mocks to prevent actual sync operations
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);
      
      // Act
      syncService.startPeriodicSync();
      
      // Wait a bit for any async operations to complete
      await Future.delayed(const Duration(milliseconds: 10));
      
      syncService.stopPeriodicSync();
      expect(syncService.currentStatus, SyncStatus.idle);
    });

    test('should emit sync status updates', () async {
      // Arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      when(mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);
      when(mockTaskRepository.hasUnsyncedChanges())
          .thenAnswer((_) async => const Right(false));

      // Act & Assert
      final statusFuture = expectLater(
        syncService.syncStatusStream,
        emitsInOrder([
          SyncStatus.syncing,
          SyncStatus.upToDate,
        ]),
      );

      await syncService.triggerSync();
      await statusFuture;
    });

    test('should handle sync failure with retry', () async {
      // Arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      when(mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);
      when(mockTaskRepository.hasUnsyncedChanges())
          .thenAnswer((_) async => const Right(true));
      when(mockTaskRepository.syncWithRemote())
          .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));

      // Act & Assert
      final statusFuture = expectLater(
        syncService.syncStatusStream,
        emitsInOrder([
          SyncStatus.syncing,
          SyncStatus.retrying,
        ]),
      );

      final errorFuture = expectLater(
        syncService.syncErrorStream,
        emits(isA<SyncError>()),
      );

      await syncService.triggerSync();
      await statusFuture;
      await errorFuture;
    });

    test('should skip sync when offline', () async {
      // Arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      when(mockNetworkInfo.isConnected)
          .thenAnswer((_) async => false);

      // Act & Assert
      final statusFuture = expectLater(
        syncService.syncStatusStream,
        emitsInOrder([
          SyncStatus.syncing,
          SyncStatus.offline,
        ]),
      );

      await syncService.triggerSync();
      await statusFuture;
    });

    test('should skip sync when not authenticated', () async {
      // Arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      // Act & Assert
      final statusFuture = expectLater(
        syncService.syncStatusStream,
        emitsInOrder([
          SyncStatus.syncing,
          SyncStatus.idle,
        ]),
      );

      await syncService.triggerSync();
      await statusFuture;
    });

    test('should reset retry count', () {
      // Act
      syncService.resetRetryCount();
      
      // Assert - should not throw and should reset internal state
      expect(syncService.currentStatus, SyncStatus.idle);
    });

    test('should check for unsynced changes', () async {
      // Arrange
      when(mockTaskRepository.hasUnsyncedChanges())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await syncService.hasUnsyncedChanges();

      // Assert
      expect(result, true);
      verify(mockTaskRepository.hasUnsyncedChanges()).called(1);
    });
  });
}
