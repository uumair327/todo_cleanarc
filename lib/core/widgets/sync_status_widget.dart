import 'package:flutter/material.dart';
import '../services/background_sync_service.dart';
import '../services/connectivity_service.dart';
import '../theme/build_context_color_extension.dart';

/// Widget that displays the current sync and connectivity status to the user
/// Provides visual feedback about sync operations and network connectivity
class SyncStatusWidget extends StatelessWidget {
  final SyncStatus syncStatus;
  final ConnectivityStatus connectivityStatus;
  final VoidCallback? onRetryPressed;
  final bool showDetails;

  const SyncStatusWidget({
    super.key,
    required this.syncStatus,
    required this.connectivityStatus,
    this.onRetryPressed,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowStatus()) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(context),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusMessage(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showDetails && _getDetailMessage().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getDetailMessage(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(context).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_shouldShowRetryButton()) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetryPressed,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              color: _getStatusColor(context),
              tooltip: 'Retry sync',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    
    switch (syncStatus) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(context)),
          ),
        );
      case SyncStatus.upToDate:
        iconData = Icons.check_circle;
        break;
      case SyncStatus.offline:
        iconData = Icons.cloud_off;
        break;
      case SyncStatus.retrying:
        iconData = Icons.sync_problem;
        break;
      case SyncStatus.failed:
        iconData = Icons.error;
        break;
      case SyncStatus.idle:
        iconData = Icons.cloud_queue;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: _getStatusColor(context),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (syncStatus) {
      case SyncStatus.syncing:
      case SyncStatus.retrying:
        return context.ongoingTaskColor;
      case SyncStatus.upToDate:
        return context.completedTaskColor;
      case SyncStatus.offline:
        return context.inProcessTaskColor;
      case SyncStatus.failed:
        return context.colorScheme.error;
      case SyncStatus.idle:
        return context.onSurfaceSecondary;
    }
  }

  String _getStatusMessage() {
    switch (syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.upToDate:
        return 'Up to date';
      case SyncStatus.offline:
        return connectivityStatus == ConnectivityStatus.none 
            ? 'Offline' 
            : 'No internet connection';
      case SyncStatus.retrying:
        return 'Retrying sync...';
      case SyncStatus.failed:
        return 'Sync failed';
      case SyncStatus.idle:
        return 'Ready to sync';
    }
  }

  String _getDetailMessage() {
    switch (syncStatus) {
      case SyncStatus.offline:
        return connectivityStatus.displayName;
      case SyncStatus.failed:
        return 'Tap to retry';
      case SyncStatus.retrying:
        return 'Please wait...';
      default:
        return '';
    }
  }

  bool _shouldShowStatus() {
    // Always show status except when idle and online
    return !(syncStatus == SyncStatus.idle && 
             connectivityStatus != ConnectivityStatus.none);
  }

  bool _shouldShowRetryButton() {
    return syncStatus == SyncStatus.failed && onRetryPressed != null;
  }
}

/// Compact version of sync status for use in app bars or status bars
class CompactSyncStatusWidget extends StatelessWidget {
  final SyncStatus syncStatus;
  final ConnectivityStatus connectivityStatus;
  final VoidCallback? onTap;

  const CompactSyncStatusWidget({
    super.key,
    required this.syncStatus,
    required this.connectivityStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (syncStatus == SyncStatus.upToDate && 
        connectivityStatus != ConnectivityStatus.none) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getCompactStatusColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactStatusIcon(context),
            const SizedBox(width: 4),
            Text(
              _getCompactMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getCompactStatusColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatusIcon(BuildContext context) {
    IconData iconData;
    
    switch (syncStatus) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(_getCompactStatusColor(context)),
          ),
        );
      case SyncStatus.offline:
        iconData = Icons.cloud_off;
        break;
      case SyncStatus.failed:
        iconData = Icons.error_outline;
        break;
      case SyncStatus.retrying:
        iconData = Icons.sync_problem;
        break;
      case SyncStatus.upToDate:
      case SyncStatus.idle:
        iconData = Icons.cloud_queue;
        break;
    }

    return Icon(
      iconData,
      size: 12,
      color: _getCompactStatusColor(context),
    );
  }

  Color _getCompactStatusColor(BuildContext context) {
    switch (syncStatus) {
      case SyncStatus.syncing:
      case SyncStatus.retrying:
        return context.ongoingTaskColor;
      case SyncStatus.offline:
        return context.inProcessTaskColor;
      case SyncStatus.failed:
        return context.colorScheme.error;
      case SyncStatus.upToDate:
      case SyncStatus.idle:
        return context.onSurfaceSecondary;
    }
  }

  String _getCompactMessage() {
    switch (syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.retrying:
        return 'Retrying';
      case SyncStatus.upToDate:
      case SyncStatus.idle:
        return 'Sync';
    }
  }
}