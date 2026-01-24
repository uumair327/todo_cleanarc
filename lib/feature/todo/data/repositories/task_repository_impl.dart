import 'package:dartz/dartz.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/hive_task_datasource.dart';
import '../datasources/supabase_task_datasource.dart';
import '../models/task_model.dart';
import '../services/task_export_import_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/pagination_helper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveTaskDataSource _hiveDataSource;
  final SupabaseTaskDataSource _supabaseDataSource;
  final NetworkInfo _networkInfo;
  final TaskExportImportService _exportImportService;

  TaskRepositoryImpl({
    required HiveTaskDataSource hiveDataSource,
    required SupabaseTaskDataSource supabaseDataSource,
    required NetworkInfo networkInfo,
    TaskExportImportService? exportImportService,
  })  : _hiveDataSource = hiveDataSource,
        _supabaseDataSource = supabaseDataSource,
        _networkInfo = networkInfo,
        _exportImportService = exportImportService ?? TaskExportImportService();

  @override
  ResultFuture<List<TaskEntity>> getAllTasks() async {
    try {
      // Always return local data first (offline-first approach)
      final localTasks = await _hiveDataSource.getAllTasks();
      final taskEntities = localTasks.map((model) => model.toEntity()).toList();

      // Try to sync in the background if connected
      if (await _networkInfo.isConnected) {
        // ignore: unawaited_futures
        _syncInBackground();
      }

      return Right(taskEntities);
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Left(failure);
    }
  }

  @override
  ResultFuture<PaginatedResult<TaskEntity>> getTasksPaginated({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Always return local data first (offline-first approach)
      final localResult = await _hiveDataSource.getTasksPaginated(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      );
      
      final taskEntities = localResult.data.map((model) => model.toEntity()).toList();
      final result = PaginatedResult<TaskEntity>(
        data: taskEntities,
        totalCount: localResult.totalCount,
        hasMore: localResult.hasMore,
        currentPage: localResult.currentPage,
        pageSize: localResult.pageSize,
      );

      // Try to sync in the background if connected
      if (await _networkInfo.isConnected) {
        // ignore: unawaited_futures
        _syncInBackground();
      }

      return Right(result);
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Left(failure);
    }
  }

  @override
  ResultFuture<TaskEntity?> getTaskById(TaskId id) async {
    try {
      final taskModel = await _hiveDataSource.getTaskById(id.toString());
      return Right(taskModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve task: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to retrieve task. Please try again.'));
    }
  }

  @override
  ResultVoid createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Always save locally first
      await _hiveDataSource.createTask(taskModel);

      // Try to sync to remote if connected
      if (await _networkInfo.isConnected) {
        try {
          final remoteTask = await _supabaseDataSource.createTask(taskModel);
          // Update local task with remote data and mark as synced
          await _hiveDataSource.updateTask(remoteTask);
          await _hiveDataSource.markTaskSynced(remoteTask.id);
        } on NetworkException {
          // Network error - task will be synced later
        } on ServerException {
          // Server error - task will be synced later
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to create task: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to create task. Please try again.'));
    }
  }

  @override
  ResultVoid updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Always update locally first
      await _hiveDataSource.updateTask(taskModel);

      // Try to sync to remote if connected
      if (await _networkInfo.isConnected) {
        try {
          final remoteTask = await _supabaseDataSource.updateTask(taskModel);
          // Update local task with remote data and mark as synced
          await _hiveDataSource.updateTask(remoteTask);
          await _hiveDataSource.markTaskSynced(remoteTask.id);
        } on NetworkException {
          // Network error - task will be synced later
        } on ServerException {
          // Server error - task will be synced later
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to update task: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to update task. Please try again.'));
    }
  }

  @override
  ResultVoid deleteTask(TaskId id) async {
    try {
      // Always delete locally first (soft delete)
      await _hiveDataSource.deleteTask(id.toString());

      // Try to sync to remote if connected
      if (await _networkInfo.isConnected) {
        try {
          await _supabaseDataSource.deleteTask(id.toString());
          await _hiveDataSource.markTaskSynced(id.toString());
        } on NetworkException {
          // Network error - deletion will be synced later
        } on ServerException {
          // Server error - deletion will be synced later
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to delete task: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to delete task. Please try again.'));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getTasksByDateRange(DateTime start, DateTime end) async {
    try {
      final localTasks = await _hiveDataSource.getTasksByDateRange(start, end);
      final taskEntities = localTasks.map((model) => model.toEntity()).toList();
      return Right(taskEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve tasks by date: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to retrieve tasks. Please try again.'));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> searchTasks(String query) async {
    try {
      final localTasks = await _hiveDataSource.searchTasks(query);
      final taskEntities = localTasks.map((model) => model.toEntity()).toList();
      return Right(taskEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Search failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to search tasks. Please try again.'));
    }
  }

  @override
  ResultVoid syncWithRemote() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Cannot sync: No internet connection. Your changes will be synced when you\'re back online.'));
    }

    try {
      // Get tasks that need syncing
      final tasksNeedingSync = await _hiveDataSource.getTasksNeedingSync();
      
      if (tasksNeedingSync.isEmpty) {
        return const Right(null);
      }

      // Get current user ID (this would come from auth repository in real implementation)
      // For now, we'll assume it's available from the first task
      final userId = tasksNeedingSync.first.userId;

      // Sync with remote
      await _supabaseDataSource.syncTasks(tasksNeedingSync, userId);

      // Mark all tasks as synced
      for (final task in tasksNeedingSync) {
        await _hiveDataSource.markTaskSynced(task.id);
      }

      // Get updated remote tasks and resolve conflicts
      final remoteTasks = await _supabaseDataSource.getAllTasks(userId);
      await _resolveConflicts(remoteTasks);

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: 'Sync failed: ${e.message}. Your changes are saved locally and will sync when connection is restored.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Server error during sync: ${e.message}. Please try again later.'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Local storage error during sync: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Unable to sync tasks. Your changes are saved locally.'));
    }
  }

  Future<void> _syncInBackground() async {
    try {
      await syncWithRemote();
    } catch (e) {
      // Silently fail background sync - user will be notified through UI if needed
    }
  }

  Future<void> _resolveConflicts(List<TaskModel> remoteTasks) async {
    for (final remoteTask in remoteTasks) {
      final localTask = await _hiveDataSource.getTaskById(remoteTask.id);
      
      if (localTask == null) {
        // Remote task doesn't exist locally, add it
        await _hiveDataSource.createTask(remoteTask);
        await _hiveDataSource.markTaskSynced(remoteTask.id);
      } else {
        // Check for conflicts using timestamp comparison
        if (remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
          // Remote is newer, update local
          await _hiveDataSource.updateTask(remoteTask);
          await _hiveDataSource.markTaskSynced(remoteTask.id);
        } else if (localTask.updatedAt.isAfter(remoteTask.updatedAt) && localTask.needsSync) {
          // Local is newer and needs sync, update remote
          try {
            await _supabaseDataSource.updateTask(localTask);
            await _hiveDataSource.markTaskSynced(localTask.id);
          } catch (e) {
            // Failed to update remote, will retry later
          }
        } else {
          // Tasks are in sync
          await _hiveDataSource.markTaskSynced(localTask.id);
        }
      }
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getTasksByUserId(UserId userId) async {
    try {
      final localTasks = await _hiveDataSource.getAllTasks();
      final userTasks = localTasks
          .where((task) => task.userId == userId.toString())
          .map((model) => model.toEntity())
          .toList();
      return Right(userTasks);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getOfflineTasks() async {
    try {
      final localTasks = await _hiveDataSource.getAllTasks();
      final taskEntities = localTasks.map((model) => model.toEntity()).toList();
      return Right(taskEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultVoid markForSync(TaskId id) async {
    try {
      await _hiveDataSource.markTaskForSync(id.toString());
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<bool> hasUnsyncedChanges() async {
    try {
      final tasksNeedingSync = await _hiveDataSource.getTasksNeedingSync();
      return Right(tasksNeedingSync.isNotEmpty);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<String> exportTasks(String format) async {
    try {
      // Get all tasks from local storage
      final localTasks = await _hiveDataSource.getAllTasks();
      final taskEntities = localTasks.map((model) => model.toEntity()).toList();

      // Export based on format
      final String exportedData;
      if (format.toLowerCase() == 'csv') {
        exportedData = _exportImportService.exportToCsv(taskEntities);
      } else if (format.toLowerCase() == 'json') {
        exportedData = _exportImportService.exportToJson(taskEntities);
      } else {
        return const Left(ValidationFailure('Unsupported export format. Use "csv" or "json".'));
      }

      return Right(exportedData);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to export tasks: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to export tasks. Please try again.'));
    }
  }

  @override
  ResultFuture<int> importTasks(String data, String format) async {
    try {
      // Parse tasks based on format
      final List<TaskEntity> tasks;
      if (format.toLowerCase() == 'csv') {
        tasks = _exportImportService.importFromCsv(data);
      } else if (format.toLowerCase() == 'json') {
        tasks = _exportImportService.importFromJson(data);
      } else {
        return const Left(ValidationFailure('Unsupported import format. Use "csv" or "json".'));
      }

      if (tasks.isEmpty) {
        return const Right(0);
      }

      // Import tasks to local storage
      int importedCount = 0;
      for (final task in tasks) {
        try {
          final taskModel = TaskModel.fromEntity(task);
          await _hiveDataSource.createTask(taskModel);
          importedCount++;
        } catch (e) {
          // Skip invalid tasks but continue importing
          continue;
        }
      }

      // Try to sync to remote if connected
      if (await _networkInfo.isConnected) {
        // ignore: unawaited_futures
        _syncInBackground();
      }

      return Right(importedCount);
    } on FormatException catch (e) {
      return Left(ValidationFailure('Invalid data format: ${e.message}'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: 'Failed to import tasks: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unable to import tasks. Please try again.'));
    }
  }
}