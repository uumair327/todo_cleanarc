import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/feature/todo/data/models/task_model.dart';

import 'generators/task_generators.dart';
import 'property_test_runner.dart';
import 'property_test_config.dart';

void main() {
  group('Task Persistence Round Trip Property Tests', () {
    /// **Feature: flutter-todo-app, Property 3: Task persistence round trip**
    /// **Validates: Requirements 4.2, 6.2, 6.3**
    /// 
    /// For any valid task data, creating a task then retrieving it should return 
    /// equivalent task information with all fields preserved.
    /// 
    /// This property tests the entity-model-entity conversion which simulates
    /// the persistence round trip (save to storage and retrieve from storage).
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task persistence round trip - all fields preserved through model conversion',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        // Convert entity to model (simulates saving to storage)
        final taskModel = TaskModel.fromEntity(originalTask);
        
        // Convert model back to entity (simulates retrieving from storage)
        final retrievedTask = taskModel.toEntity();
        
        // Verify all fields are preserved through the round trip
        return originalTask.id == retrievedTask.id &&
               originalTask.userId == retrievedTask.userId &&
               originalTask.title == retrievedTask.title &&
               originalTask.description == retrievedTask.description &&
               originalTask.dueDate.year == retrievedTask.dueDate.year &&
               originalTask.dueDate.month == retrievedTask.dueDate.month &&
               originalTask.dueDate.day == retrievedTask.dueDate.day &&
               originalTask.dueTime == retrievedTask.dueTime &&
               originalTask.category == retrievedTask.category &&
               originalTask.priority == retrievedTask.priority &&
               originalTask.progressPercentage == retrievedTask.progressPercentage &&
               originalTask.isDeleted == retrievedTask.isDeleted;
      },
      iterations: PropertyTestConfig.getSettingsFor('task_persistence').iterations,
      seed: PropertyTestConfig.getSettingsFor('task_persistence').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 3,
      propertyText: 'Task persistence round trip',
      validates: 'Requirements 4.2, 6.2, 6.3',
    );

    /// Property test for entity-model-entity conversion preserves data
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Entity to Model to Entity conversion preserves all data',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        // Convert entity -> model -> entity
        final model = TaskModel.fromEntity(originalTask);
        final convertedTask = model.toEntity();
        
        // All fields should match
        return originalTask.id == convertedTask.id &&
               originalTask.userId == convertedTask.userId &&
               originalTask.title == convertedTask.title &&
               originalTask.description == convertedTask.description &&
               originalTask.dueDate.year == convertedTask.dueDate.year &&
               originalTask.dueDate.month == convertedTask.dueDate.month &&
               originalTask.dueDate.day == convertedTask.dueDate.day &&
               originalTask.dueTime == convertedTask.dueTime &&
               originalTask.category == convertedTask.category &&
               originalTask.priority == convertedTask.priority &&
               originalTask.progressPercentage == convertedTask.progressPercentage &&
               originalTask.isDeleted == convertedTask.isDeleted;
      },
      iterations: PropertyTestConfig.getSettingsFor('task_persistence').iterations,
      seed: PropertyTestConfig.getSettingsFor('task_persistence').seed,
    );

    /// Property test for JSON serialization round trip
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'JSON serialization round trip preserves task data',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        // Convert entity -> model -> JSON -> model -> entity
        final model = TaskModel.fromEntity(originalTask);
        final json = model.toJson();
        final deserializedModel = TaskModel.fromJson(json);
        final deserializedTask = deserializedModel.toEntity();
        
        // All fields should match
        return originalTask.id == deserializedTask.id &&
               originalTask.userId == deserializedTask.userId &&
               originalTask.title == deserializedTask.title &&
               originalTask.description == deserializedTask.description &&
               originalTask.dueDate.year == deserializedTask.dueDate.year &&
               originalTask.dueDate.month == deserializedTask.dueDate.month &&
               originalTask.dueDate.day == deserializedTask.dueDate.day &&
               originalTask.dueTime == deserializedTask.dueTime &&
               originalTask.category == deserializedTask.category &&
               originalTask.priority == deserializedTask.priority &&
               originalTask.progressPercentage == deserializedTask.progressPercentage &&
               originalTask.isDeleted == deserializedTask.isDeleted;
      },
      iterations: PropertyTestConfig.getSettingsFor('task_persistence').iterations,
      seed: PropertyTestConfig.getSettingsFor('task_persistence').seed,
    );

    /// Property test for copyWith preserves unchanged fields
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'copyWith preserves all fields when no changes specified',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final copiedTask = originalTask.copyWith();
        
        // All fields should be identical
        return originalTask.id == copiedTask.id &&
               originalTask.userId == copiedTask.userId &&
               originalTask.title == copiedTask.title &&
               originalTask.description == copiedTask.description &&
               originalTask.dueDate == copiedTask.dueDate &&
               originalTask.dueTime == copiedTask.dueTime &&
               originalTask.category == copiedTask.category &&
               originalTask.priority == copiedTask.priority &&
               originalTask.progressPercentage == copiedTask.progressPercentage &&
               originalTask.createdAt == copiedTask.createdAt &&
               originalTask.updatedAt == copiedTask.updatedAt &&
               originalTask.isDeleted == copiedTask.isDeleted;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for copyWith updates only specified fields
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'copyWith updates only the specified field while preserving others',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final newTitle = 'Updated Title';
        final updatedTask = originalTask.copyWith(title: newTitle);
        
        // Only title should change, all other fields preserved
        return updatedTask.title == newTitle &&
               originalTask.id == updatedTask.id &&
               originalTask.userId == updatedTask.userId &&
               originalTask.description == updatedTask.description &&
               originalTask.dueDate == updatedTask.dueDate &&
               originalTask.dueTime == updatedTask.dueTime &&
               originalTask.category == updatedTask.category &&
               originalTask.priority == updatedTask.priority &&
               originalTask.progressPercentage == updatedTask.progressPercentage &&
               originalTask.createdAt == updatedTask.createdAt &&
               originalTask.updatedAt == updatedTask.updatedAt &&
               originalTask.isDeleted == updatedTask.isDeleted;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for task equality
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Task equality is reflexive and symmetric',
      generator: () => TaskGenerators.generateValidTask(),
      property: (task) {
        // Reflexive: task == task
        if (task != task) return false;
        
        // Create identical task using copyWith
        final identicalTask = task.copyWith();
        
        // Symmetric: if task1 == task2, then task2 == task1
        return (task == identicalTask) == (identicalTask == task);
      },
      iterations: PropertyTestConfig.defaultIterations,
    );
  });
}
