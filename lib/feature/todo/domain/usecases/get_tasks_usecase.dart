import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  const GetTasksUseCase(this.repository);

  ResultFuture<List<TaskEntity>> call() async {
    return repository.getAllTasks();
  }
}