import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/presentation/auth_presentation.dart';
import '../../feature/todo/presentation/todo_presentation.dart';

import '../../feature/auth/presentation/screens/email_verification_screen.dart';
import '../../feature/auth/presentation/screens/auth_callback_screen.dart';
import '../services/injection_container.dart' as di;
import '../widgets/widgets.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
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
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );

  static GoRouter get router => _router;

  // Authentication guard and redirect logic
  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isAuthRoute = ['/sign-in', '/sign-up', '/'].contains(state.matchedLocation);

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
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
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