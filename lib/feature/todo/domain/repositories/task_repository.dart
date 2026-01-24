import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/pagination_helper.dart';
import '../entities/task_entity.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../../../core/domain/value_objects/user_id.dart';

abstract class TaskRepository {
  // Basic CRUD operations
  ResultFuture<List<TaskEntity>> getAllTasks();
  
  ResultFuture<PaginatedResult<TaskEntity>> getTasksPaginated({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  ResultFuture<TaskEntity?> getTaskById(TaskId id);
  
  ResultVoid createTask(TaskEntity task);
  
  ResultVoid updateTask(TaskEntity task);
  
  ResultVoid deleteTask(TaskId id);
  
  // Query operations
  ResultFuture<List<TaskEntity>> getTasksByDateRange(
    DateTime start,
    DateTime end,
  );
  
  ResultFuture<List<TaskEntity>> searchTasks(String query);
  
  ResultFuture<List<TaskEntity>> getTasksByUserId(UserId userId);
  
  // Offline/Online operations
  ResultVoid syncWithRemote();
  
  ResultFuture<List<TaskEntity>> getOfflineTasks();
  
  ResultVoid markForSync(TaskId id);
  
  ResultFuture<bool> hasUnsyncedChanges();
  
  // Export/Import operations
  ResultFuture<String> exportTasks(String format);
  
  ResultFuture<int> importTasks(String data, String format);
}