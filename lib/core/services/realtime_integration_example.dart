/// Example integration of real-time features
/// 
/// This file demonstrates how to integrate real-time synchronization
/// into your Flutter app. Copy and adapt this code to your needs.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_cleanarc/feature/todo/presentation/bloc/task_list/task_list_state.dart' show TaskListState;
import '../../feature/todo/presentation/bloc/task_list/task_list_bloc.dart';
import '../services/injection_container.dart';
import '../services/realtime_sync_manager.dart';
import '../services/realtime_service.dart';
import '../widgets/realtime_status_indicator.dart';

/// Example: Integrating real-time into a screen
/// 
/// This shows how to start/stop real-time sync when a screen is shown/hidden
class TaskListScreenWithRealtime extends StatefulWidget {
  final String userId;

  const TaskListScreenWithRealtime({
    super.key,
    required this.userId,
  });

  @override
  State<TaskListScreenWithRealtime> createState() =>
      _TaskListScreenWithRealtimeState();
}

class _TaskListScreenWithRealtimeState
    extends State<TaskListScreenWithRealtime> {
  late RealtimeSyncManager _realtimeSyncManager;
  late RealtimeService _realtimeService;
  late TaskListBloc _taskListBloc;

  @override
  void initState() {
    super.initState();
    
    // Get services from dependency injection
    _realtimeSyncManager = sl<RealtimeSyncManager>();
    _realtimeService = sl<RealtimeService>();
    _taskListBloc = context.read<TaskListBloc>();
    
    // Start real-time sync
    _startRealtimeSync();
  }

  Future<void> _startRealtimeSync() async {
    try {
      await _realtimeSyncManager.start(
        widget.userId,
        taskListBloc: _taskListBloc,
      );
    } catch (e) {
      // Handle error - show snackbar or log
      debugPrint('Failed to start real-time sync: $e');
    }
  }

  @override
  void dispose() {
    // Stop real-time sync when screen is disposed
    _realtimeSyncManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Show real-time connection status
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: RealtimeStatusIndicator(
                realtimeService: _realtimeService,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          // Your task list UI here
          return const Center(
            child: Text('Task List'),
          );
        },
      ),
    );
  }
}

/// Example: Global real-time setup
/// 
/// This shows how to set up real-time sync globally when user logs in
class RealtimeSetupHelper {
  static Future<void> setupRealtimeForUser(String userId) async {
    final realtimeSyncManager = sl<RealtimeSyncManager>();
    
    try {
      await realtimeSyncManager.start(userId);
      debugPrint('Real-time sync started for user: $userId');
    } catch (e) {
      debugPrint('Failed to start real-time sync: $e');
      // Fall back to periodic sync
    }
  }

  static Future<void> teardownRealtime() async {
    final realtimeSyncManager = sl<RealtimeSyncManager>();
    
    try {
      await realtimeSyncManager.stop();
      debugPrint('Real-time sync stopped');
    } catch (e) {
      debugPrint('Failed to stop real-time sync: $e');
    }
  }
}

/// Example: Custom real-time event handler
/// 
/// This shows how to listen to real-time events directly
class CustomRealtimeListener extends StatefulWidget {
  const CustomRealtimeListener({super.key});

  @override
  State<CustomRealtimeListener> createState() => _CustomRealtimeListenerState();
}

class _CustomRealtimeListenerState extends State<CustomRealtimeListener> {
  late RealtimeService _realtimeService;
  
  @override
  void initState() {
    super.initState();
    _realtimeService = sl<RealtimeService>();
    
    // Listen to real-time events
    _realtimeService.taskUpdates.listen((event) {
      // Handle event
      switch (event.type) {
        case RealtimeEventType.insert:
          _handleInsert(event);
          break;
        case RealtimeEventType.update:
          _handleUpdate(event);
          break;
        case RealtimeEventType.delete:
          _handleDelete(event);
          break;
      }
    });
  }

  void _handleInsert(TaskRealtimeEvent event) {
    // Show notification or update UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New task: ${event.task?.title ?? "Unknown"}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleUpdate(TaskRealtimeEvent event) {
    // Handle update
    debugPrint('Task updated: ${event.task?.id}');
  }

  void _handleDelete(TaskRealtimeEvent event) {
    // Handle deletion
    debugPrint('Task deleted: ${event.taskId}');
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Example: Integration with AuthBloc
/// 
/// This shows how to start/stop real-time based on auth state
class RealtimeAuthIntegration {
  static void setupAuthListener(BuildContext context) {
    // This would typically be in your main app widget
    // Listen to auth state changes
    // When user logs in, start real-time
    // When user logs out, stop real-time
    
    // Example:
    // context.read<AuthBloc>().stream.listen((authState) {
    //   if (authState is Authenticated) {
    //     RealtimeSetupHelper.setupRealtimeForUser(authState.user.id);
    //   } else if (authState is Unauthenticated) {
    //     RealtimeSetupHelper.teardownRealtime();
    //   }
    // });
  }
}
