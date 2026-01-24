import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/feature/todo/domain/repositories/task_repository.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/export_tasks_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/import_tasks_usecase.dart';

import 'export_import_usecases_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late MockTaskRepository mockRepository;
  late ExportTasksUseCase exportUseCase;
  late ImportTasksUseCase importUseCase;

  setUp(() {
    mockRepository = MockTaskRepository();
    exportUseCase = ExportTasksUseCase(mockRepository);
    importUseCase = ImportTasksUseCase(mockRepository);
  });

  group('ExportTasksUseCase', () {
    const testCsvData = 'ID,Title,Description\n1,Task1,Desc1';
    const testJsonData = '[{"id":"1","title":"Task1"}]';

    test('should export tasks as CSV', () async {
      // Arrange
      when(mockRepository.exportTasks('csv'))
          .thenAnswer((_) async => const Right(testCsvData));

      // Act
      final result = await exportUseCase('csv');

      // Assert
      expect(result, const Right(testCsvData));
      verify(mockRepository.exportTasks('csv'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should export tasks as JSON', () async {
      // Arrange
      when(mockRepository.exportTasks('json'))
          .thenAnswer((_) async => const Right(testJsonData));

      // Act
      final result = await exportUseCase('json');

      // Assert
      expect(result, const Right(testJsonData));
      verify(mockRepository.exportTasks('json'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when export fails', () async {
      // Arrange
      const failure = CacheFailure(message: 'Export failed');
      when(mockRepository.exportTasks('csv'))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await exportUseCase('csv');

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.exportTasks('csv'));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('ImportTasksUseCase', () {
    const testCsvData = 'ID,Title,Description\n1,Task1,Desc1';
    const testJsonData = '[{"id":"1","title":"Task1"}]';

    test('should import tasks from CSV', () async {
      // Arrange
      when(mockRepository.importTasks(testCsvData, 'csv'))
          .thenAnswer((_) async => const Right(1));

      // Act
      final result = await importUseCase(testCsvData, 'csv');

      // Assert
      expect(result, const Right(1));
      verify(mockRepository.importTasks(testCsvData, 'csv'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should import tasks from JSON', () async {
      // Arrange
      when(mockRepository.importTasks(testJsonData, 'json'))
          .thenAnswer((_) async => const Right(1));

      // Act
      final result = await importUseCase(testJsonData, 'json');

      // Assert
      expect(result, const Right(1));
      verify(mockRepository.importTasks(testJsonData, 'json'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when import fails', () async {
      // Arrange
      const failure = ValidationFailure('Invalid format');
      when(mockRepository.importTasks(testCsvData, 'csv'))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await importUseCase(testCsvData, 'csv');

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.importTasks(testCsvData, 'csv'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return count of imported tasks', () async {
      // Arrange
      when(mockRepository.importTasks(testJsonData, 'json'))
          .thenAnswer((_) async => const Right(5));

      // Act
      final result = await importUseCase(testJsonData, 'json');

      // Assert
      expect(result, const Right(5));
      verify(mockRepository.importTasks(testJsonData, 'json'));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
