import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/todo/domain/usecases/delete_task_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/repositories/task_repository.dart';
import 'package:todo_cleanarc/core/error/failures.dart';

import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';

import 'delete_task_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late DeleteTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = DeleteTaskUseCase(mockRepository);
  });

  const testTaskId = TaskId('123');

  group('DeleteTaskUseCase', () {
    test('should return Right(unit) when task deletion is successful',
        () async {
      // Arrange
      when(mockRepository.deleteTask(testTaskId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase.call(testTaskId);

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.deleteTask(testTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when task deletion fails', () async {
      // Arrange
      const failure = CacheFailure(message: 'Failed to delete task');
      when(mockRepository.deleteTask(testTaskId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTaskId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.deleteTask(testTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when task does not exist', () async {
      // Arrange
      const failure = CacheFailure(message: 'Task not found');
      when(mockRepository.deleteTask(testTaskId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTaskId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.deleteTask(testTaskId));
    });
  });
}
