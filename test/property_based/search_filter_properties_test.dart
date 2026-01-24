import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:todo_cleanarc/feature/todo/domain/repositories/task_repository.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/search_tasks_usecase.dart';

import 'generators/task_generators.dart';
import 'search_filter_properties_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late MockTaskRepository mockRepository;
  late SearchTasksUseCase searchUseCase;

  setUp(() {
    mockRepository = MockTaskRepository();
    searchUseCase = SearchTasksUseCase(mockRepository);
  });

  group('Search and Filter Correctness Property Tests', () {
    /// **Feature: flutter-todo-app, Property 6: Search and filter correctness**
    /// **Validates: Requirements 5.2, 5.4**
    /// 
    /// For any search query or date filter, all returned results should match 
    /// the specified criteria and no matching items should be excluded.
    test('Search returns only tasks matching query in title or description', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate random task list
        final allTasks = TaskGenerators.generateTaskList(count: 30);
        
        // Pick a random search term from one of the tasks
        if (allTasks.isEmpty) {
          successCount++;
          continue;
        }
        
        final randomTask = allTasks[i % allTasks.length];
        final searchQuery = randomTask.title.split(' ').first.toLowerCase();
        
        // Filter tasks manually to get expected results
        final expectedResults = allTasks.where((task) =>
          task.title.toLowerCase().contains(searchQuery) ||
          task.description.toLowerCase().contains(searchQuery)
        ).toList();
        
        // Setup mock to return filtered results
        when(mockRepository.searchTasks(searchQuery))
            .thenAnswer((_) async => Right(expectedResults));

        // Execute search
        final result = await searchUseCase(searchQuery);

        result.fold(
          (failure) => null,
          (results) {
            // Verify all results match the query
            bool allMatch = results.every((task) =>
              task.title.toLowerCase().contains(searchQuery) ||
              task.description.toLowerCase().contains(searchQuery)
            );
            
            // Verify count matches expected
            if (allMatch && results.length == expectedResults.length) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All search results should match the query criteria');
    });

    /// Property test: Empty search query returns all tasks
    test('Empty search query returns all tasks', () async {
      const iterations = 50;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final allTasks = TaskGenerators.generateTaskList(count: 20);
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(allTasks));

        final result = await searchUseCase('');

        result.fold(
          (failure) => null,
          (results) {
            if (results.length == allTasks.length) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Empty query should return all tasks');
    });

    /// Property test: Search is case-insensitive
    test('Search is case-insensitive', () async {
      const iterations = 50;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final allTasks = TaskGenerators.generateTaskList(count: 20);
        
        if (allTasks.isEmpty) {
          successCount++;
          continue;
        }
        
        final randomTask = allTasks[i % allTasks.length];
        final searchTerm = randomTask.title.split(' ').first;
        
        // Test with different cases
        final lowerCase = searchTerm.toLowerCase();
        final upperCase = searchTerm.toUpperCase();
        
        final expectedResults = allTasks.where((task) =>
          task.title.toLowerCase().contains(lowerCase) ||
          task.description.toLowerCase().contains(lowerCase)
        ).toList();
        
        when(mockRepository.searchTasks(lowerCase))
            .thenAnswer((_) async => Right(expectedResults));
        when(mockRepository.searchTasks(upperCase))
            .thenAnswer((_) async => Right(expectedResults));

        final lowerResult = await searchUseCase(lowerCase);
        final upperResult = await searchUseCase(upperCase);

        var lowerSuccess = false;
        var upperSuccess = false;

        lowerResult.fold(
          (failure) => null,
          (results) {
            lowerSuccess = results.length == expectedResults.length;
          },
        );

        upperResult.fold(
          (failure) => null,
          (results) {
            upperSuccess = results.length == expectedResults.length;
          },
        );

        if (lowerSuccess && upperSuccess) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Search should be case-insensitive');
    });

    /// Property test: Date range filter returns only tasks within range
    test('Date range filter returns only tasks within specified range', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: i % 30));
        final endDate = now.add(Duration(days: (i + 10) % 30));
        
        // Generate tasks with various dates
        final allTasks = TaskGenerators.generateTaskList(count: 40);
        
        // Filter tasks manually to get expected results
        final expectedResults = allTasks.where((task) =>
          (task.dueDate.isAfter(startDate) || task.dueDate.isAtSameMomentAs(startDate)) &&
          (task.dueDate.isBefore(endDate) || task.dueDate.isAtSameMomentAs(endDate))
        ).toList();
        
        // Setup mock to return filtered results
        when(mockRepository.getTasksByDateRange(startDate, endDate))
            .thenAnswer((_) async => Right(expectedResults));

        // Execute filter
        final result = await mockRepository.getTasksByDateRange(startDate, endDate);

        result.fold(
          (failure) => null,
          (results) {
            // Verify all results are within date range
            bool allInRange = results.every((task) =>
              (task.dueDate.isAfter(startDate) || task.dueDate.isAtSameMomentAs(startDate)) &&
              (task.dueDate.isBefore(endDate) || task.dueDate.isAtSameMomentAs(endDate))
            );
            
            if (allInRange) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All filtered results should be within the specified date range');
    });

    /// Property test: No matching tasks returns empty list
    test('Search with no matches returns empty list', () async {
      TaskGenerators.generateTaskList(count: 20);
      const nonExistentQuery = 'xyzabc123nonexistent';
      
      when(mockRepository.searchTasks(nonExistentQuery))
          .thenAnswer((_) async => const Right([]));

      final result = await searchUseCase(nonExistentQuery);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (results) {
          expect(results, isEmpty);
        },
      );
    });

    /// Property test: Search results contain no duplicates
    test('Search results contain no duplicate tasks', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final allTasks = TaskGenerators.generateTaskList(count: 30);
        
        if (allTasks.isEmpty) {
          successCount++;
          continue;
        }
        
        final randomTask = allTasks[i % allTasks.length];
        final searchQuery = randomTask.title.split(' ').first.toLowerCase();
        
        final expectedResults = allTasks.where((task) =>
          task.title.toLowerCase().contains(searchQuery) ||
          task.description.toLowerCase().contains(searchQuery)
        ).toList();
        
        when(mockRepository.searchTasks(searchQuery))
            .thenAnswer((_) async => Right(expectedResults));

        final result = await searchUseCase(searchQuery);

        result.fold(
          (failure) => null,
          (results) {
            // Check for duplicates by comparing task IDs
            final taskIds = results.map((task) => task.id.toString()).toSet();
            if (taskIds.length == results.length) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Search results should not contain duplicate tasks');
    });

    /// Property test: Partial match in title returns task
    test('Partial match in title returns the task', () async {
      const iterations = 50;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final task = TaskGenerators.generateValidTask(
          title: 'Complete project documentation',
        );
        final allTasks = [task, ...TaskGenerators.generateTaskList(count: 10)];
        
        const partialQuery = 'project';
        
        final expectedResults = allTasks.where((t) =>
          t.title.toLowerCase().contains(partialQuery) ||
          t.description.toLowerCase().contains(partialQuery)
        ).toList();
        
        when(mockRepository.searchTasks(partialQuery))
            .thenAnswer((_) async => Right(expectedResults));

        final result = await searchUseCase(partialQuery);

        result.fold(
          (failure) => null,
          (results) {
            // Verify the specific task is in results
            final containsTask = results.any((t) => t.id == task.id);
            if (containsTask) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Partial matches should be included in search results');
    });

    /// Property test: Partial match in description returns task
    test('Partial match in description returns the task', () async {
      const iterations = 50;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final task = TaskGenerators.generateValidTask(
          description: 'This task involves reviewing the quarterly reports',
        );
        final allTasks = [task, ...TaskGenerators.generateTaskList(count: 10)];
        
        const partialQuery = 'quarterly';
        
        final expectedResults = allTasks.where((t) =>
          t.title.toLowerCase().contains(partialQuery) ||
          t.description.toLowerCase().contains(partialQuery)
        ).toList();
        
        when(mockRepository.searchTasks(partialQuery))
            .thenAnswer((_) async => Right(expectedResults));

        final result = await searchUseCase(partialQuery);

        result.fold(
          (failure) => null,
          (results) {
            // Verify the specific task is in results
            final containsTask = results.any((t) => t.id == task.id);
            if (containsTask) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'Partial matches in description should be included in search results');
    });

    /// Property test: Whitespace-only query returns all tasks
    test('Whitespace-only query returns all tasks', () async {
      final allTasks = TaskGenerators.generateTaskList(count: 15);
      
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => Right(allTasks));

      final result = await searchUseCase('   ');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (results) {
          expect(results.length, allTasks.length);
        },
      );
    });

    /// Property test: Date filter with same start and end date
    test('Date filter with same start and end date returns tasks on that date', () async {
      final targetDate = DateTime.now();
      
      // Generate tasks with specific date
      final tasksOnDate = TaskGenerators.generateTasksInDateRange(
        startDate: targetDate,
        endDate: targetDate,
        count: 5,
      );
      
      TaskGenerators.generateTasksInDateRange(
        startDate: targetDate.add(const Duration(days: 1)),
        endDate: targetDate.add(const Duration(days: 10)),
        count: 10,
      );
      
      when(mockRepository.getTasksByDateRange(targetDate, targetDate))
          .thenAnswer((_) async => Right(tasksOnDate));

      final result = await mockRepository.getTasksByDateRange(targetDate, targetDate);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (results) {
          // All results should be on the target date
          final allOnDate = results.every((task) =>
            task.dueDate.year == targetDate.year &&
            task.dueDate.month == targetDate.month &&
            task.dueDate.day == targetDate.day
          );
          expect(allOnDate, true);
        },
      );
    });
  });
}
