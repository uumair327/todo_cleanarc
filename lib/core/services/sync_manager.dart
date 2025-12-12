import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'background_sync_service.dart';
import 'connectivity_service.dart';
import '../network/network_info.dart';
import '../../feature/todo/domain/repositories/task_repository.dart';
import '../../feature/auth/domain/repositories/auth_repository.dart';

/// Central manager that coordinates background synchronization and connectivity monitoring
/// Provides a unified interface for sync operations and status updates
class SyncManager {
  late final BackgroundSyncService _syncService;
  late final ConnectivityService _connectivityService;
  
  // Combined status streams
  final StreamController<SyncManagerStatus> _statusController = 
      StreamController<SyncManagerStatus>.broadcast();
  
  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  StreamSubscription<ConnectivityStatus>? _connectivityStatusSubscription;
  StreamSubscription<SyncError>? _syncErrorSubscription;
  
  SyncStatus _currentSyncStatus = SyncStatus.idle;
  ConnectivityStatus _currentConnectivityStatus = ConnectivityStatus.none;
  SyncError? _lastSyncError;
  
  SyncManager({
    required TaskRepository taskRepository,
    required AuthRepository authRepository,
    required NetworkInfo networkInfo,
    Connectivity? connectivity,
  }) {
    _syncService = BackgroundSyncService(
      taskRepository: taskRepository,
      authRepository: authRepository,
      networkInfo: networkInfo,
    );
    
    _connectivityService = ConnectivityService(
      connectivity: connectivity ?? Connectivity(),
      networkInfo: networkInfo,
      syncService: _syncService,
    );
    
    _setupStatusListeners();
  }

  /// Stream of combined sync manager status updates
  Stream<SyncManagerStatus> get statusStream => _statusController.stream;
  
  /// Current sync status
  SyncStatus get syncStatus => _currentSyncStatus;
  
  /// Current connectivity status
  ConnectivityStatus get connectivityStatus => _currentConnectivityStatus;
  
  /// Last sync error (if any)
  SyncError? get lastSyncError => _lastSyncError;
  
  /// Current combined status
  SyncManagerStatus get currentStatus => SyncManagerStatus(
    syncStatus: _currentSyncStatus,
    connectivityStatus: _currentConnectivityStatus,
    lastError: _lastSyncError,
  );

  /// Initialize and start all sync services
  Future<void> initialize() async {
    developer.log('Initializing sync manager', name: 'SyncManager');
    
    try {
      // Start connectivity monitoring first
      await _connectivityService.startMonitoring();
      
      // Start background sync service
      _syncService.startPeriodicSync();
      
      developer.log('Sync manager initialized successfully', name: 'SyncManager');
    } catch (e) {
      developer.log('Failed to initialize sync manager: $e', name: 'SyncManager');
      rethrow;
    }
  }

  /// Stop all sync services
  void stop() {
    developer.log('Stopping sync manager', name: 'SyncManager');
    
    _syncService.stopPeriodicSync();
    _connectivityService.stopMonitoring();
  }

  /// Manually trigger a sync operation
  Future<void> triggerSync() async {
    developer.log('Manual sync triggered via sync manager', name: 'SyncManager');
    await _syncService.triggerSync();
  }

  /// Check if there are unsynced changes
  Future<bool> hasUnsyncedChanges() async {
    return await _syncService.hasUnsyncedChanges();
  }

  /// Get user-friendly status description
  String getStatusDescription() {
    if (_currentConnectivityStatus == ConnectivityStatus.none) {
      return 'Offline - Changes will sync when connected';
    }
    
    switch (_currentSyncStatus) {
      case SyncStatus.syncing:
        return 'Syncing your changes...';
      case SyncStatus.upToDate:
        return 'All changes synced';
      case SyncStatus.retrying:
        return 'Retrying sync...';
      case SyncStatus.failed:
        return 'Sync failed - Tap to retry';
      case SyncStatus.offline:
        return 'No internet connection';
      case SyncStatus.idle:
      default:
        return 'Ready to sync';
    }
  }

  /// Check if sync is currently in progress
  bool get isSyncing => _currentSyncStatus == SyncStatus.syncing;
  
  /// Check if currently online
  bool get isOnline => _connectivityService.isOnline;
  
  /// Check if currently offline
  bool get isOffline => _connectivityService.isOffline;

  /// Setup listeners for status updates from individual services
  void _setupStatusListeners() {
    // Listen to sync status changes
    _syncStatusSubscription = _syncService.syncStatusStream.listen(
      (syncStatus) {
        _currentSyncStatus = syncStatus;
        _emitStatusUpdate();
      },
      onError: (error) {
        developer.log('Sync status stream error: $error', name: 'SyncManager');
      },
    );
    
    // Listen to connectivity status changes
    _connectivityStatusSubscription = _connectivityService.connectivityStatusStream.listen(
      (connectivityStatus) {
        _currentConnectivityStatus = connectivityStatus;
        _emitStatusUpdate();
      },
      onError: (error) {
        developer.log('Connectivity status stream error: $error', name: 'SyncManager');
      },
    );
    
    // Listen to sync errors
    _syncErrorSubscription = _syncService.syncErrorStream.listen(
      (syncError) {
        _lastSyncError = syncError;
        _emitStatusUpdate();
      },
      onError: (error) {
        developer.log('Sync error stream error: $error', name: 'SyncManager');
      },
    );
  }

  /// Emit combined status update
  void _emitStatusUpdate() {
    final status = SyncManagerStatus(
      syncStatus: _currentSyncStatus,
      connectivityStatus: _currentConnectivityStatus,
      lastError: _lastSyncError,
    );
    
    _statusController.add(status);
  }

  /// Dispose of all resources
  void dispose() {
    developer.log('Disposing sync manager', name: 'SyncManager');
    
    stop();
    
    _syncStatusSubscription?.cancel();
    _connectivityStatusSubscription?.cancel();
    _syncErrorSubscription?.cancel();
    
    _syncService.dispose();
    _connectivityService.dispose();
    _statusController.close();
  }
}

/// Combined status class containing sync and connectivity information
class SyncManagerStatus {
  final SyncStatus syncStatus;
  final ConnectivityStatus connectivityStatus;
  final SyncError? lastError;
  final DateTime timestamp;

  SyncManagerStatus({
    required this.syncStatus,
    required this.connectivityStatus,
    this.lastError,
  }) : timestamp = DateTime.now();

  /// Check if sync is available (online and not failed)
  bool get canSync => 
      connectivityStatus != ConnectivityStatus.none && 
      syncStatus != SyncStatus.failed;

  /// Check if there are issues that need user attention
  bool get hasIssues => 
      syncStatus == SyncStatus.failed || 
      (connectivityStatus == ConnectivityStatus.none && lastError != null);

  /// Get priority level for status display (higher = more important)
  int get priority {
    if (syncStatus == SyncStatus.failed) return 4;
    if (syncStatus == SyncStatus.syncing) return 3;
    if (connectivityStatus == ConnectivityStatus.none) return 2;
    if (syncStatus == SyncStatus.retrying) return 1;
    return 0;
  }

  @override
  String toString() {
    return 'SyncManagerStatus(sync: ${syncStatus.name}, '
           'connectivity: ${connectivityStatus.name}, '
           'hasError: ${lastError != null}, timestamp: $timestamp)';
  }
}