import 'dart:math';
import 'package:todo_cleanarc/feature/todo/domain/entities/category_entity.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

/// Property-based test generators for CategoryEntity and related objects
class CategoryGenerators {
  static final Random _random = Random();

  /// Color values as ARGB integers (matching Flutter Colors)
  static const int _blueColor = 0xFF2196F3;
  static const int _greenColor = 0xFF4CAF50;
  static const int _yellowColor = 0xFFFFEB3B;
  static const int _redColor = 0xFFF44336;

  /// Generates a random CategoryEntity with valid properties
  static CategoryEntity generateValidCategory({
    TaskCategory? category,
    String? name,
    int? colorValue,
    int? taskCount,
  }) {
    final categoryValue = category ?? _generateRandomTaskCategory();
    
    return CategoryEntity(
      category: categoryValue,
      name: name ?? _generateCategoryName(categoryValue),
      colorValue: colorValue ?? _generateCategoryColorValue(categoryValue),
      taskCount: taskCount ?? _generateValidTaskCount(),
    );
  }

  /// Generates a CategoryEntity with invalid properties for negative testing
  static CategoryEntity generateInvalidCategory() {
    return CategoryEntity(
      category: TaskCategory.ongoing,
      name: _generateInvalidCategoryName(),
      colorValue: _blueColor,
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
        colorValue: _blueColor,
        taskCount: ongoingCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.completed,
        name: 'Completed',
        colorValue: _greenColor,
        taskCount: completedCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.inProcess,
        name: 'In Process',
        colorValue: _yellowColor,
        taskCount: inProcessCount ?? _generateValidTaskCount(),
      ),
      CategoryEntity(
        category: TaskCategory.canceled,
        name: 'Canceled',
        colorValue: _redColor,
        taskCount: canceledCount ?? _generateValidTaskCount(),
      ),
    ];
  }

  /// Generates a random TaskCategory
  static TaskCategory _generateRandomTaskCategory() {
    const categories = TaskCategory.values;
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

  /// Generates a category color value based on the category type
  static int _generateCategoryColorValue(TaskCategory category) {
    switch (category) {
      case TaskCategory.ongoing:
        return _blueColor;
      case TaskCategory.completed:
        return _greenColor;
      case TaskCategory.inProcess:
        return _yellowColor;
      case TaskCategory.canceled:
        return _redColor;
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
      colorValue: _generateCategoryColorValue(category),
      taskCount: taskCount ?? _generateValidTaskCount(),
    );
  }
}
