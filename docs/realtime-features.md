# Real-time Features Documentation

This document describes the real-time synchronization features implemented in the Flutter Todo App using Supabase real-time subscriptions.

## Overview

The app now supports real-time updates, allowing multiple devices or users to see changes instantly without manual refresh. This is powered by Supabase's real-time PostgreSQL change data capture (CDC).

## Architecture

### Components

1. **RealtimeService** (`lib/core/services/realtime_service.dart`)
   - Manages Supabase real-time channel subscriptions
   - Listens to INSERT, UPDATE, and DELETE events
   - Broadcasts events to listeners
   - Handles automatic reconnection

2. **RealtimeSyncManager** (`lib/core/services/realtime_sync_manager.dart`)
   - Coordinates between real-time events and local storage
   - Handles conflict resolution
   - Updates BLoCs when changes occur
   - Manages subscription lifecycle

3. **RealtimeStatusIndicator** (`lib/core/widgets/realtime_status_indicator.dart`)
   - Visual indicator of real-time connection status
   - Shows "Live" when connected, "Offline" when disconnected
   - Animated pulse effect for active connections

## Features

### Live Task Updates

When a task is created, updated, or deleted on any device:

1. **Instant Notification**: Other devices receive the change immediately
2. **Automatic Sync**: Local storage is updated automatically
3. **UI Refresh**: Task list refreshes to show the latest data
4. **Conflict Resolution**: Timestamp-based conflict resolution ensures data consistency

### Offline Support

The real-time system works seamlessly with offline mode:

- **Offline Changes**: Changes made offline are queued for sync
- **Automatic Reconnection**: When connection is restored, real-time subscriptions resume
- **Conflict Resolution**: Conflicts between offline and online changes are resolved automatically

### Connection Status

Users can see their real-time connection status:

- **Live Indicator**: Green "Live" badge when connected
- **Offline Indicator**: Grey "Offline" badge when disconnected
- **Animated Pulse**: Visual feedback for active real-time connection

## Usage

### Enabling Real-time for a User

```dart
import 'package:todo_cleanarc/core/services/injection_container.dart';
import 'package:todo_cleanarc/core/services/realtime_sync_manager.dart';

// Get the real-time sync manager
final realtimeSyncManager = sl<RealtimeSyncManager>();

// Start real-time sync for the current user
await realtimeSyncManager.start(
  userId,
  taskListBloc: taskListBloc, // Optional: BLoC to refresh
);
```

### Disabling Real-time

```dart
// Stop real-time sync
await realtimeSyncManager.stop();
```

### Displaying Connection Status

```dart
import 'package:todo_cleanarc/core/widgets/realtime_status_indicator.dart';
import 'package:todo_cleanarc/core/services/injection_container.dart';

// In your widget
RealtimeStatusIndicator(
  realtimeService: sl<RealtimeService>(),
  showWhenDisconnected: true,
)

// Or use the animated version
AnimatedRealtimeIndicator(
  realtimeService: sl<RealtimeService>(),
)
```

## Database Setup

Real-time features require proper database configuration:

### 1. Enable Real-time for Tasks Table

```sql
-- Enable real-time for tasks table
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
```

### 2. Create Notification Trigger (Optional)

```sql
-- Create function to notify on task changes
CREATE OR REPLACE FUNCTION notify_task_change()
RETURNS TRIGGER AS $$
DECLARE
    payload JSON;
BEGIN
    IF TG_OP = 'DELETE' THEN
        payload = json_build_object(
            'operation', TG_OP,
            'record', row_to_json(OLD),
            'user_id', OLD.user_id
        );
    ELSE
        payload = json_build_object(
            'operation', TG_OP,
            'record', row_to_json(NEW),
            'user_id', NEW.user_id
        );
    END IF;
    
    PERFORM pg_notify('task_changes', payload::text);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER task_change_trigger
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION notify_task_change();
```

### 3. Verify Setup

Check that real-time is enabled:

1. Go to Supabase Dashboard → Database → Publications
2. Verify `tasks` table is in `supabase_realtime` publication
3. Check that RLS policies allow real-time access

## Event Flow

### Task Creation

```
Device A                    Supabase                    Device B
   |                           |                           |
   |-- Create Task ----------->|                           |
   |                           |-- INSERT Event ---------->|
   |<-- Success Response ------|                           |
   |                           |                           |-- Update Local DB
   |                           |                           |-- Refresh UI
```

### Task Update

```
Device A                    Supabase                    Device B
   |                           |                           |
   |-- Update Task ----------->|                           |
   |                           |-- UPDATE Event ---------->|
   |<-- Success Response ------|                           |
   |                           |                           |-- Resolve Conflicts
   |                           |                           |-- Update Local DB
   |                           |                           |-- Refresh UI
```

### Task Deletion

```
Device A                    Supabase                    Device B
   |                           |                           |
   |-- Delete Task ----------->|                           |
   |                           |-- DELETE Event ---------->|
   |<-- Success Response ------|                           |
   |                           |                           |-- Delete from Local DB
   |                           |                           |-- Refresh UI
```

## Conflict Resolution

The system uses timestamp-based conflict resolution:

### Rules

1. **Remote Newer**: If remote task has a newer `updated_at`, update local
2. **Local Newer**: If local task is newer and needs sync, keep local version
3. **Same Timestamp**: Use remote version as source of truth

### Example

```dart
// In RealtimeSyncManager._handleUpdate()
if (remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
  // Remote is newer, update local
  await _localDataSource.updateTask(remoteTask);
} else if (localTask.updatedAt.isAfter(remoteTask.updatedAt) && localTask.needsSync) {
  // Local is newer and needs sync, keep local
  // Will be synced to remote later
}
```

## Performance Considerations

### Subscription Management

- **Single Channel**: One channel per user for all task updates
- **Filtered Events**: Only receive events for the current user's tasks
- **Automatic Cleanup**: Subscriptions are cleaned up when user logs out

### Network Efficiency

- **Minimal Payload**: Only changed data is transmitted
- **Batching**: Multiple rapid changes are handled efficiently
- **Reconnection**: Automatic reconnection with exponential backoff

### Memory Management

- **Stream Controllers**: Properly disposed when no longer needed
- **Subscription Cleanup**: Channels are removed when unsubscribed
- **Event Debouncing**: UI refreshes are debounced to prevent excessive updates

## Testing

### Manual Testing

1. **Two Devices Test**:
   - Sign in with the same account on two devices
   - Create a task on Device A
   - Verify it appears on Device B within 1-2 seconds

2. **Offline Test**:
   - Disconnect Device A from internet
   - Create tasks on Device A
   - Reconnect Device A
   - Verify tasks sync to Device B

3. **Conflict Test**:
   - Disconnect both devices
   - Edit the same task on both devices
   - Reconnect both devices
   - Verify conflict resolution (newer timestamp wins)

### Automated Testing

```dart
// Example test for real-time service
test('should receive INSERT events', () async {
  final service = RealtimeService(
    client: mockClient,
    logger: mockLogger,
  );
  
  await service.subscribeToTasks(userId);
  
  // Simulate INSERT event
  // Verify event is received
});
```

## Troubleshooting

### Real-time Not Working

**Symptoms**: Changes don't appear on other devices

**Solutions**:
1. Verify real-time is enabled in Supabase dashboard
2. Check that `tasks` table is in `supabase_realtime` publication
3. Verify RLS policies allow SELECT access
4. Check network connectivity
5. Review Supabase logs for errors

### Connection Drops Frequently

**Symptoms**: "Live" indicator keeps switching to "Offline"

**Solutions**:
1. Check network stability
2. Verify Supabase project is active
3. Check for rate limiting
4. Review connection timeout settings

### Conflicts Not Resolving

**Symptoms**: Old data appears after sync

**Solutions**:
1. Verify timestamp fields are properly set
2. Check conflict resolution logic
3. Ensure `updated_at` triggers are working
4. Review local storage sync status

### High Battery Usage

**Symptoms**: App drains battery quickly

**Solutions**:
1. Reduce subscription frequency
2. Implement connection pooling
3. Use background sync instead of real-time for non-critical updates
4. Optimize event handling logic

## Best Practices

### 1. Graceful Degradation

Always handle real-time failures gracefully:

```dart
try {
  await realtimeSyncManager.start(userId);
} catch (e) {
  // Fall back to periodic sync
  logger.warning('Real-time failed, using periodic sync');
}
```

### 2. User Feedback

Inform users about connection status:

```dart
// Show connection status in UI
RealtimeStatusIndicator(
  realtimeService: realtimeService,
  showWhenDisconnected: true,
)
```

### 3. Resource Cleanup

Always clean up subscriptions:

```dart
@override
void dispose() {
  realtimeSyncManager.stop();
  super.dispose();
}
```

### 4. Error Handling

Handle errors at multiple levels:

```dart
// Service level
_subscription = _realtimeService.taskUpdates.listen(
  _handleRealtimeEvent,
  onError: (error) {
    _logger.error('Real-time error', error: error);
    // Attempt reconnection
  },
);
```

## Future Enhancements

### Planned Features

1. **Presence**: Show which users are currently online
2. **Typing Indicators**: Show when someone is editing a task
3. **Collaborative Editing**: Real-time collaborative task editing
4. **Push Notifications**: Notify users of changes even when app is closed
5. **Optimistic Updates**: Show changes immediately before server confirmation

### Performance Improvements

1. **Delta Sync**: Only sync changed fields, not entire records
2. **Compression**: Compress real-time payloads
3. **Batching**: Batch multiple events for efficiency
4. **Caching**: Cache frequently accessed data

## Resources

- [Supabase Real-time Documentation](https://supabase.com/docs/guides/realtime)
- [PostgreSQL Change Data Capture](https://www.postgresql.org/docs/current/logical-replication.html)
- [Flutter Stream Documentation](https://dart.dev/tutorials/language/streams)

## Support

For issues or questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review Supabase real-time logs
3. Check the project's GitHub issues
4. Contact the development team

---

**Last Updated**: January 2026
**Version**: 1.0.0
