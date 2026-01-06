/// Main entry point for the Flutter Todo App.
/// 
/// This application implements Clean Architecture principles with offline-first
/// capabilities, providing comprehensive task management features with seamless
/// synchronization to Supabase backend.
/// 
/// Key Features:
/// - User authentication with email/password
/// - Full offline functionality with local Hive database
/// - Automatic synchronization when connectivity is restored
/// - Dashboard with task statistics and analytics
/// - Task CRUD operations with rich metadata
/// - Search and filter capabilities
/// - Cross-platform support (iOS, Android, Web, Desktop)
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/injection_container.dart' as di;
import 'core/services/theme_provider_service.dart';
import 'core/theme/app_theme_data.dart' as theme_data;
import 'core/router/app_router.dart';
import 'feature/auth/presentation/auth_presentation.dart';

/// Application entry point.
/// 
/// Initializes the following in order:
/// 1. Flutter framework bindings
/// 2. HydratedBloc storage for state persistence
/// 3. Dependency injection container with all services and repositories
/// 4. Runs the main application widget
void main() async {
  // Ensure Flutter framework is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HydratedBloc storage for offline state persistence
  // This allows BLoCs to automatically persist and restore their state
  // On web, HydratedStorage uses IndexedDB automatically without needing a directory
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb 
        ? HydratedStorage.webStorageDirectory 
        : await getApplicationDocumentsDirectory(),
  );
  
  // Initialize dependency injection container
  // Registers all repositories, use cases, BLoCs, and services
  await di.init();
  
  // Start the application
  runApp(const MyApp());
}

/// Root application widget.
/// 
/// Configures the app with:
/// - BLoC providers for state management
/// - Material Design theme with color system integration
/// - GoRouter for declarative navigation
/// - Global error handling
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Provide global BLoCs that need to be accessible throughout the app
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
      ],
      child: StreamBuilder(
        // Listen to theme changes from the centralized theme provider
        stream: di.sl<ThemeProviderService>().themeStream,
        builder: (context, snapshot) {
          // Get current theme from the theme provider service
          final themeState = di.sl<ThemeProviderService>().currentTheme;
          final colorExtension = theme_data.AppThemeData.createColorExtension(themeState.currentTheme.mode);
          
          return MaterialApp.router(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false,
            theme: theme_data.AppThemeData.lightTheme(colorExtension),
            darkTheme: theme_data.AppThemeData.darkTheme(colorExtension),
            themeMode: themeState.currentTheme.mode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}


