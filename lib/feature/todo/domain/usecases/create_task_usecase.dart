import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  const CreateTaskUseCase(this.repository);

  ResultVoid call(TaskEntity task) async {
    return repository.createTask(task);
  }
}