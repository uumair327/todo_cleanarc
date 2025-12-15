import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import 'background_sync_service.dart';

/// Service responsible for monitoring network connectivity and triggering
/// sync operations when connectivity is restored. Provides real-time
/// connectivity status updates to the UI.
class ConnectivityService {
  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;
  final BackgroundSyncService _syncService;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  List<ConnectivityResult> _currentConnectivity = [ConnectivityResult.none];
  bool _wasOffline = false;
  
  // Stream controllers for connectivity updates
  final StreamController<ConnectivityStatus> _connectivityStatusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityService({
    required Connectivity connectivity,
    required NetworkInfo networkInfo,
    required BackgroundSyncService syncService,
  })  : _connectivity = connectivity,
        _networkInfo = networkInfo,
        _syncService = syncService;

  /// Stream of connectivity status updates
  Stream<ConnectivityStatus> get connectivityStatusStream => 
      _connectivityStatusController.stream;
  
  /// Current connectivity status
  ConnectivityStatus get currentStatus => _mapConnectivityResults(_currentConnectivity);

  /// Start monitoring connectivity changes
  Future<void> startMonitoring() async {
    developer.log('Starting connectivity monitoring', name: 'ConnectivityService');
    
    try {
      // Get initial connectivity state
      _currentConnectivity = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(_currentConnectivity);
      
      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          developer.log('Connectivity monitoring error: $error', 
              name: 'ConnectivityService');
        },
      );
      
      developer.log('Connectivity monitoring started. Initial state: ${_currentConnectivity.join(", ")}', 
          name: 'ConnectivityService');
      
    } catch (e) {
      developer.log('Failed to start connectivity monitoring: $e', 
          name: 'ConnectivityService');
    }
  }

  /// Stop monitoring connectivity changes
  void stopMonitoring() {
    developer.log('Stopping connectivity monitoring', name: 'ConnectivityService');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    developer.log('Connectivity changed from ${_currentConnectivity.join(", ")} to ${results.join(", ")}', 
        name: 'ConnectivityService');
    
    final previousConnectivity = _currentConnectivity;
    _currentConnectivity = results;
    
    // Update connectivity status
    _updateConnectivityStatus(results);
    
    // Check if we've transitioned from offline to online
    final wasOffline = _isOffline(previousConnectivity);
    final isOnline = _isOnline(results);
    
    if (wasOffline && isOnline) {
      await _handleConnectivityRestored();
    } else if (isOnline && _wasOffline) {
      // Handle case where we were offline but now have connectivity
      await _handleConnectivityRestored();
    }
    
    _wasOffline = _isOffline(results);
  }

  /// Handle connectivity restoration
  Future<void> _handleConnectivityRestored() async {
    developer.log('Connectivity restored, triggering sync', name: 'ConnectivityService');
    
    try {
      // Verify actual internet connectivity (not just network interface)
      final hasInternet = await _networkInfo.isConnected;
      
      if (hasInternet) {
        // Reset sync service retry count
        _syncService.resetRetryCount();
        
        // Trigger immediate sync
        await _syncService.triggerSync();
        
        developer.log('Sync triggered successfully after connectivity restoration', 
            name: 'ConnectivityService');
      } else {
        developer.log('Network interface available but no internet connectivity', 
            name: 'ConnectivityService');
      }
    } catch (e) {
      developer.log('Error handling connectivity restoration: $e', 
          name: 'ConnectivityService');
    }
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final status = _mapConnectivityResults(results);
    _connectivityStatusController.add(status);
    
    developer.log('Connectivity status updated to: ${status.name}', 
        name: 'ConnectivityService');
  }

  /// Map ConnectivityResult list to ConnectivityStatus
  ConnectivityStatus _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.none;
    }
    
    // Prioritize connection types
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.ethernet;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.mobile;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityStatus.vpn;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityStatus.bluetooth;
    } else if (results.contains(ConnectivityResult.other)) {
      return ConnectivityStatus.other;
    }
    
    return ConnectivityStatus.none;
  }

  /// Check if connectivity result indicates offline state
  bool _isOffline(List<ConnectivityResult> results) {
    return results.isEmpty || results.contains(ConnectivityResult.none);
  }

  /// Check if connectivity result indicates online state
  bool _isOnline(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Get user-friendly connectivity description
  String getConnectivityDescription() {
    switch (currentStatus) {
      case ConnectivityStatus.wifi:
        return 'Connected via Wi-Fi';
      case ConnectivityStatus.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityStatus.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityStatus.vpn:
        return 'Connected via VPN';
      case ConnectivityStatus.other:
        return 'Connected via Other Network';
      case ConnectivityStatus.none:
        return 'No Internet Connection';
    }
  }

  /// Check if currently online
  bool get isOnline => currentStatus != ConnectivityStatus.none;

  /// Check if currently offline
  bool get isOffline => currentStatus == ConnectivityStatus.none;

  /// Dispose of resources
  void dispose() {
    developer.log('Disposing connectivity service', name: 'ConnectivityService');
    stopMonitoring();
    _connectivityStatusController.close();
  }
}

/// Enumeration of possible connectivity statuses
enum ConnectivityStatus {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other;
  
  String get displayName {
    switch (this) {
      case ConnectivityStatus.none:
        return 'No Connection';
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.bluetooth:
        return 'Bluetooth';
      case ConnectivityStatus.vpn:
        return 'VPN';
      case ConnectivityStatus.other:
        return 'Other';
    }
  }
}

/// Extension to provide user-friendly names for connectivity status
extension ConnectivityStatusExtension on ConnectivityStatus {
  String get displayName {
    switch (this) {
      case ConnectivityStatus.wifi:
        return 'Wi-Fi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.bluetooth:
        return 'Bluetooth';
      case ConnectivityStatus.vpn:
        return 'VPN';
      case ConnectivityStatus.other:
        return 'Other';
      case ConnectivityStatus.none:
        return 'Offline';
    }
  }

  bool get isConnected => this != ConnectivityStatus.none;
}