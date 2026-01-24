import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../services/connectivity_service.dart';
import '../services/background_sync_service.dart';

/// Persistent banner that shows when the app is in offline mode
/// Displays sync queue information and provides quick actions
class OfflineModeBanner extends StatelessWidget {
  final ConnectivityStatus connectivityStatus;
  final int queuedOperationsCount;
  final VoidCallback? onRetrySync;
  final bool showQueueCount;

  const OfflineModeBanner({
    super.key,
    required this.connectivityStatus,
    this.queuedOperationsCount = 0,
    this.onRetrySync,
    this.showQueueCount = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show when offline
    if (connectivityStatus != ConnectivityStatus.none) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.orange.shade700,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Working Offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (showQueueCount && queuedOperationsCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$queuedOperationsCount ${queuedOperationsCount == 1 ? 'change' : 'changes'} pending sync',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onRetrySync != null)
                TextButton(
                  onPressed: onRetrySync,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget showing sync progress for queued operations
class SyncProgressIndicator extends StatelessWidget {
  final SyncStatus syncStatus;
  final int totalOperations;
  final int completedOperations;
  final String? currentOperation;

  const SyncProgressIndicator({
    super.key,
    required this.syncStatus,
    this.totalOperations = 0,
    this.completedOperations = 0,
    this.currentOperation,
  });

  @override
  Widget build(BuildContext context) {
    // Only show when syncing
    if (syncStatus != SyncStatus.syncing || totalOperations == 0) {
      return const SizedBox.shrink();
    }

    final progress = totalOperations > 0
        ? completedOperations / totalOperations
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Syncing changes...',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$completedOperations/$totalOperations',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              minHeight: 6,
            ),
          ),
          if (currentOperation != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              currentOperation!,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact offline indicator for app bar
class CompactOfflineIndicator extends StatelessWidget {
  final ConnectivityStatus connectivityStatus;
  final int queuedOperationsCount;

  const CompactOfflineIndicator({
    super.key,
    required this.connectivityStatus,
    this.queuedOperationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Only show when offline
    if (connectivityStatus != ConnectivityStatus.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 14,
            color: Colors.orange.shade900,
          ),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.orange.shade900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (queuedOperationsCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$queuedOperationsCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
