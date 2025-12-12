# Sync Services Documentation

This directory contains the offline-first synchronization implementation for the Flutter Todo App. The sync system provides automatic background synchronization, connectivity monitoring, and conflict resolution.

## Architecture Overview

The sync system consists of three main components:

1. **BackgroundSyncService** - Handles automatic synchronization with retry logic
2. **ConnectivityService** - Monitors network connectivity and triggers sync on restoration
3. **SyncManager** - Coordinates both services and provides unified status updates

## Components

### BackgroundSyncService

Manages background synchronization of tasks with the remote server.

**Features:**
- Periodic sync every 5 minutes
- Manual sync triggering
- Exponential backoff retry logic (max 3 retries)
- Conflict resolution using timestamp comparison
- Status updates via streams

**Usage:**
```dart
final syncService = BackgroundSyncService(
  taskRepository: taskRepository,
  authRepository: authRepository,
  networkInfo: networkInfo,
);

// Start periodic sync
syncService.startPeriodicSync();

// Manual sync
await syncService.triggerSync();

// Listen to status updates
syncService.syncStatusStream.listen((status) {
  print('Sync status: ${status.name}');
});

// Check for unsynced changes
final hasChanges = await syncService.hasUnsyncedChanges();
```

### ConnectivityService

Monitors network connectivity and automatically triggers sync when connectivity is restored.

**Features:**
- Real-time connectivity monitoring
- Automatic sync trigger on connectivity restoration
- Connectivity status updates
- Support for different connection types (WiFi, Mobile, etc.)

**Usage:**
```dart
final connectivityService = ConnectivityService(
  connectivity: Connectivity(),
  networkInfo: networkInfo,
  syncService: syncService,
);

// Start monitoring
await connectivityService.startMonitoring();

// Listen to connectivity changes
connectivityService.connectivityStatusStream.listen((status) {
  print('Connectivity: ${status.displayName}');
});

// Check current status
final isOnline = connectivityService.isOnline;
```

### SyncManager

Coordinates both services and provides a unified interface for sync operations.

**Features:**
- Unified status updates combining sync and connectivity
- Centralized sync management
- Error handling and user feedback
- Status descriptions for UI display

**Usage:**
```dart
final syncManager = SyncManager(
  taskRepository: taskRepository,
  authRepository: authRepository,
  networkInfo: networkInfo,
);

// Initialize
await syncManager.initialize();

// Listen to combined status
syncManager.statusStream.listen((status) {
  print('Combined status: ${syncManager.getStatusDescription()}');
});

// Manual sync
await syncManager.triggerSync();
```

## UI Integration

### Sync Status Widgets

The system provides two widgets for displaying sync status:

1. **SyncStatusWidget** - Full status display with details
2. **CompactSyncStatusWidget** - Compact status for app bars

**Example:**
```dart
// In app bar
StreamBuilder<SyncManagerStatus>(
  stream: syncManager.statusStream,
  builder: (context, snapshot) {
    final status = snapshot.data!;
    return CompactSyncStatusWidget(
      syncStatus: status.syncStatus,
      connectivityStatus: status.connectivityStatus,
      onTap: () => showSyncDialog(context),
    );
  },
)

// As banner for issues
StreamBuilder<SyncManagerStatus>(
  stream: syncManager.statusStream,
  builder: (context, snapshot) {
    final status = snapshot.data!;
    if (!status.hasIssues) return SizedBox.shrink();
    
    return SyncStatusWidget(
      syncStatus: status.syncStatus,
      connectivityStatus: status.connectivityStatus,
      showDetails: true,
      onRetryPressed: () => syncManager.triggerSync(),
    );
  },
)
```

## Sync Status Types

### SyncStatus
- `idle` - Ready to sync
- `syncing` - Sync in progress
- `upToDate` - All changes synced
- `offline` - No internet connection
- `retrying` - Retrying after failure
- `failed` - Sync failed (max retries exceeded)

### ConnectivityStatus
- `none` - No connection
- `wifi` - WiFi connection
- `mobile` - Mobile data connection
- `ethernet` - Ethernet connection
- `bluetooth` - Bluetooth connection
- `vpn` - VPN connection
- `other` - Other connection type

## Conflict Resolution

The sync system uses timestamp-based conflict resolution:

1. **Local newer than remote** - Local changes are pushed to remote
2. **Remote newer than local** - Remote changes overwrite local
3. **Same timestamp** - No conflict, mark as synced

## Error Handling

The system handles various error scenarios:

- **Network errors** - Retry with exponential backoff
- **Server errors** - Retry with exponential backoff
- **Authentication errors** - Skip sync until re-authenticated
- **Conflict errors** - Resolve using timestamp comparison

## Dependencies

The sync system requires these dependencies:

```yaml
dependencies:
  connectivity_plus: ^6.0.5  # Network connectivity monitoring
```

## Integration with Existing Code

The sync services are integrated into the dependency injection system and can be accessed throughout the app:

```dart
// In BLoCs
final syncManager = sl<SyncManager>();

// Trigger sync after operations
await syncManager.triggerSync();

// Check sync status
final canSync = syncManager.canSync;
```

## Testing

The sync services include comprehensive unit tests covering:

- Sync operation success/failure scenarios
- Connectivity change handling
- Retry logic and error handling
- Status update emissions

Run tests with:
```bash
flutter test test/core/services/
```

## Performance Considerations

- Sync operations run in background threads
- Local-first approach ensures UI responsiveness
- Batch operations for efficient network usage
- Intelligent sync scheduling to avoid unnecessary operations

## Future Enhancements

Potential improvements for the sync system:

1. **Delta sync** - Only sync changed fields
2. **Conflict resolution UI** - Let users choose resolution strategy
3. **Sync queues** - Priority-based sync ordering
4. **Offline indicators** - More detailed offline status
5. **Sync analytics** - Track sync performance and issues