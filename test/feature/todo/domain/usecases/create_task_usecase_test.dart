import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/todo/domain/usecases/create_task_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/repositories/task_repository.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';

import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import 'create_task_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late CreateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = CreateTaskUseCase(mockRepository);
  });

  final testTask = TaskEntity(
    id: const TaskId('123'),
    userId: UserId.fromString('user123'),
    title: 'Test Task',
    description: 'Test Description',
    dueDate: DateTime.now(),
    dueTime: const DomainTime(hour: 10, minute: 0),
    category: TaskCategory.ongoing,
    priority: TaskPriority.medium,
    progressPercentage: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreateTaskUseCase', () {
    test('should return TaskEntity when task creation is successful', () async {
      // Arrange
      when(mockRepository.createTask(testTask))
          .thenAnswer((_) async => Right(testTask));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, Right(testTask));
      verify(mockRepository.createTask(testTask));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return StorageFailure when task creation fails', () async {
      // Arrange
      const failure = CacheFailure(message: 'Failed to create task');
      when(mockRepository.createTask(testTask))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.createTask(testTask));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when task data is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Title cannot be empty');
      when(mockRepository.createTask(testTask))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(testTask);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.createTask(testTask));
    });
  });
}
