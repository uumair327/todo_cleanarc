import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/pagination_helper.dart';
import '../../../../core/utils/memory_manager.dart';

abstract class HiveTaskDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<PaginatedResult<TaskModel>> getTasksPaginated({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TaskModel?> getTaskById(String id);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getTasksByDateRange(DateTime start, DateTime end);
  Future<List<TaskModel>> searchTasks(String query);
  Future<List<TaskModel>> getTasksNeedingSync();
  Future<void> markTaskForSync(String id);
  Future<void> markTaskSynced(String id);
  Future<void> batchCreateTasks(List<TaskModel> tasks);
  Future<void> batchUpdateTasks(List<TaskModel> tasks);
  Future<void> batchDeleteTasks(List<String> ids);
  Future<bool> hasConflict(TaskModel task);
  Future<void> clearAllTasks();
  Future<int> getTaskCount();
  Future<void> optimizeStorage();
}

class HiveTaskDataSourceImpl implements HiveTaskDataSource {
  static const String _boxName = 'tasks';
  static const String _indexBoxName = 'task_indexes';
  Box<TaskModel>? _box;
  Box<Map<String, dynamic>>? _indexBox;

  Future<Box<TaskModel>> get box async {
    _box ??= await Hive.openBox<TaskModel>(_boxName);
    return _box!;
  }

  Future<Box<Map<String, dynamic>>> get indexBox async {
    _indexBox ??= await Hive.openBox<Map<String, dynamic>>(_indexBoxName);
    return _indexBox!;
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      const cacheKey = 'all_tasks';
      final cached = memoryManager.getCachedItem<List<TaskModel>>(cacheKey);
      if (cached != null) return cached;

      final taskBox = await box;
      final tasks = taskBox.values
          .where((task) => !task.isDeleted)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Cache for 5 minutes
      memoryManager.cacheItem(cacheKey, tasks, ttl: const Duration(minutes: 5));
      return tasks;
    } catch (e) {
      throw CacheException(message: 'Failed to get all tasks: $e');
    }
  }

  @override
  Future<PaginatedResult<TaskModel>> getTasksPaginated({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final cacheKey = 'paginated_tasks_${page}_${pageSize}_${searchQuery ?? ''}_${startDate?.millisecondsSinceEpoch ?? ''}_${endDate?.millisecondsSinceEpoch ?? ''}';
      final cached = memoryManager.getCachedItem<PaginatedResult<TaskModel>>(cacheKey);
      if (cached != null) return cached;

      final taskBox = await box;
      var allTasks = taskBox.values.where((task) => !task.isDeleted);

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        allTasks = allTasks.where((task) =>
            task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query));
      }

      if (startDate != null || endDate != null) {
        allTasks = allTasks.where((task) {
          if (startDate != null && endDate != null) {
            return task.dueDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   task.dueDate.isBefore(endDate.add(const Duration(days: 1)));
          } else if (startDate != null) {
            return task.dueDate.isAfter(startDate.subtract(const Duration(days: 1)));
          } else if (endDate != null) {
            return task.dueDate.isBefore(endDate.add(const Duration(days: 1)));
          }
          return true;
        });
      }

      final taskList = allTasks.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final totalCount = taskList.length;
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalCount);
      
      final paginatedTasks = startIndex < totalCount 
          ? taskList.sublist(startIndex, endIndex)
          : <TaskModel>[];

      final result = PaginatedResult<TaskModel>(
        data: paginatedTasks,
        totalCount: totalCount,
        hasMore: endIndex < totalCount,
        currentPage: page,
        pageSize: pageSize,
      );

      // Cache for 2 minutes
      memoryManager.cacheItem(cacheKey, result, ttl: const Duration(minutes: 2));
      return result;
    } catch (e) {
      throw CacheException(message: 'Failed to get paginated tasks: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final taskBox = await box;
      final task = taskBox.get(id);
      return (task != null && !task.isDeleted) ? task : null;
    } catch (e) {
      throw CacheException(message: 'Failed to get task by id: $e');
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      final taskBox = await box;
      task.needsSync = true;
      await taskBox.put(task.id, task);
      await _updateIndexes(task);
      _invalidateCache();
    } catch (e) {
      throw CacheException(message: 'Failed to create task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final taskBox = await box;
      final existingTask = taskBox.get(task.id);
      if (existingTask == null) {
        throw CacheException(message: 'Task not found for update');
      }
      
      task.needsSync = true;
      task.updatedAt = DateTime.now();
      await taskBox.put(task.id, task);
      await _updateIndexes(task);
      _invalidateCache();
    } catch (e) {
      throw CacheException(message: 'Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final taskBox = await box;
      final task = taskBox.get(id);
      if (task == null) {
        throw CacheException(message: 'Task not found for deletion');
      }
      
      // Soft delete - mark as deleted and needs sync
      task.isDeleted = true;
      task.needsSync = true;
      task.updatedAt = DateTime.now();
      await taskBox.put(id, task);
      await _removeFromIndexes(id);
      _invalidateCache();
    } catch (e) {
      throw CacheException(message: 'Failed to delete task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(DateTime start, DateTime end) async {
    try {
      final taskBox = await box;
      return taskBox.values
          .where((task) => 
              !task.isDeleted &&
              task.dueDate.isAfter(start.subtract(const Duration(days: 1))) &&
              task.dueDate.isBefore(end.add(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      throw CacheException(message: 'Failed to get tasks by date range: $e');
    }
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final taskBox = await box;
      final lowercaseQuery = query.toLowerCase();
      
      return taskBox.values
          .where((task) => 
              !task.isDeleted &&
              (task.title.toLowerCase().contains(lowercaseQuery) ||
               task.description.toLowerCase().contains(lowercaseQuery)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw CacheException(message: 'Failed to search tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksNeedingSync() async {
    try {
      final taskBox = await box;
      return taskBox.values
          .where((task) => task.needsSync)
          .toList()
        ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    } catch (e) {
      throw CacheException(message: 'Failed to get tasks needing sync: $e');
    }
  }

  @override
  Future<void> markTaskForSync(String id) async {
    try {
      final taskBox = await box;
      final task = taskBox.get(id);
      if (task != null) {
        task.needsSync = true;
        await taskBox.put(id, task);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to mark task for sync: $e');
    }
  }

  @override
  Future<void> markTaskSynced(String id) async {
    try {
      final taskBox = await box;
      final task = taskBox.get(id);
      if (task != null) {
        task.needsSync = false;
        await taskBox.put(id, task);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to mark task as synced: $e');
    }
  }

  @override
  Future<void> batchCreateTasks(List<TaskModel> tasks) async {
    try {
      final taskBox = await box;
      final Map<String, TaskModel> taskMap = {};
      
      for (final task in tasks) {
        task.needsSync = true;
        taskMap[task.id] = task;
      }
      
      await taskBox.putAll(taskMap);
    } catch (e) {
      throw CacheException(message: 'Failed to batch create tasks: $e');
    }
  }

  @override
  Future<void> batchUpdateTasks(List<TaskModel> tasks) async {
    try {
      final taskBox = await box;
      final Map<String, TaskModel> taskMap = {};
      
      for (final task in tasks) {
        final existingTask = taskBox.get(task.id);
        if (existingTask != null) {
          task.needsSync = true;
          task.updatedAt = DateTime.now();
          taskMap[task.id] = task;
        }
      }
      
      await taskBox.putAll(taskMap);
    } catch (e) {
      throw CacheException(message: 'Failed to batch update tasks: $e');
    }
  }

  @override
  Future<void> batchDeleteTasks(List<String> ids) async {
    try {
      final taskBox = await box;
      final Map<String, TaskModel> taskMap = {};
      
      for (final id in ids) {
        final task = taskBox.get(id);
        if (task != null) {
          task.isDeleted = true;
          task.needsSync = true;
          task.updatedAt = DateTime.now();
          taskMap[id] = task;
        }
      }
      
      await taskBox.putAll(taskMap);
    } catch (e) {
      throw CacheException(message: 'Failed to batch delete tasks: $e');
    }
  }

  @override
  Future<bool> hasConflict(TaskModel task) async {
    try {
      final taskBox = await box;
      final existingTask = taskBox.get(task.id);
      
      if (existingTask == null) return false;
      
      // Check if the existing task has been modified more recently
      return existingTask.updatedAt.isAfter(task.updatedAt);
    } catch (e) {
      throw CacheException(message: 'Failed to check for conflicts: $e');
    }
  }

  @override
  Future<void> clearAllTasks() async {
    try {
      final taskBox = await box;
      final indexBox = await this.indexBox;
      await taskBox.clear();
      await indexBox.clear();
      _invalidateCache();
    } catch (e) {
      throw CacheException(message: 'Failed to clear all tasks: $e');
    }
  }

  @override
  Future<int> getTaskCount() async {
    try {
      const cacheKey = 'task_count';
      final cached = memoryManager.getCachedItem<int>(cacheKey);
      if (cached != null) return cached;

      final taskBox = await box;
      final count = taskBox.values.where((task) => !task.isDeleted).length;
      
      // Cache for 1 minute
      memoryManager.cacheItem(cacheKey, count, ttl: const Duration(minutes: 1));
      return count;
    } catch (e) {
      throw CacheException(message: 'Failed to get task count: $e');
    }
  }

  @override
  Future<void> optimizeStorage() async {
    try {
      final taskBox = await box;
      final indexBox = await this.indexBox;
      
      // Remove permanently deleted tasks older than 30 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final keysToRemove = <String>[];
      
      for (final entry in taskBox.toMap().entries) {
        final task = entry.value;
        if (task.isDeleted && task.updatedAt.isBefore(cutoffDate)) {
          keysToRemove.add(entry.key);
        }
      }
      
      for (final key in keysToRemove) {
        await taskBox.delete(key);
        await _removeFromIndexes(key);
      }
      
      // Compact the database
      await taskBox.compact();
      await indexBox.compact();
      
      _invalidateCache();
    } catch (e) {
      throw CacheException(message: 'Failed to optimize storage: $e');
    }
  }

  /// Update search indexes for faster queries
  Future<void> _updateIndexes(TaskModel task) async {
    try {
      final indexBox = await this.indexBox;
      
      // Title index for search
      final titleWords = task.title.toLowerCase().split(' ');
      for (final word in titleWords) {
        if (word.isNotEmpty) {
          final key = 'title_$word';
          final existing = indexBox.get(key) ?? <String, dynamic>{'ids': <String>[]};
          final ids = List<String>.from(existing['ids'] ?? []);
          if (!ids.contains(task.id)) {
            ids.add(task.id);
            existing['ids'] = ids;
            await indexBox.put(key, existing);
          }
        }
      }
      
      // Date index for filtering
      final dateKey = 'date_${task.dueDate.toIso8601String().split('T')[0]}';
      final existing = indexBox.get(dateKey) ?? <String, dynamic>{'ids': <String>[]};
      final ids = List<String>.from(existing['ids'] ?? []);
      if (!ids.contains(task.id)) {
        ids.add(task.id);
        existing['ids'] = ids;
        await indexBox.put(dateKey, existing);
      }
      
      // Category index
      final categoryKey = 'category_${task.category}';
      final categoryExisting = indexBox.get(categoryKey) ?? <String, dynamic>{'ids': <String>[]};
      final categoryIds = List<String>.from(categoryExisting['ids'] ?? []);
      if (!categoryIds.contains(task.id)) {
        categoryIds.add(task.id);
        categoryExisting['ids'] = categoryIds;
        await indexBox.put(categoryKey, categoryExisting);
      }
    } catch (e) {
      // Index update failures shouldn't break the main operation
      // Log error in production
    }
  }

  /// Remove task from all indexes
  Future<void> _removeFromIndexes(String taskId) async {
    try {
      final indexBox = await this.indexBox;
      
      // Remove from all indexes
      for (final entry in indexBox.toMap().entries) {
        final data = entry.value;
        if (data.containsKey('ids')) {
          final ids = List<String>.from(data['ids'] ?? []);
          if (ids.remove(taskId)) {
            data['ids'] = ids;
            await indexBox.put(entry.key, data);
          }
        }
      }
    } catch (e) {
      // Index update failures shouldn't break the main operation
      // Log error in production
    }
  }

  /// Invalidate memory cache
  void _invalidateCache() {
    memoryManager.clearCache();
  }
}