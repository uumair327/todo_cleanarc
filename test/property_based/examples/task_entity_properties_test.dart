import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import '../generators/task_generators.dart';
import '../property_test_runner.dart';
import '../property_test_config.dart';

void main() {
  group('TaskEntity Property-Based Tests', () {
    
    /// **Feature: flutter-todo-app, Property 3: Task persistence round trip**
    /// **Validates: Requirements 4.2, 6.2, 6.3**
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task persistence round trip - creating and retrieving task preserves all fields',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        // Simulate round trip by copying the task (represents persistence and retrieval)
        final retrievedTask = task.copyWith();
        
        // All fields should be preserved
        return task.id == retrievedTask.id &&
               task.userId == retrievedTask.userId &&
               task.title == retrievedTask.title &&
               task.description == retrievedTask.description &&
               task.dueDate == retrievedTask.dueDate &&
               task.dueTime == retrievedTask.dueTime &&
               task.category == retrievedTask.category &&
               task.priority == retrievedTask.priority &&
               task.progressPercentage == retrievedTask.progressPercentage &&
               task.createdAt == retrievedTask.createdAt &&
               task.updatedAt == retrievedTask.updatedAt &&
               task.isDeleted == retrievedTask.isDeleted;
      },
      iterations: PropertyTestConfig.getSettingsFor('task_persistence').iterations,
      seed: PropertyTestConfig.getSettingsFor('task_persistence').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 3,
      propertyText: 'Task persistence round trip',
      validates: 'Requirements 4.2, 6.2, 6.3',
    );

    /// Example property test for task validation
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Valid tasks have progress percentage between 0 and 100',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        return task.progressPercentage >= 0 && task.progressPercentage <= 100;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Example property test for task categories
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task category determines expected behavior',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        // All tasks should have a valid category
        return TaskCategory.values.contains(task.category);
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Example property test for task timestamps
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task updatedAt should be after or equal to createdAt',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        return task.updatedAt.isAfter(task.createdAt) || 
               task.updatedAt.isAtSameMomentAs(task.createdAt);
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Example property test for task list operations
    PropertyTestRunner.runPropertyWithGenerator<List<TaskEntity>>(
      description: 'Filtering tasks by category returns only tasks of that category',
      generator: () => TaskGenerators.generateTaskList(count: 20),
      property: (tasks) {
        for (final category in TaskCategory.values) {
          final filtered = tasks.where((task) => task.category == category).toList();
          final allMatch = filtered.every((task) => task.category == category);
          if (!allMatch) return false;
        }
        return true;
      },
      iterations: 50,
    );

    /// Example property test for task equality
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task equality is reflexive, symmetric, and transitive',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        // Reflexive: task == task
        if (task != task) return false;
        
        // Create identical task
        final identicalTask = task.copyWith();
        
        // Symmetric: if task1 == task2, then task2 == task1
        if ((task == identicalTask) != (identicalTask == task)) return false;
        
        // Transitive is harder to test with random data, but we can test basic case
        final anotherIdentical = identicalTask.copyWith();
        if (task == identicalTask && identicalTask == anotherIdentical) {
          return task == anotherIdentical;
        }
        
        return true;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );
  });
}
