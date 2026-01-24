import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../entities/search_filter.dart';
import '../repositories/task_repository.dart';

/// Use case for advanced task search with multiple filters
class AdvancedSearchTasksUseCase {
  final TaskRepository repository;

  const AdvancedSearchTasksUseCase(this.repository);

  /// Performs advanced search with multiple filter criteria
  ResultFuture<List<TaskEntity>> call(SearchFilter filter) async {
    // Get all tasks first
    final result = await repository.getAllTasks();

    return result.map((tasks) {
      var filteredTasks = tasks.where((task) => !task.isDeleted).toList();

      // Apply search query filter
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        filteredTasks = filteredTasks.where((task) {
          return task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query);
        }).toList();
      }

      // Apply date range filter
      if (filter.startDate != null || filter.endDate != null) {
        filteredTasks = filteredTasks.where((task) {
          final taskDate = task.dueDate;

          if (filter.startDate != null && filter.endDate != null) {
            return taskDate.isAfter(filter.startDate!.subtract(const Duration(days: 1))) &&
                taskDate.isBefore(filter.endDate!.add(const Duration(days: 1)));
          } else if (filter.startDate != null) {
            return taskDate.isAfter(filter.startDate!.subtract(const Duration(days: 1)));
          } else if (filter.endDate != null) {
            return taskDate.isBefore(filter.endDate!.add(const Duration(days: 1)));
          }

          return true;
        }).toList();
      }

      // Apply category filter
      if (filter.categories != null && filter.categories!.isNotEmpty) {
        filteredTasks = filteredTasks.where((task) {
          return filter.categories!.contains(task.category);
        }).toList();
      }

      // Apply priority filter
      if (filter.priorities != null && filter.priorities!.isNotEmpty) {
        filteredTasks = filteredTasks.where((task) {
          return filter.priorities!.contains(task.priority);
        }).toList();
      }

      // Apply progress filter
      if (filter.minProgress != null || filter.maxProgress != null) {
        filteredTasks = filteredTasks.where((task) {
          final progress = task.progressPercentage;

          if (filter.minProgress != null && filter.maxProgress != null) {
            return progress >= filter.minProgress! && progress <= filter.maxProgress!;
          } else if (filter.minProgress != null) {
            return progress >= filter.minProgress!;
          } else if (filter.maxProgress != null) {
            return progress <= filter.maxProgress!;
          }

          return true;
        }).toList();
      }

      // Apply completion status filter
      if (filter.isCompleted != null) {
        filteredTasks = filteredTasks.where((task) {
          final isCompleted = task.progressPercentage == 100;
          return isCompleted == filter.isCompleted;
        }).toList();
      }

      // Sort by due date (ascending)
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return filteredTasks;
    });
  }
}
