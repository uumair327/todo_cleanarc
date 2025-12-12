import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/domain/enums/task_enums.dart';

class CategoryEntity extends Equatable {
  final TaskCategory category;
  final String name;
  final Color displayColor;
  final int taskCount;

  const CategoryEntity({
    required this.category,
    required this.name,
    required this.displayColor,
    required this.taskCount,
  });

  CategoryEntity copyWith({
    TaskCategory? category,
    String? name,
    Color? displayColor,
    int? taskCount,
  }) {
    return CategoryEntity(
      category: category ?? this.category,
      name: name ?? this.name,
      displayColor: displayColor ?? this.displayColor,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  List<Object> get props => [
        category,
        name,
        displayColor,
        taskCount,
      ];
}