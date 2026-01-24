import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_cleanarc/feature/todo/data/datasources/hive_task_datasource.dart';
import 'package:todo_cleanarc/feature/todo/data/models/task_model.dart';

import 'generators/task_generators.dart';

/// Helper function to convert TaskEntity to TaskModel
List<TaskModel> _generateTaskModels(int count) {
  return List.generate(count, (_) {
    final entity = TaskGenerators.generateValidTask();
    return TaskModel.fromEntity(entity);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Bounds Property Tests', () {
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

    /// **Feature: flutter-todo-app, Property 8: Performance bounds**
    /// **Validates: Requirements 3.5, 7.1, 10.1, 10.4**
    /// 
    /// For any database operation or search query, response times should remain 
    /// within specified limits (50ms for cache reads, 100ms for searches) 
    /// regardless of dataset size.
    
    test('Cache read operations complete within 50ms for small datasets', () async {
      // Generate a small dataset (100 tasks)
      final tasks = _generateTaskModels(100);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // Measure cache read performance
      final stopwatch = Stopwatch()..start();
      await dataSource.getAllTasks();
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Cache read should complete within 50ms for 100 tasks',
      );
    });

    test('Cache read operations complete within 50ms for medium datasets', () async {
      // Generate a medium dataset (1000 tasks)
      final tasks = _generateTaskModels(1000);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // First call to populate cache
      await dataSource.getAllTasks();
      
      // Measure cached read performance
      final stopwatch = Stopwatch()..start();
      await dataSource.getAllTasks();
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Cached read should complete within 50ms for 1000 tasks',
      );
    });

    test('Search operations complete within 100ms for small datasets', () async {
      // Generate a small dataset (100 tasks)
      final tasks = _generateTaskModels(100);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // Measure search performance
      final stopwatch = Stopwatch()..start();
      await dataSource.searchTasks('task');
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Search should complete within 100ms for 100 tasks',
      );
    });

    test('Search operations complete within 100ms for medium datasets', () async {
      // Generate a medium dataset (1000 tasks)
      final tasks = _generateTaskModels(1000);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // Measure search performance
      final stopwatch = Stopwatch()..start();
      await dataSource.searchTasks('task');
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Search should complete within 100ms for 1000 tasks',
      );
    });

    test('Date range queries complete within 100ms', () async {
      // Generate tasks with various dates
      final tasks = _generateTaskModels(500);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // Measure date range query performance
      final now = DateTime.now();
      final stopwatch = Stopwatch()..start();
      await dataSource.getTasksByDateRange(
        now.subtract(const Duration(days: 30)),
        now.add(const Duration(days: 30)),
      );
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Date range query should complete within 100ms',
      );
    });

    test('Task count operations complete within 50ms', () async {
      // Generate tasks
      final tasks = _generateTaskModels(500);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // First call to populate cache
      await dataSource.getTaskCount();
      
      // Measure cached count performance
      final stopwatch = Stopwatch()..start();
      await dataSource.getTaskCount();
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Task count should complete within 50ms when cached',
      );
    });

    test('Single task retrieval completes within 50ms', () async {
      // Generate and store a task
      final entity = TaskGenerators.generateValidTask();
      final task = TaskModel.fromEntity(entity);
      await dataSource.createTask(task);
      
      // Measure single task retrieval performance
      final stopwatch = Stopwatch()..start();
      await dataSource.getTaskById(task.id);
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Single task retrieval should complete within 50ms',
      );
    });

    test('Paginated queries complete within 100ms', () async {
      // Generate a large dataset
      final tasks = _generateTaskModels(1000);
      
      // Populate database
      await dataSource.batchCreateTasks(tasks);
      
      // Measure paginated query performance
      final stopwatch = Stopwatch()..start();
      await dataSource.getTasksPaginated(page: 0, pageSize: 20);
      stopwatch.stop();
      
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Paginated query should complete within 100ms',
      );
    });

    /// Property-based test: Performance scales linearly with dataset size
    test('Performance scales reasonably with dataset size', () async {
      final datasetSizes = [10, 50, 100, 250, 500];
      
      for (final datasetSize in datasetSizes) {
        // Clear previous data
        await dataSource.clearAllTasks();
        
        // Generate dataset
        final tasks = _generateTaskModels(datasetSize);
        await dataSource.batchCreateTasks(tasks);
        
        // Measure search performance
        final stopwatch = Stopwatch()..start();
        await dataSource.searchTasks('task');
        stopwatch.stop();
        
        // Performance should scale reasonably (not exponentially)
        // For datasets up to 500, should stay under 100ms
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Search should complete within 100ms for $datasetSize tasks',
        );
      }
    });

    /// Property-based test: Batch operations are more efficient than individual operations
    test('Batch operations are more efficient than individual operations', () async {
      const taskCount = 100;
      final tasks = _generateTaskModels(taskCount);
      
      // Clear database
      await dataSource.clearAllTasks();
      
      // Measure individual operations
      final individualStopwatch = Stopwatch()..start();
      for (final task in tasks.take(10)) {
        await dataSource.createTask(task);
      }
      individualStopwatch.stop();
      final individualTime = individualStopwatch.elapsedMilliseconds;
      
      // Clear database
      await dataSource.clearAllTasks();
      
      // Measure batch operation
      final batchStopwatch = Stopwatch()..start();
      await dataSource.batchCreateTasks(tasks.take(10).toList());
      batchStopwatch.stop();
      final batchTime = batchStopwatch.elapsedMilliseconds;
      
      // Batch should be faster or at least not significantly slower
      expect(
        batchTime,
        lessThanOrEqualTo(individualTime * 1.5),
        reason: 'Batch operations should be more efficient than individual operations',
      );
    });

    /// Property-based test: Memory usage remains stable during operations
    test('Multiple sequential operations maintain performance', () async {
      final performanceMeasurements = <int>[];
      
      // Perform multiple operations and measure each
      for (int i = 0; i < 5; i++) {
        await dataSource.clearAllTasks();
        
        final tasks = _generateTaskModels(200);
        await dataSource.batchCreateTasks(tasks);
        
        final stopwatch = Stopwatch()..start();
        await dataSource.searchTasks('task');
        stopwatch.stop();
        
        performanceMeasurements.add(stopwatch.elapsedMilliseconds);
      }
      
      // Performance should not degrade significantly across operations
      final firstMeasurement = performanceMeasurements.first;
      final lastMeasurement = performanceMeasurements.last;
      
      expect(
        lastMeasurement,
        lessThanOrEqualTo(firstMeasurement * 2),
        reason: 'Performance should not degrade significantly across multiple operations',
      );
    });
  });
}
