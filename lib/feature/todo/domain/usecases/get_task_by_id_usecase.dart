import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  const GetTaskByIdUseCase(this.repository);

  ResultFuture<TaskEntity?> call(TaskId taskId) async {
    return repository.getTaskById(taskId);
  }
}