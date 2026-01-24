import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/todo/domain/usecases/update_task_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/repositories/task_repository.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';

import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import 'update_task_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late UpdateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = UpdateTaskUseCase(mockRepository);
  });

  final testTask = TaskEntity(
    id: const TaskId('123'),
    userId: UserId.fromString('user123'),
    title: 'Updated Task',
    description: 'Updated Description',
    dueDate: DateTime.now(),
    dueTime: const DomainTime(hour: 10, minute: 0),
    category: TaskCategory.inProcess,
    priority: TaskPriority.urgent,
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

    test('should return CacheFailure when task update fails', () async {
      // Arrange
      const failure = CacheFailure(message: 'Failed to update task');
      when(mockRepository.updateTask(testTask))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.updateTask(testTask));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when task does not exist', () async {
      // Arrange
      const failure = CacheFailure(message: 'Task not found');
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
