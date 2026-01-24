import '../../../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case for creating a new task.
///
/// This use case handles the creation of a new task in the system.
/// It follows the offline-first approach, saving the task locally first
/// and then syncing to the remote server when a connection is available.
///
/// **Usage Example:**
/// ```dart
/// final createTask = CreateTaskUseCase(taskRepository);
/// final task = TaskEntity(
///   id: TaskId.generate(),
///   userId: UserId.fromString('user123'),
///   title: 'Complete project documentation',
///   description: 'Write comprehensive docs for the API',
///   dueDate: DateTime.now().add(Duration(days: 7)),
///   dueTime: DomainTime(hour: 17, minute: 0),
///   category: TaskCategory.ongoing,
///   priority: TaskPriority.high,
///   progressPercentage: 0,
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// 
/// final result = await createTask(task);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('Task created successfully'),
/// );
/// ```
///
/// **Returns:**
/// - `Right(null)` on success
/// - `Left(CacheFailure)` if local storage fails
/// - `Left(NetworkFailure)` if remote sync fails (task is still saved locally)
class CreateTaskUseCase {
  final TaskRepository repository;

  const CreateTaskUseCase(this.repository);

  /// Creates a new task.
  ///
  /// [task] The task entity to create. Must have a unique ID.
  ///
  /// Returns a [ResultVoid] which is either:
  /// - `Right(null)` if the task was created successfully
  /// - `Left(Failure)` if an error occurred
  ResultVoid call(TaskEntity task) async {
    return repository.createTask(task);
  }
}