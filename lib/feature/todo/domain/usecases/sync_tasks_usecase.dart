import '../../../../core/utils/typedef.dart';
import '../repositories/task_repository.dart';

/// Use case for synchronizing tasks with the remote server
/// Provides a clean interface for triggering sync operations from the presentation layer
class SyncTasksUseCase {
  final TaskRepository _repository;

  SyncTasksUseCase(this._repository);

  /// Execute sync operation
  /// Returns a Result indicating success or failure
  ResultVoid call() async {
    return await _repository.syncWithRemote();
  }
}