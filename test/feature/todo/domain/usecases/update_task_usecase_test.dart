import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/todo/domain/usecases/update_task_usecase.dart';
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/todo/domain/entities/task_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'update_task_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late UpdateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = UpdateTaskUseCase(repository: mockRepository);
  });

  final testTask = TaskEntity(
    id: '123',
    userId: 'user123',
    title: 'Updated Task',
    description: 'Updated Description',
    dueDate: DateTime.now(),
    category: 'in_process',
    priority: 4,
    progressPercentage: 50,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );

  group('UpdateTaskUseCase', () {
    test('should return TaskEntity when task update is successful', () async {
      // Arrange
      when(mockRepository.updateTask(testTask))
          .thenAnswer((_) async => Right(testTask));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, Right(testTask));
      verify(mockRepository.updateTask(testTask));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return StorageFailure when task update fails', () async {
      // Arrange
      const failure = StorageFailure(message: 'Failed to update task');
      when(mockRepository.updateTask(testTask))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.updateTask(testTask));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when task does not exist', () async {
      // Arrange
      const failure = NotFoundFailure(message: 'Task not found');
      when(mockRepository.updateTask(testTask))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.updateTask(testTask));
    });
  });
}
