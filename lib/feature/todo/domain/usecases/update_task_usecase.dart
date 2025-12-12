import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  const UpdateTaskUseCase(this.repository);

  ResultVoid call(TaskEntity task) async {
    return repository.updateTask(task);
  }
}