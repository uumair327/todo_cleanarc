import 'package:equatable/equatable.dart';
import '../../../../core/domain/enums/task_enums.dart';

/// Domain entity for task categories.
/// Uses int for color to avoid Flutter dependency in domain layer.
class CategoryEntity extends Equatable {
  final TaskCategory category;
  final String name;
  /// Color stored as ARGB int value (e.g., 0xFF2196F3 for blue)
  final int colorValue;
  final int taskCount;

  const CategoryEntity({
    required this.category,
    required this.name,
    required this.colorValue,
    required this.taskCount,
  });

  CategoryEntity copyWith({
    TaskCategory? category,
    String? name,
    int? colorValue,
    int? taskCount,
  }) {
    return CategoryEntity(
      category: category ?? this.category,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  List<Object> get props => [
        category,
        name,
        colorValue,
        taskCount,
      ];
}