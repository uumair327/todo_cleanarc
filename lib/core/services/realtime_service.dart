import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../feature/todo/data/models/task_model.dart';
import '../services/app_logger.dart';

/// Service for managing Supabase real-time subscriptions
/// 
/// This service handles:
/// - Real-time task updates from Supabase
/// - Automatic reconnection on connection loss
/// - Event broadcasting to listeners
class RealtimeService {
  final SupabaseClient _client;
  final AppLogger _logger;
  
  RealtimeChannel? _taskChannel;
  final _taskUpdatesController = StreamController<TaskRealtimeEvent>.broadcast();
  bool _isSubscribed = false;

  RealtimeService({
    required SupabaseClient client,
    required AppLogger logger,
  })  : _client = client,
        _logger = logger;

  /// Stream of real-time task events
  Stream<TaskRealtimeEvent> get taskUpdates => _taskUpdatesController.stream;

  /// Check if currently subscribed to real-time updates
  bool get isSubscribed => _isSubscribed;

  /// Subscribe to real-time task updates for a specific user
  Future<void> subscribeToTasks(String userId) async {
    if (_isSubscribed) {
      _logger.info('Already subscribed to task updates');
      return;
    }

    try {
      _logger.info('Subscribing to real-time task updates for user: $userId');

      // Create a channel for task updates
      _taskChannel = _client.channel('tasks:$userId');

      // Listen to INSERT events
      _taskChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'tasks',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _logger.debug('Real-time INSERT event received');
              _handleInsert(payload);
            },
          )
          // Listen to UPDATE events
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'tasks',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _logger.debug('Real-time UPDATE event received');
              _handleUpdate(payload);
            },
          )
          // Listen to DELETE events
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'tasks',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _logger.debug('Real-time DELETE event received');
              _handleDelete(payload);
            },
          )
          .subscribe();

      _isSubscribed = true;
      _logger.info('Successfully subscribed to real-time task updates');
    } catch (e) {
      _logger.error('Failed to subscribe to real-time updates', e);
      _isSubscribed = false;
      rethrow;
    }
  }

  /// Unsubscribe from real-time task updates
  Future<void> unsubscribe() async {
    if (!_isSubscribed || _taskChannel == null) {
      return;
    }

    try {
      _logger.info('Unsubscribing from real-time task updates');
      await _client.removeChannel(_taskChannel!);
      _taskChannel = null;
      _isSubscribed = false;
      _logger.info('Successfully unsubscribed from real-time updates');
    } catch (e) {
      _logger.error('Failed to unsubscribe from real-time updates', e);
      rethrow;
    }
  }

  void _handleInsert(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord.isEmpty) return;

      final task = TaskModel.fromJson(newRecord);
      _taskUpdatesController.add(TaskRealtimeEvent(
        type: RealtimeEventType.insert,
        task: task,
      ));
      
      _logger.debug('Task inserted: ${task.id}');
    } catch (e) {
      _logger.error('Error handling INSERT event', e);
    }
  }

  void _handleUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord.isEmpty) return;

      final task = TaskModel.fromJson(newRecord);
      _taskUpdatesController.add(TaskRealtimeEvent(
        type: RealtimeEventType.update,
        task: task,
      ));
      
      _logger.debug('Task updated: ${task.id}');
    } catch (e) {
      _logger.error('Error handling UPDATE event', e);
    }
  }

  void _handleDelete(PostgresChangePayload payload) {
    try {
      final oldRecord = payload.oldRecord;
      if (oldRecord.isEmpty) return;

      final taskId = oldRecord['id'] as String?;
      if (taskId == null) return;

      _taskUpdatesController.add(TaskRealtimeEvent(
        type: RealtimeEventType.delete,
        taskId: taskId,
      ));
      
      _logger.debug('Task deleted: $taskId');
    } catch (e) {
      _logger.error('Error handling DELETE event', e);
    }
  }

  /// Dispose of resources
  void dispose() {
    _logger.info('Disposing RealtimeService');
    unsubscribe();
    _taskUpdatesController.close();
  }
}

/// Types of real-time events
enum RealtimeEventType {
  insert,
  update,
  delete,
}

/// Real-time event data
class TaskRealtimeEvent {
  final RealtimeEventType type;
  final TaskModel? task;
  final String? taskId;

  TaskRealtimeEvent({
    required this.type,
    this.task,
    this.taskId,
  });

  @override
  String toString() {
    return 'TaskRealtimeEvent(type: $type, taskId: ${task?.id ?? taskId})';
  }
}
