import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_cleanarc/feature/todo/data/repositories/task_repository_impl.dart';
import 'package:todo_cleanarc/feature/todo/data/datasources/hive_task_datasource.dart';
import 'package:todo_cleanarc/feature/todo/data/datasources/supabase_task_datasource.dart';
import 'package:todo_cleanarc/feature/todo/data/models/task_model.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/network/network_info.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import 'task_repository_integration_test.mocks.dart';

@GenerateMocks([HiveTaskDataSource, SupabaseTaskDataSource, NetworkInfo])
void main() {
  late TaskRepositoryImpl repository;
  late MockHiveTaskDataSource mockLocalDataSource;
  late MockSupabaseTaskDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockHiveTaskDataSource();
    mockRemoteDataSource = MockSupabaseTaskDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = TaskRepositoryImpl(
      hiveDataSource: mockLocalDataSource,
      supabaseDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final testDate = DateTime(2026, 1, 25);
  final testModel = TaskModel(
    id: '123',
    userId: 'user123',
    title: 'Test Task',
    description: 'Test Description',
    dueDate: testDate,
    dueTime: '14:30',
    category: 'ongoing',
    priority: 3,
    progressPercentage: 50,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testEntity = TaskEntity(
    id: const TaskId('123'),
    userId: UserId.fromString('user123'),
    title: 'Test Task',
    description: 'Test Description',
    dueDate: testDate,
    dueTime: const DomainTime(hour: 14, minute: 30),
    category: TaskCategory.ongoing,
    priority: TaskPriority.urgent,
    progressPercentage: 50,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('TaskRepository Integration Tests', () {
    group('createTask - offline first', () {
      test('should save to local storage first when online', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.createTask(any))
            .thenAnswer((_) async => testModel);
        when(mockRemoteDataSource.createTask(any))
            .thenAnswer((_) async => testModel);

        // Act
        await repository.createTask(testEntity);

        // Assert
        verify(mockLocalDataSource.createTask(any)).called(1);
        verify(mockRemoteDataSource.createTask(any)).called(1);
      });

      test('should save to local storage and queue for sync when offline',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.createTask(any))
            .thenAnswer((_) async => testModel);

        // Act
        await repository.createTask(testEntity);

        // Assert
        verify(mockLocalDataSource.createTask(any)).called(1);
        verifyNever(mockRemoteDataSource.createTask(any));
      });
    });

    group('getAllTasks - offline first', () {
      test('should return local data when offline', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getAllTasks())
            .thenAnswer((_) async => [testModel]);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) => expect(tasks.length, 1),
        );
        verify(mockLocalDataSource.getAllTasks()).called(1);
        verifyNever(mockRemoteDataSource.getAllTasks(any));
      });

      test('should sync with remote when online', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getAllTasks())
            .thenAnswer((_) async => [testModel]);
        when(mockRemoteDataSource.getAllTasks(any))
            .thenAnswer((_) async => [testModel]);
        when(mockLocalDataSource.getTasksNeedingSync())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result.isRight(), true);
        verify(mockLocalDataSource.getAllTasks()).called(1);
      });
    });

    group('updateTask - conflict resolution', () {
      test('should update local and remote when online', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.updateTask(any))
            .thenAnswer((_) async => testModel);
        when(mockRemoteDataSource.updateTask(any))
            .thenAnswer((_) async => testModel);

        // Act
        await repository.updateTask(testEntity);

        // Assert
        verify(mockLocalDataSource.updateTask(any)).called(1);
        verify(mockRemoteDataSource.updateTask(any)).called(1);
      });

      test('should queue update for sync when offline', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.updateTask(any))
            .thenAnswer((_) async => testModel);

        // Act
        await repository.updateTask(testEntity);

        // Assert
        verify(mockLocalDataSource.updateTask(any)).called(1);
        verifyNever(mockRemoteDataSource.updateTask(any));
      });
    });

    group('deleteTask', () {
      test('should delete from local and remote when online', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.deleteTask('123'))
            .thenAnswer((_) async => Future.value());
        when(mockRemoteDataSource.deleteTask('123'))
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.deleteTask(testEntity.id);

        // Assert
        verify(mockLocalDataSource.deleteTask('123')).called(1);
        verify(mockRemoteDataSource.deleteTask('123')).called(1);
      });

      test('should mark as deleted locally when offline', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.deleteTask('123'))
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.deleteTask(testEntity.id);

        // Assert
        verify(mockLocalDataSource.deleteTask('123')).called(1);
        verifyNever(mockRemoteDataSource.deleteTask('123'));
      });
    });

    group('searchTasks', () {
      test('should search in local storage', () async {
        // Arrange
        const query = 'test';
        when(mockLocalDataSource.searchTasks(query))
            .thenAnswer((_) async => [testModel]);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, 1);
            expect(tasks.first.title, 'Test Task');
          },
        );
        verify(mockLocalDataSource.searchTasks(query)).called(1);
      });
    });
  });
}
