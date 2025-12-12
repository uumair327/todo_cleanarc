import 'dart:math';
import 'package:flutter/material.dart' as material;
import 'package:faker/faker.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/category_entity.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

/// Property-based test generators for CategoryEntity and related objects
class CategoryGenerators {
  static final Random _random = Random();
  static final Faker _faker = Faker();

  /// Generates a random CategoryEntity with valid properties
  static CategoryEntity generateValidCategory({
    TaskCategory? category,
    String? name,
    material.Color? displayColor,
    int? taskCount,
  }) {
    final categoryValue = category ?? _generateRandomTaskCategory();
    
    return CategoryEntity(
      category: categoryValue,
      name: name ?? _generateCategoryName(categoryValue),
      displayColor: displayColor ?? _generateCategoryColor(categoryValue),
      taskCount: taskCount ?? _generateValidTaskCount(),
    );
  }

  /// Generates a CategoryEntity with invalid properties for negative testing
  static CategoryEntity generateInvalidCategory() {
    return CategoryEntity(
      category: TaskCategory.ongoing,
      name: _generateInvalidCategoryName(),
      displayColor: material.Colors.blue,
      taskCount: _generateInvalidTaskCount(),
    );
  }

  /// Generates a list of random CategoryEntity objects
  static List<CategoryEntity> generateCategoryList({int? count}) {
    final categoryCount = count ?? TaskCategory.values.length;
    return List.generate(categoryCount, (index) => generateValidCategory());
  }

  /// Generates all categories with specific task counts
  static List<CategoryEntity> generateAllCategoriesWithCounts({
    int? ongoingCount,
    int? completedCount,
    int? inProcessCount,
    int? canceledCount,
  }) {
    return [
      CategoryEntity(
        category: TaskCategory.ongoing,
        name: 'Ongoing',
        displayColor: material.Colors.blue,
        taskCount: ongoingCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.completed,
        name: 'Completed',
        displayColor: material.Colors.green,
        taskCount: completedCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.inProcess,
        name: 'In Process',
        displayColor: material.Colors.yellow,
        taskCount: inProcessCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.canceled,
        name: 'Canceled',
        displayColor: material.Colors.red,
        taskCount: canceledCount ?? _generateValidTaskCount(),
      ),
    ];
  }

  /// Generates a random TaskCategory
  static TaskCategory _generateRandomTaskCategory() {
    final categories = TaskCategory.values;
    return categories[_random.nextInt(categories.length)];
  }

  /// Generates a category name based on the category type
  static String _generateCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return 'Ongoing';
      case TaskCategory.completed:
        return 'Completed';
      case TaskCategory.inProcess:
        return 'In Process';
      case TaskCategory.canceled:
        return 'Canceled';
    }
  }

  /// Generates a category color based on the category type
  static material.Color _generateCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return material.Colors.blue;
      case TaskCategory.completed:
        return material.Colors.green;
      case TaskCategory.inProcess:
        return material.Colors.yellow;
      case TaskCategory.canceled:
        return material.Colors.red;
    }
  }

  /// Generates a valid task count (non-negative)
  static int _generateValidTaskCount() {
    return _random.nextInt(1000); // 0 to 999
  }

  /// Generates an invalid category name for negative testing
  static String _generateInvalidCategoryName() {
    final invalidNames = [
      '', // Empty string
      ' ', // Whitespace only
      '   ', // Multiple whitespaces
    ];
    return invalidNames[_random.nextInt(invalidNames.length)];
  }

  /// Generates an invalid task count for negative testing
  static int _generateInvalidTaskCount() {
    final invalidCounts = [-1, -10, -100];
    return invalidCounts[_random.nextInt(invalidCounts.length)];
  }

  /// Generates a CategoryEntity with zero tasks
  static CategoryEntity generateEmptyCategory() {
    return generateValidCategory(taskCount: 0);
  }

  /// Generates a CategoryEntity with many tasks
  static CategoryEntity generateCategoryWithManyTasks() {
    return generateValidCategory(taskCount: _random.nextInt(9000) + 1000); // 1000-9999
  }

  /// Generates categories for dashboard statistics testing
  static Map<TaskCategory, int> generateDashboardStats() {
    return {
      TaskCategory.ongoing: _generateValidTaskCount(),
      TaskCategory.completed: _generateValidTaskCount(),
      TaskCategory.inProcess: _generateValidTaskCount(),
      TaskCategory.canceled: _generateValidTaskCount(),
    };
  }

  /// Generates a specific category with custom properties
  static CategoryEntity generateSpecificCategory({
    required TaskCategory category,
    int? taskCount,
  }) {
    return CategoryEntity(
      category: category,
      name: _generateCategoryName(category),
      displayColor: _generateCategoryColor(category),
      taskCount: taskCount ?? _generateValidTaskCount(),
    );
  }
}