import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/presentation/auth_presentation.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../services/injection_container.dart' as di;
import '../services/sync_manager.dart';
import '../services/background_sync_service.dart';
import 'sync_status_widget.dart';
import 'global_error_handler.dart';

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
      debugPrint('Failed to initialize sync manager: $e');
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: _navigationItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.selectedIcon),
          label: item.label,
        )).toList(),
      ),
      floatingActionButton: _shouldShowFAB() ? FloatingActionButton(
        onPressed: () => context.push('/task/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ) : null,
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
            SizedBox(width: 8),
            Text('Sync Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Sync Status', status.syncStatus.name),
            const SizedBox(height: 8),
            _buildStatusRow('Connectivity', status.connectivityStatus.displayName),
            if (status.lastError != null) ...[
              const SizedBox(height: 8),
              _buildStatusRow('Last Error', status.lastError!.message),
            ],
            const SizedBox(height: 16),
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
            style: const TextStyle(color: AppColors.textSecondary),
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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                accountName: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 16),
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
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}