import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

/// Property-based test generators for TaskEntity and related objects
class TaskGenerators {
  static final Random _random = Random();
  static final Faker _faker = Faker();

  /// Generates a random TaskEntity with valid properties
  static TaskEntity generateValidTask({
    TaskId? id,
    UserId? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    TaskCategory? category,
    TaskPriority? priority,
    int? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    final createdAtValue = createdAt ?? _generateRandomDateTime(
      start: now.subtract(const Duration(days: 365)),
      end: now,
    );
    
    return TaskEntity(
      id: id ?? TaskId.generate(),
      userId: userId ?? UserId.generate(),
      title: title ?? _generateValidTitle(),
      description: description ?? _generateValidDescription(),
      dueDate: dueDate ?? _generateRandomDateTime(
        start: now,
        end: now.add(const Duration(days: 365)),
      ),
      dueTime: dueTime ?? _generateRandomTimeOfDay(),
      category: category ?? _generateRandomTaskCategory(),
      priority: priority ?? _generateRandomTaskPriority(),
      progressPercentage: progressPercentage ?? _generateValidProgressPercentage(),
      createdAt: createdAtValue,
      updatedAt: updatedAt ?? _generateRandomDateTime(
        start: createdAtValue,
        end: now.add(const Duration(hours: 1)),
      ),
      isDeleted: isDeleted ?? _random.nextBool(),
    );
  }

  /// Generates a TaskEntity with invalid properties for negative testing
  static TaskEntity generateInvalidTask() {
    return TaskEntity(
      id: TaskId.generate(),
      userId: UserId.generate(),
      title: _generateInvalidTitle(),
      description: _faker.lorem.sentence(),
      dueDate: DateTime.now(),
      dueTime: TimeOfDay.now(),
      category: TaskCategory.ongoing,
      priority: TaskPriority.medium,
      progressPercentage: _generateInvalidProgressPercentage(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    );
  }

  /// Generates a list of random TaskEntity objects
  static List<TaskEntity> generateTaskList({int? count, UserId? userId}) {
    final taskCount = count ?? _random.nextInt(50) + 1;
    final userIdValue = userId ?? UserId.generate();
    
    return List.generate(taskCount, (index) => 
      generateValidTask(userId: userIdValue)
    );
  }

  /// Generates a random TaskId
  static TaskId generateTaskId() => TaskId.generate();

  /// Generates a random TaskCategory
  static TaskCategory _generateRandomTaskCategory() {
    final categories = TaskCategory.values;
    return categories[_random.nextInt(categories.length)];
  }

  /// Generates a random TaskPriority
  static TaskPriority _generateRandomTaskPriority() {
    final priorities = TaskPriority.values;
    return priorities[_random.nextInt(priorities.length)];
  }

  /// Generates a valid task title (non-empty, reasonable length)
  static String _generateValidTitle() {
    final titles = [
      _faker.lorem.words(2).join(' '),
      _faker.lorem.words(3).join(' '),
      _faker.lorem.words(4).join(' '),
      'Complete ${_faker.lorem.word()}',
      'Review ${_faker.lorem.word()}',
      'Update ${_faker.lorem.word()}',
    ];
    return titles[_random.nextInt(titles.length)];
  }

  /// Generates a valid task description
  static String _generateValidDescription() {
    return _faker.lorem.sentences(_random.nextInt(3) + 1).join(' ');
  }

  /// Generates an invalid title for negative testing
  static String _generateInvalidTitle() {
    final invalidTitles = [
      '', // Empty string
      ' ', // Whitespace only
      '   ', // Multiple whitespaces
    ];
    return invalidTitles[_random.nextInt(invalidTitles.length)];
  }

  /// Generates a valid progress percentage (0-100)
  static int _generateValidProgressPercentage() {
    return _random.nextInt(101); // 0 to 100 inclusive
  }

  /// Generates an invalid progress percentage for negative testing
  static int _generateInvalidProgressPercentage() {
    final invalidValues = [-1, -10, 101, 150, 200];
    return invalidValues[_random.nextInt(invalidValues.length)];
  }

  /// Generates a random DateTime within a range
  static DateTime _generateRandomDateTime({
    required DateTime start,
    required DateTime end,
  }) {
    final difference = end.difference(start).inMilliseconds;
    // Ensure the difference is within valid range for Random.nextInt
    final safeDifference = difference.clamp(1, 2147483647); // Max int32 value
    final randomMilliseconds = _random.nextInt(safeDifference);
    return start.add(Duration(milliseconds: randomMilliseconds));
  }

  /// Generates a random TimeOfDay
  static TimeOfDay _generateRandomTimeOfDay() {
    return TimeOfDay(
      hour: _random.nextInt(24),
      minute: _random.nextInt(60),
    );
  }

  /// Generates a TaskEntity with specific category for testing
  static TaskEntity generateTaskWithCategory(TaskCategory category) {
    return generateValidTask(category: category);
  }

  /// Generates a TaskEntity with specific priority for testing
  static TaskEntity generateTaskWithPriority(TaskPriority priority) {
    return generateValidTask(priority: priority);
  }

  /// Generates a TaskEntity with specific progress for testing
  static TaskEntity generateTaskWithProgress(int progress) {
    return generateValidTask(progressPercentage: progress);
  }

  /// Generates tasks for a specific date range
  static List<TaskEntity> generateTasksInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? count,
  }) {
    final taskCount = count ?? _random.nextInt(20) + 1;
    return List.generate(taskCount, (index) => 
      generateValidTask(
        dueDate: _generateRandomDateTime(start: startDate, end: endDate),
      )
    );
  }
}