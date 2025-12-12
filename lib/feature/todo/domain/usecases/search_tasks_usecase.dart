import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class SearchTasksUseCase {
  final TaskRepository repository;

  const SearchTasksUseCase(this.repository);

  ResultFuture<List<TaskEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return repository.getAllTasks();
    }
    return repository.searchTasks(query);
  }
}