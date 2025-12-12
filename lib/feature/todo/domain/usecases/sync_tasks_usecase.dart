import '../../../../core/utils/typedef.dart';
import '../repositories/task_repository.dart';

class SyncTasksUseCase {
  final TaskRepository repository;

  const SyncTasksUseCase(this.repository);

  ResultVoid call() async {
    return repository.syncWithRemote();
  }
}