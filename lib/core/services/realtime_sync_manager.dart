import 'dart:async';
import '../../feature/todo/data/datasources/hive_task_datasource.dart';
import '../../feature/todo/presentation/bloc/task_list/task_list_bloc.dart';
import '../../feature/todo/presentation/bloc/task_list/task_list_event.dart';
import '../services/app_logger.dart';
import '../services/realtime_service.dart';

/// Manages real-time synchronization between Supabase and local storage
/// 
/// This manager:
/// - Listens to real-time events from Supabase
/// - Updates local storage automatically
/// - Notifies BLoCs of changes
/// - Handles conflict resolution
class RealtimeSyncManager {
  final RealtimeService _realtimeService;
  final HiveTaskDataSource _localDataSource;
  final AppLogger _logger;
  
  StreamSubscription<TaskRealtimeEvent>? _subscription;
  TaskListBloc? _taskListBloc;

  RealtimeSyncManager({
    required RealtimeService realtimeService,
    required HiveTaskDataSource localDataSource,
    required AppLogger logger,
  })  : _realtimeService = realtimeService,
        _localDataSource = localDataSource,
        _logger = logger;

  /// Start listening to real-time updates
  Future<void> start(String userId, {TaskListBloc? taskListBloc}) async {
    _taskListBloc = taskListBloc;
    
    try {
      // Subscribe to real-time updates
      await _realtimeService.subscribeToTasks(userId);
      
      // Listen to events and sync with local storage
      _subscription = _realtimeService.taskUpdates.listen(
        _handleRealtimeEvent,
        onError: (error) {
          _logger.error('Real-time subscription error', error);
        },
      );
      
      _logger.info('RealtimeSyncManager started for user: $userId');
    } catch (e) {
      _logger.error('Failed to start RealtimeSyncManager', e);
      rethrow;
    }
  }

  /// Stop listening to real-time updates
  Future<void> stop() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      await _realtimeService.unsubscribe();
      _taskListBloc = null;
      _logger.info('RealtimeSyncManager stopped');
    } catch (e) {
      _logger.error('Failed to stop RealtimeSyncManager', e);
    }
  }

  Future<void> _handleRealtimeEvent(TaskRealtimeEvent event) async {
    try {
      _logger.debug('Handling real-time event: ${event.type}');

      switch (event.type) {
        case RealtimeEventType.insert:
          await _handleInsert(event);
          break;
        case RealtimeEventType.update:
          await _handleUpdate(event);
          break;
        case RealtimeEventType.delete:
          await _handleDelete(event);
          break;
      }

      // Refresh the task list in the UI
      _taskListBloc?.add(const TaskListLoadRequested());
    } catch (e) {
      _logger.error('Error handling real-time event', e);
    }
  }

  Future<void> _handleInsert(TaskRealtimeEvent event) async {
    if (event.task == null) return;

    final task = event.task!;
    
    // Check if task already exists locally
    final existingTask = await _localDataSource.getTaskById(task.id);
    
    if (existingTask == null) {
      // New task from remote, add it locally
      await _localDataSource.createTask(task);
      await _localDataSource.markTaskSynced(task.id);
      _logger.info('Inserted task from real-time: ${task.id}');
    } else {
      // Task already exists, check if we need to update
      if (task.updatedAt.isAfter(existingTask.updatedAt)) {
        await _localDataSource.updateTask(task);
        await _localDataSource.markTaskSynced(task.id);
        _logger.info('Updated existing task from real-time: ${task.id}');
      }
    }
  }

  Future<void> _handleUpdate(TaskRealtimeEvent event) async {
    if (event.task == null) return;

    final task = event.task!;
    
    // Check if task exists locally
    final existingTask = await _localDataSource.getTaskById(task.id);
    
    if (existingTask == null) {
      // Task doesn't exist locally, create it
      await _localDataSource.createTask(task);
      await _localDataSource.markTaskSynced(task.id);
      _logger.info('Created task from real-time update: ${task.id}');
    } else {
      // Resolve conflicts using timestamp comparison
      if (task.updatedAt.isAfter(existingTask.updatedAt)) {
        // Remote is newer, update local
        await _localDataSource.updateTask(task);
        await _localDataSource.markTaskSynced(task.id);
        _logger.info('Updated task from real-time: ${task.id}');
      } else if (existingTask.updatedAt.isAfter(task.updatedAt) && existingTask.needsSync) {
        // Local is newer and needs sync, keep local version
        _logger.info('Keeping local version (newer): ${task.id}');
      } else {
        // Same timestamp or local doesn't need sync, use remote
        await _localDataSource.updateTask(task);
        await _localDataSource.markTaskSynced(task.id);
        _logger.info('Synced task from real-time: ${task.id}');
      }
    }
  }

  Future<void> _handleDelete(TaskRealtimeEvent event) async {
    if (event.taskId == null) return;

    final taskId = event.taskId!;
    
    // Check if task exists locally
    final existingTask = await _localDataSource.getTaskById(taskId);
    
    if (existingTask != null) {
      // Delete locally
      await _localDataSource.deleteTask(taskId);
      _logger.info('Deleted task from real-time: $taskId');
    }
  }

  /// Dispose of resources
  void dispose() {
    stop();
  }
}
