import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/presentation/auth_presentation.dart';
import '../../feature/todo/presentation/todo_presentation.dart';
import '../../feature/todo/presentation/screens/export_import_screen.dart';

import '../../feature/auth/presentation/screens/email_verification_screen.dart';
import '../../feature/auth/presentation/screens/auth_callback_screen.dart';
import '../services/injection_container.dart' as di;
import '../widgets/widgets.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/app_colors.dart';

/// A ChangeNotifier that wraps a Stream to notify GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  // Store the refresh notifier to keep it alive
  static GoRouterRefreshStream? _refreshNotifier;

  static GoRouter createRouter(AuthBloc authBloc) {
    _refreshNotifier = GoRouterRefreshStream(authBloc.stream);

    return GoRouter(
      initialLocation: '/',
      refreshListenable: _refreshNotifier,
      redirect: (context, state) => _redirect(context, state, authBloc),
      routes: [
        // Authentication Routes
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          name: 'signIn',
          builder: (context, state) => BlocProvider(
            create: (context) => di.sl<SignInBloc>(),
            child: const SignInScreen(),
          ),
        ),
        GoRoute(
          path: '/sign-up',
          name: 'signUp',
          builder: (context, state) => BlocProvider(
            create: (context) => di.sl<SignUpBloc>(),
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/email-verification',
          name: 'emailVerification',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationScreen(email: email);
          },
        ),
        GoRoute(
          path: '/auth/callback',
          name: 'authCallback',
          builder: (context, state) => const AuthCallbackScreen(),
        ),

        // Main App Shell with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) => MainAppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => BlocProvider(
                create: (context) => di.sl<DashboardBloc>(),
                child: const DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => BlocProvider(
                create: (context) => di.sl<TaskListBloc>(),
                child: const TaskListScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => BlocProvider(
                create: (context) => di.sl<ProfileBloc>(),
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),

        // Task Form Routes (Modal-style)
        GoRoute(
          path: '/task/new',
          name: 'newTask',
          pageBuilder: (context, state) => MaterialPage<void>(
            fullscreenDialog: true,
            child: BlocProvider(
              create: (context) => _createTaskFormBloc(context),
              child: const TaskFormScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/task/edit/:taskId',
          name: 'editTask',
          pageBuilder: (context, state) {
            final taskId = state.pathParameters['taskId']!;
            return MaterialPage<void>(
              fullscreenDialog: true,
              child: BlocProvider(
                create: (context) => _createTaskFormBloc(context),
                child: TaskFormScreen(taskId: taskId),
              ),
            );
          },
        ),

        // Settings Route
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Export/Import Route
        GoRoute(
          path: '/export-import',
          name: 'exportImport',
          builder: (context, state) => const ExportImportScreen(),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(error: state.error),
    );
  }

  // Authentication guard and redirect logic
  static String? _redirect(
      BuildContext context, GoRouterState state, AuthBloc authBloc) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isAuthRoute =
        ['/sign-in', '/sign-up', '/'].contains(state.matchedLocation);

    // If not authenticated and trying to access protected routes
    if (!isAuthenticated && !isAuthRoute) {
      return '/sign-in';
    }

    // If authenticated and on auth routes, redirect to dashboard
    if (isAuthenticated && isAuthRoute && state.matchedLocation != '/') {
      return '/dashboard';
    }

    return null; // No redirect needed
  }

  // Helper function to create TaskFormBloc with current user context
  static TaskFormBloc _createTaskFormBloc(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is AuthAuthenticated) {
      return TaskFormBloc(
        createTaskUseCase: di.sl(),
        updateTaskUseCase: di.sl(),
        getTaskByIdUseCase: di.sl(),
        currentUserId: authState.user.id,
      );
    } else {
      throw Exception('User not authenticated');
    }
  }
}

// Error Screen for navigation errors
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSpacing.xxxl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Something went wrong',
              style: AppTypography.h5,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
