import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/presentation/auth_presentation.dart';

import '../theme/build_context_color_extension.dart';
import '../theme/app_durations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/injection_container.dart' as di;
import '../services/sync_manager.dart';
import '../services/background_sync_service.dart';
import '../services/app_logger.dart';
import 'sync_status_widget.dart';
import 'global_error_handler.dart';
import 'offline_mode_banner.dart';

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({super.key, required this.child});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;
  late final SyncManager _syncManager;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.task_outlined,
      selectedIcon: Icons.task,
      label: 'Tasks',
      route: '/tasks',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncManager = di.sl<SyncManager>();
    _initializeSyncManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  @override
  void dispose() {
    _syncManager.dispose();
    super.dispose();
  }

  Future<void> _initializeSyncManager() async {
    try {
      await _syncManager.initialize();
    } catch (e) {
      // Handle initialization error silently
      final logger = AppLogger();
      logger.error('Failed to initialize sync manager', e);
    }
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _navigationItems.indexWhere((item) => item.route == location);
    if (index != -1 && index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      context.go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalErrorHandler(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          backgroundColor: context.ongoingTaskColor,
          foregroundColor: context.onOngoingTaskColor,
          elevation: 0,
          actions: [
            // Compact offline indicator
            StreamBuilder<SyncManagerStatus>(
              stream: _syncManager.statusStream,
              initialData: _syncManager.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data!;
                return CompactOfflineIndicator(
                  connectivityStatus: status.connectivityStatus,
                  queuedOperationsCount: 0, // TODO: Get from sync manager
                );
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            // Sync status indicator
            StreamBuilder<SyncManagerStatus>(
              stream: _syncManager.statusStream,
              initialData: _syncManager.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data!;
                return CompactSyncStatusWidget(
                  syncStatus: status.syncStatus,
                  connectivityStatus: status.connectivityStatus,
                  onTap: () => _showSyncStatusDialog(context, status),
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications feature coming soon!'),
                    duration: AppDurations.snackBarShort,
                  ),
                );
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // Offline mode banner (persistent when offline)
            StreamBuilder<SyncManagerStatus>(
              stream: _syncManager.statusStream,
              initialData: _syncManager.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data!;
                return OfflineModeBanner(
                  connectivityStatus: status.connectivityStatus,
                  queuedOperationsCount: 0, // TODO: Get from sync manager
                  onRetrySync: () => _syncManager.triggerSync(),
                );
              },
            ),
            // Sync progress indicator (shown when syncing)
            StreamBuilder<SyncManagerStatus>(
              stream: _syncManager.statusStream,
              initialData: _syncManager.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data!;
                return SyncProgressIndicator(
                  syncStatus: status.syncStatus,
                  totalOperations: 0, // TODO: Get from sync manager
                  completedOperations: 0, // TODO: Get from sync manager
                );
              },
            ),
            // Sync status banner (shown when there are issues)
            StreamBuilder<SyncManagerStatus>(
              stream: _syncManager.statusStream,
              initialData: _syncManager.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data!;
                if (!status.hasIssues) return const SizedBox.shrink();

                return SyncStatusWidget(
                  syncStatus: status.syncStatus,
                  connectivityStatus: status.connectivityStatus,
                  showDetails: true,
                  onRetryPressed: status.syncStatus == SyncStatus.failed
                      ? () => _syncManager.triggerSync()
                      : null,
                );
              },
            ),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: context.ongoingTaskColor,
          unselectedItemColor: context.onSurfaceSecondary,
          backgroundColor: context.surfacePrimary,
          elevation: 8,
          items: _navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ))
              .toList(),
        ),
        floatingActionButton: _shouldShowFAB()
            ? FloatingActionButton(
                onPressed: () => context.push('/task/new'),
                backgroundColor: context.ongoingTaskColor,
                foregroundColor: context.onOngoingTaskColor,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Tasks';
      case 2:
        return 'Profile';
      default:
        return 'TaskFlow';
    }
  }

  bool _shouldShowFAB() {
    // Show FAB on Dashboard and Tasks screens
    return _selectedIndex == 0 || _selectedIndex == 1;
  }

  void _showSyncStatusDialog(BuildContext context, SyncManagerStatus status) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sync, size: 24),
            SizedBox(width: AppSpacing.sm),
            Text('Sync Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Sync Status', status.syncStatus.name),
            const SizedBox(height: AppSpacing.sm),
            _buildStatusRow(
                'Connectivity', status.connectivityStatus.displayName),
            if (status.lastError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildStatusRow('Last Error', status.lastError!.message),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              _syncManager.getStatusDescription(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          if (status.syncStatus == SyncStatus.failed)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _syncManager.triggerSync();
              },
              child: const Text('Retry Sync'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: context.onSurfaceSecondary),
          ),
        ),
      ],
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String userEmail = 'user@example.com';
              String userName = 'User';

              if (state is AuthAuthenticated) {
                userEmail = state.user.email.value;
                userName = state.user.displayName.isNotEmpty
                    ? state.user.displayName
                    : state.user.email.value.split('@')[0];
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: context.ongoingTaskColor,
                ),
                accountName: Text(
                  userName,
                  style: AppTypography.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: context.onOngoingTaskColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.ongoingTaskColor,
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation Items
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_outlined),
            title: const Text('My Tasks'),
            onTap: () {
              Navigator.pop(context);
              context.go('/tasks');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),

          const Divider(),

          // Settings and Actions
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),

          const Spacer(),

          // Logout
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: context.colorScheme.error),
            title: Text('Logout',
                style: TextStyle(color: context.colorScheme.error)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
