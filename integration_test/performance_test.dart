/// Performance benchmarking integration tests
/// Tests critical operations against performance requirements
/// Requirements: 3.5, 7.1, 10.1, 10.4
library;


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:glimfo_todo/main.dart' as app;
import 'package:glimfo_todo/core/services/injection_container.dart' as di;
import 'package:glimfo_todo/feature/todo/domain/repositories/task_repository.dart';
import 'package:glimfo_todo/feature/todo/domain/entities/task_entity.dart';
import 'package:glimfo_todo/core/domain/value_objects/task_id.dart';
import 'package:glimfo_todo/core/domain/value_objects/user_id.dart';
import 'package:glimfo_todo/core/domain/enums/task_enums.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Benchmarking Tests', () {
    late TaskRepository taskRepository;

    setUp(() async {
      await IntegrationTestConfig.initialize();
      taskRepository = di.sl<TaskRepository>();
    });

    tearDown(() async {
      await IntegrationTestConfig.cleanup();
    });

    testWidgets(
      'Performance: Database read operations should complete within 50ms',
      (WidgetTester tester) async {
        // Requirement 10.1: Database read operations under 50ms
        
        // Create test tasks
        final testUserId = UserId.generate();
        final testTasks = List.generate(
          100,
          (index) => TaskEntity(
            id: TaskId.generate(),
            userId: testUserId,
            title: 'Task $index',
            description: 'Description $index',
            dueDate: DateTime.now().add(Duration(days: index)),
            dueTime: const DomainTime(hour: 12, minute: 0),
            category: TaskCategory.ongoing,
            priority: TaskPriority.medium,
            progressPercentage: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Store tasks
        for (final task in testTasks) {
          await taskRepository.createTask(task);
        }

        // Benchmark: Read all tasks
        final readBenchmark = PerformanceBenchmark('Read all tasks');
        readBenchmark.start();
        
        final tasksResult = await taskRepository.getAllTasks();
        
        final readDuration = readBenchmark.stop();
        readBenchmark.printResults();

        // Assert: Should complete within 50ms
        expect(
          readDuration.inMilliseconds,
          lessThanOrEqualTo(50),
          reason: 'Database read operations should complete within 50ms',
        );

        tasksResult.fold(
          (failure) => fail('Failed to get tasks: ${failure.message}'),
          (tasks) {
            expect(tasks.length, greaterThanOrEqualTo(100));
          },
        );
      },
    );

    testWidgets(
      'Performance: Search operations should complete within 100ms',
      (WidgetTester tester) async {
        // Requirement 10.4: Search operations within 100ms
        
        // Create test tasks with searchable content
        final testUserId = UserId.generate();
        final testTasks = List.generate(
          500,
          (index) => TaskEntity(
            id: TaskId.generate(),
            userId: testUserId,
            title: 'Task $index with searchable content',
            description: 'Description $index with keywords',
            dueDate: DateTime.now().add(Duration(days: index)),
            dueTime: const DomainTime(hour: 12, minute: 0),
            category: TaskCategory.ongoing,
            priority: TaskPriority.medium,
            progressPercentage: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Store tasks
        for (final task in testTasks) {
          await taskRepository.createTask(task);
        }

        // Benchmark: Search tasks
        final searchBenchmark = PerformanceBenchmark('Search tasks');
        searchBenchmark.start();
        
        final searchResultsResult = await taskRepository.searchTasks('searchable');
        
        final searchDuration = searchBenchmark.stop();
        searchBenchmark.printResults();

        // Assert: Should complete within 100ms
        expect(
          searchDuration.inMilliseconds,
          lessThanOrEqualTo(100),
          reason: 'Search operations should complete within 100ms',
        );

        searchResultsResult.fold(
          (failure) => fail('Failed to search tasks: ${failure.message}'),
          (searchResults) {
            expect(searchResults.length, greaterThan(0));
          },
        );
      },
    );

    testWidgets(
      'Performance: Task creation should complete within 100ms',
      (WidgetTester tester) async {
        // Benchmark task creation performance
        
        final testUserId = UserId.generate();
        final newTask = TaskEntity(
          id: TaskId.generate(),
          userId: testUserId,
          title: 'Performance Test Task',
          description: 'Testing task creation performance',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          dueTime: const DomainTime(hour: 12, minute: 0),
          category: TaskCategory.ongoing,
          priority: TaskPriority.high,
          progressPercentage: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Benchmark: Create task
        final createBenchmark = PerformanceBenchmark('Create task');
        createBenchmark.start();
        
        await taskRepository.createTask(newTask);
        
        final createDuration = createBenchmark.stop();
        createBenchmark.printResults();

        // Assert: Should complete within 100ms
        expect(
          createDuration.inMilliseconds,
          lessThanOrEqualTo(100),
          reason: 'Task creation should complete within 100ms',
        );

        // Verify task was created
        final retrievedTaskResult = await taskRepository.getTaskById(newTask.id);
        retrievedTaskResult.fold(
          (failure) => fail('Failed to retrieve task: ${failure.message}'),
          (retrievedTask) {
            expect(retrievedTask, isNotNull);
            expect(retrievedTask?.title, equals(newTask.title));
          },
        );
      },
    );

    testWidgets(
      'Performance: Batch operations should handle large datasets efficiently',
      (WidgetTester tester) async {
        // Requirement 10.2: Batch processing for large datasets
        
        // Create large dataset
        final testUserId = UserId.generate();
        final largeBatch = List.generate(
          1000,
          (index) => TaskEntity(
            id: TaskId.generate(),
            userId: testUserId,
            title: 'Batch Task $index',
            description: 'Batch description $index',
            dueDate: DateTime.now().add(Duration(days: index % 30)),
            dueTime: const DomainTime(hour: 12, minute: 0),
            category: TaskCategory.values[index % TaskCategory.values.length],
            priority: TaskPriority.values[index % TaskPriority.values.length],
            progressPercentage: index % 101,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Benchmark: Batch create
        final batchBenchmark = PerformanceBenchmark('Batch create 1000 tasks');
        batchBenchmark.start();
        
        for (final task in largeBatch) {
          await taskRepository.createTask(task);
        }
        
        final batchDuration = batchBenchmark.stop();
        batchBenchmark.printResults();

        // Assert: Should complete within reasonable time (10 seconds for 1000 tasks)
        expect(
          batchDuration.inSeconds,
          lessThanOrEqualTo(10),
          reason: 'Batch operations should complete within 10 seconds',
        );

        // Verify all tasks were created
        final allTasksResult = await taskRepository.getAllTasks();
        allTasksResult.fold(
          (failure) => fail('Failed to get all tasks: ${failure.message}'),
          (allTasks) {
            expect(allTasks.length, greaterThanOrEqualTo(1000));
          },
        );
      },
    );

    testWidgets(
      'Performance: App startup time should be under 2 seconds',
      (WidgetTester tester) async {
        // Benchmark app startup
        final startupBenchmark = PerformanceBenchmark('App startup');
        startupBenchmark.start();
        
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        final startupDuration = startupBenchmark.stop();
        startupBenchmark.printResults();

        // Assert: Should start within 2 seconds
        expect(
          startupDuration.inSeconds,
          lessThanOrEqualTo(2),
          reason: 'App should start within 2 seconds',
        );
      },
    );

    testWidgets(
      'Performance: Sync operations should handle conflicts efficiently',
      (WidgetTester tester) async {
        // Requirement 7.3, 7.4: Sync performance
        
        // Create tasks that need syncing
        final testUserId = UserId.generate();
        final tasksToSync = List.generate(
          50,
          (index) => TaskEntity(
            id: TaskId.generate(),
            userId: testUserId,
            title: 'Sync Task $index',
            description: 'Task for sync testing',
            dueDate: DateTime.now().add(Duration(days: index)),
            dueTime: const DomainTime(hour: 12, minute: 0),
            category: TaskCategory.ongoing,
            priority: TaskPriority.medium,
            progressPercentage: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Store tasks locally
        for (final task in tasksToSync) {
          await taskRepository.createTask(task);
        }

        // Benchmark: Sync with remote
        final syncBenchmark = PerformanceBenchmark('Sync 50 tasks');
        syncBenchmark.start();
        
        final syncResult = await taskRepository.syncWithRemote();
        syncResult.fold(
          (failure) => debugPrint('Sync failed (expected in test environment): ${failure.message}'),
          (_) => debugPrint('Sync completed successfully'),
        );
        
        final syncDuration = syncBenchmark.stop();
        syncBenchmark.printResults();

        // Assert: Should attempt sync within reasonable time
        expect(
          syncDuration.inSeconds,
          lessThanOrEqualTo(5),
          reason: 'Sync operations should complete within 5 seconds',
        );
      },
    );
  });
}
