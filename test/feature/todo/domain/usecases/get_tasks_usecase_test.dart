import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/todo/domain/usecases/get_tasks_usecase.dart';
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/todo/domain/entities/task_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'get_tasks_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late GetTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetTasksUseCase(repository: mockRepository);
  });

  final testTasks = [
    TaskEntity(
      id: '1',
      userId: 'user123',
      title: 'Task 1',
      description: 'Description 1',
      dueDate: DateTime.now(),
      category: 'ongoing',
      priority: 3,
      progressPercentage: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TaskEntity(
      id: '2',
      userId: 'user123',
      title: 'Task 2',
      description: 'Description 2',
      dueDate: DateTime.now(),
      category: 'completed',
      priority: 2,
      progressPercentage: 100,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  group('GetTasksUseCase', () {
    test('should return list of tasks when retrieval is successful', () async {
      // Arrange
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => Right(testTasks));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, Right(testTasks));
      verify(mockRepository.getAllTasks());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no tasks exist', () async {
      // Arrange
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Right([]));
      verify(mockRepository.getAllTasks());
    });

    test('should return StorageFailure when retrieval fails', () async {
      // Arrange
      const failure = StorageFailure(message: 'Failed to retrieve tasks');
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.getAllTasks());
    });
  });
}
