import 'dart:async';
import 'dart:developer' as developer;
import '../../feature/todo/domain/repositories/task_repository.dart';
import '../../feature/auth/domain/repositories/auth_repository.dart';
import '../network/network_info.dart';
import '../error/failures.dart';

/// Service responsible for managing background synchronization of tasks
/// with the remote server. Handles conflict resolution, queue management,
/// and automatic sync triggers.
class BackgroundSyncService {
  final TaskRepository _taskRepository;
  final AuthRepository _authRepository;
  final NetworkInfo _networkInfo;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  final Duration _syncInterval = const Duration(minutes: 5);
  final Duration _retryDelay = const Duration(seconds: 30);
  int _retryCount = 0;
  static const int _maxRetries = 3;
  
  // Stream controllers for sync status updates
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  final StreamController<SyncError> _syncErrorController = 
      StreamController<SyncError>.broadcast();
  
  BackgroundSyncService({
    required TaskRepository taskRepository,
    required AuthRepository authRepository,
    required NetworkInfo networkInfo,
  })  : _taskRepository = taskRepository,
        _authRepository = authRepository,
        _networkInfo = networkInfo;

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  /// Stream of sync errors
  Stream<SyncError> get syncErrorStream => _syncErrorController.stream;
  
  /// Current sync status
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  /// Start the background sync service with periodic synchronization
  void startPeriodicSync() {
    if (_syncTimer?.isActive == true) {
      developer.log('Background sync already running', name: 'BackgroundSyncService');
      return;
    }
    
    developer.log('Starting background sync service', name: 'BackgroundSyncService');
    _updateSyncStatus(SyncStatus.idle);
    
    // Start periodic sync
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (!_isSyncing) {
        _performBackgroundSync();
      }
    });
    
    // Perform initial sync
    _performBackgroundSync();
  }

  /// Stop the background sync service
  void stopPeriodicSync() {
    developer.log('Stopping background sync service', name: 'BackgroundSyncService');
    _syncTimer?.cancel();
    _syncTimer = null;
    _updateSyncStatus(SyncStatus.idle);
  }

  /// Manually trigger a sync operation
  Future<void> triggerSync() async {
    if (_isSyncing) {
      developer.log('Sync already in progress, skipping manual trigger', 
          name: 'BackgroundSyncService');
      return;
    }
    
    developer.log('Manual sync triggered', name: 'BackgroundSyncService');
    await _performSync();
  }

  /// Check if there are unsynced changes
  Future<bool> hasUnsyncedChanges() async {
    try {
      final result = await _taskRepository.hasUnsyncedChanges();
      return result.fold(
        (failure) => false,
        (hasChanges) => hasChanges,
      );
    } catch (e) {
      developer.log('Error checking unsynced changes: $e', 
          name: 'BackgroundSyncService');
      return false;
    }
  }

  /// Perform background sync (non-blocking)
  void _performBackgroundSync() {
    _performSync().catchError((error) {
      // Silently handle background sync errors
      developer.log('Background sync failed: $error', 
          name: 'BackgroundSyncService');
    });
  }

  /// Perform the actual sync operation
  Future<void> _performSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      // Check if user is authenticated
      final isAuthenticated = await _authRepository.isAuthenticated();
      
      if (!isAuthenticated) {
        developer.log('User not authenticated, skipping sync', 
            name: 'BackgroundSyncService');
        _updateSyncStatus(SyncStatus.idle);
        return;
      }

      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        developer.log('No network connection, skipping sync', 
            name: 'BackgroundSyncService');
        _updateSyncStatus(SyncStatus.offline);
        return;
      }

      // Check if there are changes to sync
      final hasChanges = await hasUnsyncedChanges();
      if (!hasChanges) {
        developer.log('No changes to sync', name: 'BackgroundSyncService');
        _updateSyncStatus(SyncStatus.upToDate);
        _retryCount = 0; // Reset retry count on success
        return;
      }

      developer.log('Starting sync operation', name: 'BackgroundSyncService');
      
      // Perform the sync with conflict resolution
      final syncResult = await _taskRepository.syncWithRemote();
      
      syncResult.fold(
        (failure) {
          developer.log('Sync failed: ${failure.message}', 
              name: 'BackgroundSyncService');
          _handleSyncFailure(failure);
        },
        (_) {
          developer.log('Sync completed successfully', 
              name: 'BackgroundSyncService');
          _updateSyncStatus(SyncStatus.upToDate);
          _retryCount = 0; // Reset retry count on success
        },
      );
      
    } catch (e) {
      developer.log('Unexpected sync error: $e', name: 'BackgroundSyncService');
      _handleSyncFailure(ServerFailure(message: 'Unexpected error: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle sync failures with retry logic
  void _handleSyncFailure(Failure failure) {
    _retryCount++;
    
    final syncError = SyncError(
      message: failure.message,
      retryCount: _retryCount,
      maxRetries: _maxRetries,
      canRetry: _retryCount < _maxRetries,
    );
    
    _syncErrorController.add(syncError);
    
    if (_retryCount < _maxRetries) {
      _updateSyncStatus(SyncStatus.retrying);
      
      // Schedule retry with exponential backoff
      final retryDelay = Duration(
        seconds: _retryDelay.inSeconds * _retryCount,
      );
      
      developer.log(
        'Scheduling sync retry ${_retryCount}/$_maxRetries in ${retryDelay.inSeconds}s',
        name: 'BackgroundSyncService',
      );
      
      Timer(retryDelay, () {
        if (!_isSyncing) {
          _performSync();
        }
      });
    } else {
      developer.log('Max retries exceeded, giving up', 
          name: 'BackgroundSyncService');
      _updateSyncStatus(SyncStatus.failed);
    }
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _syncStatusController.add(status);
      
      developer.log('Sync status changed to: ${status.name}', 
          name: 'BackgroundSyncService');
    }
  }

  /// Reset retry count (called when connectivity is restored)
  void resetRetryCount() {
    _retryCount = 0;
    if (_currentStatus == SyncStatus.failed) {
      _updateSyncStatus(SyncStatus.idle);
    }
  }

  /// Dispose of resources
  void dispose() {
    developer.log('Disposing background sync service', 
        name: 'BackgroundSyncService');
    stopPeriodicSync();
    _syncStatusController.close();
    _syncErrorController.close();
  }
}

/// Enumeration of possible sync statuses
enum SyncStatus {
  idle,
  syncing,
  upToDate,
  offline,
  retrying,
  failed,
}

/// Class representing a sync error with retry information
class SyncError {
  final String message;
  final int retryCount;
  final int maxRetries;
  final bool canRetry;
  final DateTime timestamp;

  SyncError({
    required this.message,
    required this.retryCount,
    required this.maxRetries,
    required this.canRetry,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'SyncError(message: $message, retryCount: $retryCount/$maxRetries, '
           'canRetry: $canRetry, timestamp: $timestamp)';
  }
}