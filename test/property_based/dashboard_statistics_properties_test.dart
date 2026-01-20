import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:glimfo_todo/feature/todo/domain/entities/task_entity.dart';
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/todo/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:glimfo_todo/core/domain/enums/task_enums.dart';

import 'generators/task_generators.dart';
import 'property_test_config.dart';
import 'dashboard_statistics_properties_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late MockTaskRepository mockRepository;
  late GetDashboardStatsUseCase useCase;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetDashboardStatsUseCase(mockRepository);
  });

  group('Dashboard Statistics Accuracy Property Tests', () {
    /// **Feature: flutter-todo-app, Property 5: Dashboard statistics accuracy**
    /// **Validates: Requirements 3.2**
    /// 
    /// For any set of tasks, the dashboard category counts should equal the actual 
    /// number of tasks in each category (Ongoing, Completed, In Process, Canceled).
    test('Dashboard statistics accurately count tasks by category', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random task list
        final tasks = TaskGenerators.generateTaskList(count: 50);
        
        // Setup mock to return the generated tasks
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        // Execute use case
        final result = await useCase();

        result.fold(
          (failure) => null, // Failure means property doesn't hold
          (stats) {
            // Count tasks manually by category
            final expectedOngoing = tasks.where((t) => t.category == TaskCategory.ongoing).length;
            final expectedCompleted = tasks.where((t) => t.category == TaskCategory.completed).length;
            final expectedInProcess = tasks.where((t) => t.category == TaskCategory.inProcess).length;
            final expectedCanceled = tasks.where((t) => t.category == TaskCategory.canceled).length;

            // Verify all counts match
            if (stats.ongoingCount == expectedOngoing &&
                stats.completedCount == expectedCompleted &&
                stats.inProcessCount == expectedInProcess &&
                stats.canceledCount == expectedCanceled) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All dashboard statistics should accurately count tasks by category');
    });

    /// Property test: Total count equals sum of category counts
    test('Total task count equals sum of all category counts', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final tasks = TaskGenerators.generateTaskList(count: 30);
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        final result = await useCase();

        result.fold(
          (failure) => null,
          (stats) {
            final totalFromStats = stats.ongoingCount + 
                                  stats.completedCount + 
                                  stats.inProcessCount + 
                                  stats.canceledCount;
            if (totalFromStats == tasks.length) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Total count should always equal sum of category counts');
    });

    /// Property test: Empty task list produces zero counts
    test('Empty task list produces zero counts for all categories', () async {
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (stats) {
          expect(stats.ongoingCount, 0);
          expect(stats.completedCount, 0);
          expect(stats.inProcessCount, 0);
          expect(stats.canceledCount, 0);
          expect(stats.recentTasks, isEmpty);
        },
      );
    });

    /// Property test: Recent tasks are sorted by creation date
    test('Recent tasks are sorted by creation date (newest first)', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final tasks = TaskGenerators.generateTaskList(count: 20);
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        final result = await useCase();

        result.fold(
          (failure) => null,
          (stats) {
            if (stats.recentTasks.isEmpty) {
              successCount++;
              return;
            }
            
            // Check if recent tasks are sorted by createdAt descending
            bool isSorted = true;
            for (int j = 0; j < stats.recentTasks.length - 1; j++) {
              if (stats.recentTasks[j].createdAt.isBefore(stats.recentTasks[j + 1].createdAt)) {
                isSorted = false;
                break;
              }
            }
            
            if (isSorted) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Recent tasks should always be sorted by creation date (newest first)');
    });

    /// Property test: Recent tasks limited to 5 items
    test('Recent tasks list contains at most 5 tasks', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final tasks = TaskGenerators.generateTaskList(count: 50);
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        final result = await useCase();

        result.fold(
          (failure) => null,
          (stats) {
            if (stats.recentTasks.length <= 5) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Recent tasks should never exceed 5 items');
    });

    /// Property test: Category counts are non-negative
    test('All category counts are non-negative', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final tasks = TaskGenerators.generateTaskList(count: 40);
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        final result = await useCase();

        result.fold(
          (failure) => null,
          (stats) {
            if (stats.ongoingCount >= 0 &&
                stats.completedCount >= 0 &&
                stats.inProcessCount >= 0 &&
                stats.canceledCount >= 0) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All category counts should always be non-negative');
    });

    /// Property test: Statistics for single category
    test('Tasks with single category produce correct count', () async {
      // Generate tasks all with the same category
      final tasks = List.generate(
        10,
        (index) => TaskGenerators.generateTaskWithCategory(TaskCategory.ongoing),
      );

      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => Right(tasks));

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (stats) {
          expect(stats.ongoingCount, 10);
          expect(stats.completedCount, 0);
          expect(stats.inProcessCount, 0);
          expect(stats.canceledCount, 0);
        },
      );
    });

    /// Property test: Statistics with mixed categories
    test('Tasks with mixed categories produce correct counts', () async {
      final tasks = [
        TaskGenerators.generateTaskWithCategory(TaskCategory.ongoing),
        TaskGenerators.generateTaskWithCategory(TaskCategory.ongoing),
        TaskGenerators.generateTaskWithCategory(TaskCategory.completed),
        TaskGenerators.generateTaskWithCategory(TaskCategory.completed),
        TaskGenerators.generateTaskWithCategory(TaskCategory.completed),
        TaskGenerators.generateTaskWithCategory(TaskCategory.inProcess),
        TaskGenerators.generateTaskWithCategory(TaskCategory.canceled),
      ];

      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => Right(tasks));

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (stats) {
          expect(stats.ongoingCount, 2);
          expect(stats.completedCount, 3);
          expect(stats.inProcessCount, 1);
          expect(stats.canceledCount, 1);
        },
      );
    });
  });
}
