import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/todo/domain/usecases/search_tasks_usecase.dart';
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/todo/domain/entities/task_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'search_tasks_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late SearchTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = SearchTasksUseCase(repository: mockRepository);
  });

  final testTasks = [
    TaskEntity(
      id: '1',
      userId: 'user123',
      title: 'Buy groceries',
      description: 'Milk, eggs, bread',
      dueDate: DateTime.now(),
      category: 'ongoing',
      priority: 3,
      progressPercentage: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  group('SearchTasksUseCase', () {
    test('should return matching tasks when search is successful', () async {
      // Arrange
      const query = 'groceries';
      when(mockRepository.searchTasks(query))
          .thenAnswer((_) async => Right(testTasks));

      // Act
      final result = await useCase.call(query);

      // Assert
      expect(result, Right(testTasks));
      verify(mockRepository.searchTasks(query));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no tasks match query', () async {
      // Arrange
      const query = 'nonexistent';
      when(mockRepository.searchTasks(query))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call(query);

      // Assert
      expect(result, const Right([]));
      verify(mockRepository.searchTasks(query));
    });

    test('should return StorageFailure when search fails', () async {
      // Arrange
      const query = 'test';
      const failure = StorageFailure(message: 'Search failed');
      when(mockRepository.searchTasks(query))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(query);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.searchTasks(query));
    });
  });
}
