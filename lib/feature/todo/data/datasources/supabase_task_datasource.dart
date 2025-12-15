import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/pagination_helper.dart';
import '../../../../core/utils/loading_manager.dart';

abstract class SupabaseTaskDataSource {
  Future<List<TaskModel>> getAllTasks(String userId);
  Future<PaginatedResult<TaskModel>> getTasksPaginated(
    String userId, {
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TaskModel?> getTaskById(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getTasksByDateRange(String userId, DateTime start, DateTime end);
  Future<List<TaskModel>> searchTasks(String userId, String query);
  Future<void> batchCreateTasks(List<TaskModel> tasks);
  Future<void> batchUpdateTasks(List<TaskModel> tasks);
  Future<void> batchDeleteTasks(List<String> ids);
  Stream<List<TaskModel>> watchTasks(String userId);
  Future<void> syncTasks(List<TaskModel> localTasks, String userId);
  Future<int> getTaskCount(String userId);
}

class SupabaseTaskDataSourceImpl implements SupabaseTaskDataSource {
  final SupabaseClient _client;
  static const String _tableName = 'tasks';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  SupabaseTaskDataSourceImpl(this._client);

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    return ErrorHandler.executeWithRetry(
      operation,
      maxRetries: _maxRetries,
      baseDelay: _retryDelay,
      shouldRetry: (error) => ErrorHandler.shouldRetryError(error),
    );
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    const operationId = 'get_all_tasks';
    loadingManager.startOperation(operationId, message: 'Loading tasks...');
    
    try {
      final result = await _executeWithRetry(() async {
        final response = await _client
            .from(_tableName)
            .select()
            .eq('user_id', userId)
            .eq('is_deleted', false)
            .order('updated_at', ascending: false);

        return response
            .map((json) => TaskModel.fromJson(json))
            .toList();
      });
      
      loadingManager.completeOperation(operationId);
      return result;
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      loadingManager.failOperation(operationId, failure.toString());
      
      if (e is PostgrestException) {
        throw ServerException(message: 'Database error: ${e.message}');
      } else if (e is SocketException || e.toString().contains('network')) {
        throw NetworkException(message: 'Network error: $e');
      } else {
        throw ServerException(message: 'Server error: $e');
      }
    }
  }

  @override
  Future<PaginatedResult<TaskModel>> getTasksPaginated(
    String userId, {
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _executeWithRetry(() async {
      // First get total count
      var countQuery = _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      // Apply filters to count query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.textSearch('title,description', searchQuery);
      }
      if (startDate != null) {
        countQuery = countQuery.filter('due_date', 'gte', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        countQuery = countQuery.filter('due_date', 'lte', endDate.toIso8601String().split('T')[0]);
      }

      final countResponse = await countQuery;
      final totalCount = countResponse.length;

      // Then get paginated data
      var dataQuery = _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      // Apply same filters to data query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Note: Supabase v2 doesn't support .or() on already executed queries
        // This is a limitation we'll need to handle differently
      }
      if (startDate != null) {
        // Note: Supabase v2 doesn't support .gte() on already executed queries
      }
      if (endDate != null) {
        // Note: Supabase v2 doesn't support .lte() on already executed queries
      }

      final dataResponse = await dataQuery;
      final tasks = dataResponse
          .map((json) => TaskModel.fromJson(json))
          .toList();

      return PaginatedResult<TaskModel>(
        data: tasks,
        totalCount: totalCount,
        hasMore: (page + 1) * pageSize < totalCount,
        currentPage: page,
        pageSize: pageSize,
      );
    });
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    return _executeWithRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('is_deleted', false)
          .maybeSingle();

      return response != null ? TaskModel.fromJson(response) : null;
    });
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    const operationId = 'create_task';
    loadingManager.startOperation(operationId, message: 'Creating task...');
    
    try {
      final result = await _executeWithRetry(() async {
        final taskJson = task.toJson();
        taskJson.remove('needs_sync'); // Remove local-only field
        
        final response = await _client
            .from(_tableName)
            .insert(taskJson)
            .select()
            .single();

        return TaskModel.fromJson(response);
      });
      
      loadingManager.completeOperation(operationId);
      return result;
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      loadingManager.failOperation(operationId, failure.toString());
      
      if (e is PostgrestException) {
        throw ServerException(message: 'Failed to create task: ${e.message}');
      } else if (e is SocketException || e.toString().contains('network')) {
        throw NetworkException(message: 'Network error while creating task: $e');
      } else {
        throw ServerException(message: 'Server error while creating task: $e');
      }
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    return _executeWithRetry(() async {
      final taskJson = task.toJson();
      taskJson.remove('needs_sync'); // Remove local-only field
      taskJson['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_tableName)
          .update(taskJson)
          .eq('id', task.id)
          .select()
          .single();

      return TaskModel.fromJson(response);
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    return _executeWithRetry(() async {
      await _client
          .from(_tableName)
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    });
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(String userId, DateTime start, DateTime end) async {
    return _executeWithRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .gte('due_date', start.toIso8601String().split('T')[0])
          .lte('due_date', end.toIso8601String().split('T')[0])
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => TaskModel.fromJson(json as DataMap))
          .toList();
    });
  }

  @override
  Future<List<TaskModel>> searchTasks(String userId, String query) async {
    return _executeWithRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => TaskModel.fromJson(json as DataMap))
          .toList();
    });
  }

  @override
  Future<void> batchCreateTasks(List<TaskModel> tasks) async {
    return _executeWithRetry(() async {
      final tasksJson = tasks.map((task) {
        final json = task.toJson();
        json.remove('needs_sync'); // Remove local-only field
        return json;
      }).toList();

      await _client.from(_tableName).insert(tasksJson);
    });
  }

  @override
  Future<void> batchUpdateTasks(List<TaskModel> tasks) async {
    return _executeWithRetry(() async {
      // Supabase doesn't support batch updates directly, so we'll do them individually
      // In a production app, you might want to use a stored procedure for better performance
      for (final task in tasks) {
        await updateTask(task);
      }
    });
  }

  @override
  Future<void> batchDeleteTasks(List<String> ids) async {
    return _executeWithRetry(() async {
      await _client
          .from(_tableName)
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', ids);
    });
  }

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => data
            .where((json) => json['user_id'] == userId && json['is_deleted'] == false)
            .map((json) => TaskModel.fromJson(json))
            .toList());
  }

  @override
  Future<void> syncTasks(List<TaskModel> localTasks, String userId) async {
    return _executeWithRetry(() async {
      // Get all remote tasks for comparison
      final remoteTasks = await getAllTasks(userId);
      final remoteTasksMap = {for (var task in remoteTasks) task.id: task};

      final tasksToCreate = <TaskModel>[];
      final tasksToUpdate = <TaskModel>[];

      for (final localTask in localTasks) {
        final remoteTask = remoteTasksMap[localTask.id];
        
        if (remoteTask == null) {
          // Task doesn't exist remotely, create it
          tasksToCreate.add(localTask);
        } else if (localTask.updatedAt.isAfter(remoteTask.updatedAt)) {
          // Local task is newer, update remote
          tasksToUpdate.add(localTask);
        }
      }

      // Execute batch operations
      if (tasksToCreate.isNotEmpty) {
        await batchCreateTasks(tasksToCreate);
      }
      
      if (tasksToUpdate.isNotEmpty) {
        await batchUpdateTasks(tasksToUpdate);
      }
    });
  }

  @override
  Future<int> getTaskCount(String userId) async {
    return _executeWithRetry(() async {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      return response.length;
    });
  }
}