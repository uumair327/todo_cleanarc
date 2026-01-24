import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case for searching tasks by query string.
///
/// This use case performs a case-insensitive search across task titles
/// and descriptions. If an empty query is provided, it returns all tasks.
///
/// **Search Behavior:**
/// - Case-insensitive matching
/// - Searches both title and description fields
/// - Partial matches are included
/// - Empty/whitespace queries return all tasks
///
/// **Usage Example:**
/// ```dart
/// final searchTasks = SearchTasksUseCase(taskRepository);
/// 
/// // Search for tasks containing "project"
/// final result = await searchTasks('project');
/// result.fold(
///   (failure) => print('Search failed: ${failure.message}'),
///   (tasks) => print('Found ${tasks.length} tasks'),
/// );
/// 
/// // Get all tasks (empty query)
/// final allTasks = await searchTasks('');
/// ```
///
/// **Returns:**
/// - `Right(List<TaskEntity>)` with matching tasks
/// - `Left(CacheFailure)` if local search fails
class SearchTasksUseCase {
  final TaskRepository repository;

  const SearchTasksUseCase(this.repository);

  /// Searches for tasks matching the given query.
  ///
  /// [query] The search string. If empty or whitespace-only, returns all tasks.
  ///
  /// Returns a [ResultFuture] containing:
  /// - `Right(List<TaskEntity>)` with tasks matching the query
  /// - `Left(Failure)` if the search operation fails
  ResultFuture<List<TaskEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return repository.getAllTasks();
    }
    return repository.searchTasks(query);
  }
}