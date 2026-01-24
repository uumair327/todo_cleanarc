import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_cleanarc/feature/todo/data/datasources/hive_task_datasource.dart';
import 'package:todo_cleanarc/feature/todo/data/models/task_model.dart';

import '../property_based/generators/task_generators.dart';

/// Large Dataset Performance Tests
/// 
/// Tests performance with 10,000+ tasks to ensure the application
/// can handle large datasets efficiently.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Large Dataset Performance Tests (10,000+ tasks)', () {
    late HiveTaskDataSourceImpl dataSource;

    setUp(() async {
      // Initialize Hive for testing
      Hive.init('./test_hive_data');
      
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskModelAdapter());
      }
      
      dataSource = HiveTaskDataSourceImpl();
      
      // Clear any existing data
      try {
        await dataSource.clearAllTasks();
      } catch (e) {
        // Ignore if boxes don't exist yet
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await dataSource.clearAllTasks();
        await Hive.close();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    /// Helper function to generate task models with guaranteed unique IDs
    List<TaskModel> _generateTaskModels(int count) {
      final tasks = <TaskModel>[];
      final now = DateTime.now();
      
      for (int i = 0; i < count; i++) {
        final entity = TaskGenerators.generateValidTask();
        final model = TaskModel(
          id: 'task_${DateTime.now().microsecondsSinceEpoch}_$i',
          userId: entity.userId.value,
          title: entity.title,
          description: entity.description,
          dueDate: entity.dueDate,
          dueTime: entity.dueTime.toString(),
          category: entity.category.name,
          priority: entity.priority.index,
          progressPercentage: entity.progressPercentage,
          createdAt: entity.createdAt,
          updatedAt: entity.updatedAt,
          isDeleted: false,
          needsSync: false,
        );
        tasks.add(model);
      }
      return tasks;
    }

    test('Batch create 10,000 tasks completes in reasonable time', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      
      final stopwatch = Stopwatch()..start();
      await dataSource.batchCreateTasks(tasks);
      stopwatch.stop();
      
      print('Batch create $taskCount tasks: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within 5 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Batch create of $taskCount tasks should complete within 5 seconds',
      );
      
      // Verify all tasks were created
      final count = await dataSource.getTaskCount();
      expect(count, equals(taskCount));
    });

    test('Paginated query on 10,000 tasks completes within 100ms', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // First call to warm up
      await dataSource.getTasksPaginated(page: 0, pageSize: 20);
      
      // Measure paginated query performance
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.getTasksPaginated(page: 0, pageSize: 20);
      stopwatch.stop();
      
      print('Paginated query (10,000 tasks): ${stopwatch.elapsedMilliseconds}ms');
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Paginated query should complete within 100ms even with 10,000 tasks',
      );
      
      expect(result.data.length, equals(20));
      expect(result.totalCount, equals(taskCount));
      expect(result.hasMore, isTrue);
    });

    test('Search query on 10,000 tasks completes within 200ms', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      
      // Ensure some tasks have searchable content
      for (int i = 0; i < 100; i++) {
        tasks[i].title = 'Task ${tasks[i].title}';
      }
      
      await dataSource.batchCreateTasks(tasks);
      
      // Measure search performance
      final stopwatch = Stopwatch()..start();
      final results = await dataSource.searchTasks('Task');
      stopwatch.stop();
      
      print('Search query (10,000 tasks): ${stopwatch.elapsedMilliseconds}ms');
      
      // Search might take longer with large datasets, allow 200ms
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Search should complete within 200ms for 10,000 tasks',
      );
      
      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(100));
    });

    test('Get task by ID on 10,000 tasks completes within 50ms', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // Pick a random task ID
      final targetId = tasks[5000].id;
      
      // Measure single task retrieval
      final stopwatch = Stopwatch()..start();
      final task = await dataSource.getTaskById(targetId);
      stopwatch.stop();
      
      print('Get task by ID (10,000 tasks): ${stopwatch.elapsedMilliseconds}ms');
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Single task retrieval should complete within 50ms',
      );
      
      expect(task, isNotNull);
      expect(task!.id, equals(targetId));
    });

    test('Date range query on 10,000 tasks completes within 300ms', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));
      final end = now.add(const Duration(days: 30));
      
      // Measure date range query
      final stopwatch = Stopwatch()..start();
      final results = await dataSource.getTasksByDateRange(start, end);
      stopwatch.stop();
      
      print('Date range query (10,000 tasks): ${stopwatch.elapsedMilliseconds}ms');
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
        reason: 'Date range query should complete within 300ms for 10,000 tasks',
      );
      
      expect(results, isNotEmpty);
    });

    test('Task count on 10,000 tasks completes within 50ms (cached)', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // First call to populate cache
      await dataSource.getTaskCount();
      
      // Measure cached count
      final stopwatch = Stopwatch()..start();
      final count = await dataSource.getTaskCount();
      stopwatch.stop();
      
      print('Task count (10,000 tasks, cached): ${stopwatch.elapsedMilliseconds}ms');
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Cached task count should complete within 50ms',
      );
      
      expect(count, equals(taskCount));
    });

    test('Multiple paginated queries maintain performance', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      final measurements = <int>[];
      
      // Query multiple pages
      for (int page = 0; page < 10; page++) {
        final stopwatch = Stopwatch()..start();
        await dataSource.getTasksPaginated(page: page, pageSize: 20);
        stopwatch.stop();
        measurements.add(stopwatch.elapsedMilliseconds);
      }
      
      final avgTime = measurements.reduce((a, b) => a + b) / measurements.length;
      print('Average paginated query time: ${avgTime.toStringAsFixed(2)}ms');
      
      // All queries should complete within 100ms
      for (final time in measurements) {
        expect(
          time,
          lessThan(100),
          reason: 'Each paginated query should complete within 100ms',
        );
      }
    });

    test('Batch update 1,000 tasks completes in reasonable time', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // Update first 1000 tasks
      final tasksToUpdate = tasks.take(1000).map((task) {
        return TaskModel(
          id: task.id,
          userId: task.userId,
          title: '${task.title} - Updated',
          description: task.description,
          dueDate: task.dueDate,
          dueTime: task.dueTime,
          category: task.category,
          priority: task.priority,
          progressPercentage: task.progressPercentage,
          createdAt: task.createdAt,
          updatedAt: DateTime.now(),
          isDeleted: task.isDeleted,
          needsSync: task.needsSync,
        );
      }).toList();
      
      final stopwatch = Stopwatch()..start();
      await dataSource.batchUpdateTasks(tasksToUpdate);
      stopwatch.stop();
      
      print('Batch update 1,000 tasks: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within 2 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Batch update of 1,000 tasks should complete within 2 seconds',
      );
    });

    test('Batch delete 1,000 tasks completes in reasonable time', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // Delete first 1000 tasks
      final idsToDelete = tasks.take(1000).map((task) => task.id).toList();
      
      final stopwatch = Stopwatch()..start();
      await dataSource.batchDeleteTasks(idsToDelete);
      stopwatch.stop();
      
      print('Batch delete 1,000 tasks: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within 2 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Batch delete of 1,000 tasks should complete within 2 seconds',
      );
      
      // Verify tasks were deleted (soft delete)
      final count = await dataSource.getTaskCount();
      expect(count, equals(9000));
    });

    test('Storage optimization on 10,000 tasks completes successfully', () async {
      const taskCount = 10000;
      final tasks = _generateTaskModels(taskCount);
      await dataSource.batchCreateTasks(tasks);
      
      // Delete some old tasks
      final oldDate = DateTime.now().subtract(const Duration(days: 31));
      final oldTasks = tasks.take(1000).map((task) {
        return TaskModel(
          id: task.id,
          userId: task.userId,
          title: task.title,
          description: task.description,
          dueDate: task.dueDate,
          dueTime: task.dueTime,
          category: task.category,
          priority: task.priority,
          progressPercentage: task.progressPercentage,
          createdAt: task.createdAt,
          updatedAt: oldDate,
          isDeleted: true,
          needsSync: task.needsSync,
        );
      }).toList();
      
      await dataSource.batchUpdateTasks(oldTasks);
      
      // Run optimization
      final stopwatch = Stopwatch()..start();
      await dataSource.optimizeStorage();
      stopwatch.stop();
      
      print('Storage optimization: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within 5 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Storage optimization should complete within 5 seconds',
      );
    });

    test('Performance scales linearly with dataset size', () async {
      final datasetSizes = [1000, 2500, 5000, 7500, 10000];
      final measurements = <int, int>{};
      
      for (final size in datasetSizes) {
        await dataSource.clearAllTasks();
        
        final tasks = _generateTaskModels(size);
        await dataSource.batchCreateTasks(tasks);
        
        // Measure paginated query
        final stopwatch = Stopwatch()..start();
        await dataSource.getTasksPaginated(page: 0, pageSize: 20);
        stopwatch.stop();
        
        measurements[size] = stopwatch.elapsedMilliseconds;
        print('Paginated query ($size tasks): ${stopwatch.elapsedMilliseconds}ms');
      }
      
      // Verify performance doesn't degrade exponentially
      // The ratio between 10,000 and 1,000 should be reasonable
      // Handle case where first measurement is 0ms
      final firstTime = measurements[1000]! > 0 ? measurements[1000]! : 1;
      final ratio = measurements[10000]! / firstTime;
      expect(
        ratio,
        lessThan(15.0),
        reason: 'Performance should scale linearly, not exponentially',
      );
    });
  });
}
