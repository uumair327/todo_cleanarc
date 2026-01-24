import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/feature/todo/presentation/bloc/task_form/task_form_state.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import 'generators/task_generators.dart';
import 'property_test_runner.dart';
import 'property_test_config.dart';

/// Helper extension to convert between DomainTime and TimeOfDay
extension DomainTimeConversion on DomainTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

void main() {
  group('Form Population Property Tests', () {
    /// **Feature: flutter-todo-app, Property 10: Form population accuracy**
    /// **Validates: Requirements 6.1**
    /// 
    /// For any existing task selected for editing, the form fields should be 
    /// populated with the current task data exactly as stored.
    /// 
    /// This property tests that when a task is loaded into the form state,
    /// all fields are accurately populated from the task entity.
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form population accuracy - all task fields populate form state correctly',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        // Simulate form initialization with a task (edit mode)
        final formState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // Verify all fields are populated correctly
        return formState.isEditing == true &&
               formState.originalTask == originalTask &&
               formState.title == originalTask.title &&
               formState.description == originalTask.description &&
               formState.dueDate.year == originalTask.dueDate.year &&
               formState.dueDate.month == originalTask.dueDate.month &&
               formState.dueDate.day == originalTask.dueDate.day &&
               formState.dueTime.hour == originalTask.dueTime.hour &&
               formState.dueTime.minute == originalTask.dueTime.minute &&
               formState.category == originalTask.category &&
               formState.priority == originalTask.priority &&
               formState.progressPercentage == originalTask.progressPercentage;
      },
      iterations: PropertyTestConfig.getSettingsFor('task_persistence').iterations,
      seed: PropertyTestConfig.getSettingsFor('task_persistence').seed,
      featureName: PropertyTestConfig.featureName,
      propertyNumber: 10,
      propertyText: 'Form population accuracy',
      validates: 'Requirements 6.1',
    );

    /// Property test for form state preserves original task reference
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form state maintains reference to original task for edit operations',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final formState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // Original task reference should be preserved
        return formState.originalTask != null &&
               formState.originalTask!.id == originalTask.id &&
               formState.originalTask!.userId == originalTask.userId;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for form validation with populated data
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form populated with valid task data should be valid',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final formState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        ).validateForm();
        
        // Form should be valid when populated with valid task data
        return formState.isValid == true;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for form field updates preserve other fields
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Updating one form field preserves all other populated fields',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        // Initialize form with task data
        final initialFormState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // Update only the title
        const newTitle = 'Updated Title';
        final updatedFormState = initialFormState.copyWith(title: newTitle);
        
        // All other fields should remain unchanged
        return updatedFormState.title == newTitle &&
               updatedFormState.description == originalTask.description &&
               updatedFormState.dueDate == originalTask.dueDate &&
               updatedFormState.dueTime == originalTask.dueTime.toTimeOfDay() &&
               updatedFormState.category == originalTask.category &&
               updatedFormState.priority == originalTask.priority &&
               updatedFormState.progressPercentage == originalTask.progressPercentage &&
               updatedFormState.originalTask == originalTask;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for empty task creates default form state
    test('Empty form initialization creates default state', () {
      final formState = TaskFormState();
      
      expect(formState.isEditing, false);
      expect(formState.originalTask, null);
      expect(formState.title, '');
      expect(formState.description, '');
      expect(formState.category, TaskCategory.ongoing);
      expect(formState.priority, TaskPriority.medium);
      expect(formState.progressPercentage, 0);
      expect(formState.isValid, false);
    });

    /// Property test for form state equality
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form states with identical data are equal',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final formState1 = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        final formState2 = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // States with identical data should be equal
        return formState1 == formState2;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for progress percentage bounds
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form populated with task maintains valid progress percentage bounds',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final formState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // Progress percentage should be within valid bounds
        return formState.progressPercentage >= 0 && 
               formState.progressPercentage <= 100 &&
               formState.progressPercentage == originalTask.progressPercentage;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );

    /// Property test for date and time preservation
    PropertyTestRunner.runPropertyWithGenerator<TaskEntity>(
      description: 'Form preserves exact date and time from task',
      generator: () => TaskGenerators.generateValidTask(),
      property: (originalTask) {
        final formState = TaskFormState(
          isEditing: true,
          originalTask: originalTask,
          title: originalTask.title,
          description: originalTask.description,
          dueDate: originalTask.dueDate,
          dueTime: originalTask.dueTime.toTimeOfDay(),
          category: originalTask.category,
          priority: originalTask.priority,
          progressPercentage: originalTask.progressPercentage,
        );
        
        // Date should match exactly (year, month, day)
        final dateMatches = formState.dueDate.year == originalTask.dueDate.year &&
                           formState.dueDate.month == originalTask.dueDate.month &&
                           formState.dueDate.day == originalTask.dueDate.day;
        
        // Time should match exactly (hour, minute)
        final timeMatches = formState.dueTime.hour == originalTask.dueTime.hour &&
                           formState.dueTime.minute == originalTask.dueTime.minute;
        
        return dateMatches && timeMatches;
      },
      iterations: PropertyTestConfig.defaultIterations,
    );
  });
}
