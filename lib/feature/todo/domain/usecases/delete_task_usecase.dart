import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  const DeleteTaskUseCase(this.repository);

  ResultVoid call(TaskId taskId) async {
    return repository.deleteTask(taskId);
  }
}