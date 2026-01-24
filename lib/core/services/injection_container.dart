import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import '../constants/app_constants.dart';
import '../network/network_info.dart';
import 'background_sync_service.dart';
import 'connectivity_service.dart';
import 'sync_manager.dart';
import 'app_logger.dart';
import 'realtime_service.dart';
import 'realtime_sync_manager.dart';
import 'notification_service.dart';
import 'notification_service_impl.dart';
import 'task_notification_manager.dart';
import '../../feature/auth/data/models/user_model.dart';
import '../../feature/todo/data/models/task_model.dart';

// Color system imports
import '../domain/repositories/color_repository.dart';
import '../domain/repositories/theme_repository.dart';
import '../domain/entities/app_theme_config.dart';
import '../infrastructure/color/color_storage_impl.dart';
import '../infrastructure/theme/theme_storage_impl.dart';
import 'color_resolver_service.dart';
import 'color_resolver_service_impl.dart';
import 'theme_provider_service.dart';
import 'theme_provider_service_impl.dart';

// Auth imports
import '../../feature/auth/data/datasources/hive_auth_datasource.dart';
import '../../feature/auth/data/datasources/supabase_auth_datasource.dart';
import '../../feature/auth/data/repositories/auth_repository_impl.dart';
import '../../feature/auth/domain/repositories/auth_repository.dart';
import '../../feature/auth/domain/usecases/sign_in_usecase.dart';
import '../../feature/auth/domain/usecases/sign_up_usecase.dart';
import '../../feature/auth/domain/usecases/sign_out_usecase.dart';
import '../../feature/auth/domain/usecases/delete_account_usecase.dart';
import '../../feature/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../feature/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import '../../feature/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import '../../feature/auth/presentation/bloc/profile/profile_bloc.dart';

// Todo imports
import '../../feature/todo/data/datasources/hive_task_datasource.dart';
import '../../feature/todo/data/datasources/supabase_task_datasource.dart';
import '../../feature/todo/data/datasources/supabase_attachment_datasource.dart';
import '../../feature/todo/data/repositories/task_repository_impl.dart';
import '../../feature/todo/domain/repositories/task_repository.dart';
import '../../feature/todo/domain/usecases/create_task_usecase.dart';
import '../../feature/todo/domain/usecases/update_task_usecase.dart';
import '../../feature/todo/domain/usecases/delete_task_usecase.dart';
import '../../feature/todo/domain/usecases/get_tasks_usecase.dart';
import '../../feature/todo/domain/usecases/get_tasks_paginated_usecase.dart';
import '../../feature/todo/domain/usecases/get_task_by_id_usecase.dart';
import '../../feature/todo/domain/usecases/search_tasks_usecase.dart';
import '../../feature/todo/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../feature/todo/domain/usecases/sync_tasks_usecase.dart';
import '../../feature/todo/domain/usecases/export_tasks_usecase.dart';
import '../../feature/todo/domain/usecases/import_tasks_usecase.dart';
import '../../feature/todo/presentation/bloc/task_list/task_list_bloc.dart';

import '../../feature/todo/presentation/bloc/dashboard/dashboard_bloc.dart';

// Notification imports
import '../presentation/bloc/notification_preferences_bloc.dart';

// Category imports
import '../../feature/category/data/models/category_model.dart';
import '../../feature/category/data/datasources/hive_category_datasource.dart';
import '../../feature/category/data/datasources/supabase_category_datasource.dart';
import '../../feature/category/data/repositories/category_repository_impl.dart';
import '../../feature/category/domain/repositories/category_repository.dart';
import '../../feature/category/domain/usecases/create_category_usecase.dart';
import '../../feature/category/domain/usecases/update_category_usecase.dart';
import '../../feature/category/domain/usecases/delete_category_usecase.dart';
import '../../feature/category/domain/usecases/get_categories_usecase.dart';
import '../../feature/category/presentation/bloc/category_bloc.dart';

// Search imports
import '../../feature/todo/data/models/saved_search_model.dart';
import '../../feature/todo/data/models/search_history_model.dart';
import '../../feature/todo/data/datasources/search_datasource.dart';
import '../../feature/todo/data/datasources/hive_search_datasource.dart';
import '../../feature/todo/data/repositories/search_repository_impl.dart';
import '../../feature/todo/domain/repositories/search_repository.dart';
import '../../feature/todo/domain/usecases/advanced_search_tasks_usecase.dart';
import '../../feature/todo/domain/usecases/add_search_history_usecase.dart';
import '../../feature/todo/domain/usecases/get_search_history_usecase.dart';
import '../../feature/todo/domain/usecases/get_saved_searches_usecase.dart';
import '../../feature/todo/domain/usecases/save_search_usecase.dart';
import '../../feature/todo/domain/usecases/delete_saved_search_usecase.dart';
import '../../feature/todo/presentation/bloc/advanced_search/advanced_search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(SavedSearchModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SearchHistoryModelAdapter());
  }
  
  // Open Hive boxes
  await Hive.openBox<TaskModel>(AppConstants.hiveBoxName);
  await Hive.openBox<UserModel>(AppConstants.userBoxName);
  await Hive.openBox<CategoryModel>('categories');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // Initialize color system services
  await _initializeColorServices();
  
  // Core - Register AppLogger first as many services depend on it
  sl.registerLazySingleton<AppLogger>(() => AppLogger());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Color System - Application Layer
  sl.registerLazySingleton<ColorResolverService>(
    () => ColorResolverServiceImpl(
      colorRepository: sl(),
    ),
  );
  
  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => Hive.box<TaskModel>(AppConstants.hiveBoxName));
  sl.registerLazySingleton(() => Hive.box<UserModel>(AppConstants.userBoxName));
  sl.registerLazySingleton(() => Hive.box<CategoryModel>('categories'));
  sl.registerLazySingleton(() => Connectivity());
  
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Notification Services
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(
      notificationsPlugin: sl(),
      prefs: sl(),
      logger: sl(),
    ),
  );
  sl.registerLazySingleton<TaskNotificationManager>(
    () => TaskNotificationManager(
      notificationService: sl(),
      logger: sl(),
    ),
  );
  
  // Initialize notification service
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  
  // Sync Services
  sl.registerLazySingleton<BackgroundSyncService>(
    () => BackgroundSyncService(
      taskRepository: sl(),
      authRepository: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(
      connectivity: sl(),
      networkInfo: sl(),
      syncService: sl(),
    ),
  );
  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      taskRepository: sl(),
      authRepository: sl(),
      networkInfo: sl(),
      connectivity: sl(),
    ),
  );
  
  // Real-time Services
  sl.registerLazySingleton<RealtimeService>(
    () => RealtimeService(
      client: sl<SupabaseClient>(),
      logger: sl(),
    ),
  );
  sl.registerLazySingleton<RealtimeSyncManager>(
    () => RealtimeSyncManager(
      realtimeService: sl(),
      localDataSource: sl(),
      logger: sl(),
    ),
  );
  
  // Auth Data Sources
  sl.registerLazySingleton<HiveAuthDataSource>(
    () => HiveAuthDataSourceImpl(),
  );
  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSourceImpl(sl<SupabaseClient>()),
  );
  
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      hiveDataSource: sl(),
      supabaseDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Auth Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  
  // Todo Data Sources
  sl.registerLazySingleton<HiveTaskDataSource>(
    () => HiveTaskDataSourceImpl(),
  );
  sl.registerLazySingleton<SupabaseTaskDataSource>(
    () => SupabaseTaskDataSourceImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<SupabaseAttachmentDataSource>(
    () => SupabaseAttachmentDataSourceImpl(sl<SupabaseClient>()),
  );
  
  // Todo Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      hiveDataSource: sl(),
      supabaseDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Attachment Repository - requires current user ID
  // This will be registered lazily when user logs in
  
  // Todo Use Cases
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksPaginatedUseCase(sl()));
  sl.registerLazySingleton(() => GetTaskByIdUseCase(sl()));
  sl.registerLazySingleton(() => SearchTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => SyncTasksUseCase(sl()));
  sl.registerLazySingleton(() => ExportTasksUseCase(sl()));
  sl.registerLazySingleton(() => ImportTasksUseCase(sl()));
  
  // Category Data Sources
  sl.registerLazySingleton<HiveCategoryDataSource>(
    () => HiveCategoryDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SupabaseCategoryDataSource>(
    () => SupabaseCategoryDataSourceImpl(sl<SupabaseClient>()),
  );
  
  // Category Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Category Use Cases
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  
  // Search Data Sources
  sl.registerLazySingleton<SearchDataSource>(
    () => HiveSearchDataSource(),
  );
  
  // Search Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(dataSource: sl()),
  );
  
  // Search Use Cases
  sl.registerLazySingleton(() => AdvancedSearchTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddSearchHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetSearchHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedSearchesUseCase(sl()));
  sl.registerLazySingleton(() => SaveSearchUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSavedSearchUseCase(sl()));
  
  // Auth BLoCs
  sl.registerFactory(() => AuthBloc(
    authRepository: sl(),
    signOutUseCase: sl(),
  ));
  sl.registerFactory(() => SignInBloc(signInUseCase: sl()));
  sl.registerFactory(() => SignUpBloc(signUpUseCase: sl()));
  sl.registerFactory(() => ProfileBloc(
    authRepository: sl(),
    signOutUseCase: sl(),
    deleteAccountUseCase: sl(),
  ));
  
  // Todo BLoCs
  sl.registerFactory(() => TaskListBloc(
    getTasksUseCase: sl(),
    getTasksPaginatedUseCase: sl(),
    searchTasksUseCase: sl(),
    deleteTaskUseCase: sl(),
    updateTaskUseCase: sl(),
    syncTasksUseCase: sl(),
  ));
  // TaskFormBloc needs to be created with current user context
  // This will be handled at the widget level where we have access to the current user
  sl.registerFactory(() => DashboardBloc(
    getDashboardStatsUseCase: sl(),
    authRepository: sl(),
  ));
  
  // Category BLoCs
  sl.registerFactory(() => CategoryBloc(
    getCategoriesUseCase: sl(),
    createCategoryUseCase: sl(),
    updateCategoryUseCase: sl(),
    deleteCategoryUseCase: sl(),
    categoryRepository: sl(),
  ));
  
  // Search BLoCs
  sl.registerFactory(() => AdvancedSearchBloc(
    advancedSearchTasksUseCase: sl(),
    addSearchHistoryUseCase: sl(),
    getSearchHistoryUseCase: sl(),
    getSavedSearchesUseCase: sl(),
    saveSearchUseCase: sl(),
    deleteSavedSearchUseCase: sl(),
    searchRepository: sl(),
  ));
  
  // Notification BLoCs
  sl.registerFactory(() => NotificationPreferencesBloc(
    notificationService: sl(),
    logger: sl(),
  ));
}

/// Initializes color system services with proper dependency setup
/// 
/// This function handles the initialization of theme storage and
/// theme provider service with proper error handling.
Future<void> _initializeColorServices() async {
  try {
    // First register the repositories
    sl.registerLazySingleton<ColorRepository>(() => ColorStorageImpl());
    sl.registerLazySingleton<ThemeRepository>(() => ThemeStorageImpl());
    
    // Initialize theme storage
    final themeRepository = sl<ThemeRepository>();
    if (themeRepository is ThemeStorageImpl) {
      await themeRepository.initialize();
    }
    
    // Get default theme for theme provider initialization
    final defaultThemeResult = await themeRepository.getDefaultTheme();
    final defaultTheme = defaultThemeResult.fold(
      (failure) {
        final logger = AppLogger();
        logger.warning('Failed to get default theme, using fallback', failure);
        // Return a fallback theme config with minimal tokens
        return AppThemeConfig(
          name: 'Light',
          mode: ThemeMode.light,
          colorTokens: const {},
        );
      },
      (theme) => theme,
    );
    
    // Register theme provider service with proper initial theme
    sl.registerLazySingleton<ThemeProviderService>(
      () => ThemeProviderServiceImpl(
        themeRepository: sl(),
        initialTheme: defaultTheme,
      ),
    );
    
    // Initialize the theme provider service
    final themeProvider = sl<ThemeProviderService>();
    final initResult = await themeProvider.initialize();
    initResult.fold(
      (failure) {
        final logger = AppLogger();
        logger.warning('Failed to initialize theme provider', failure);
      },
      (_) => null,
    );
  } catch (e) {
    // Log error but don't crash the app - use fallback theme
    final logger = AppLogger();
    logger.warning('Color system initialization failed', e);
    logger.info('Continuing with default theme configuration');
    
    // Ensure repositories are registered even if initialization fails
    if (!sl.isRegistered<ColorRepository>()) {
      sl.registerLazySingleton<ColorRepository>(() => ColorStorageImpl());
    }
    if (!sl.isRegistered<ThemeRepository>()) {
      sl.registerLazySingleton<ThemeRepository>(() => ThemeStorageImpl());
    }
    if (!sl.isRegistered<ThemeProviderService>()) {
      // Register with a minimal fallback theme
      sl.registerLazySingleton<ThemeProviderService>(
        () => ThemeProviderServiceImpl(
          themeRepository: sl(),
          initialTheme: AppThemeConfig(
            name: 'Light',
            mode: ThemeMode.light,
            colorTokens: const {},
          ),
        ),
      );
    }
  }
}

/// Cleanup function for dependency injection container
/// 
/// Should be called when the application is shutting down to
/// properly dispose of services and clear resources.
void dispose() {
  try {
    // Dispose theme provider service
    final themeProvider = sl<ThemeProviderService>();
    themeProvider.dispose();
    
    // Clear color resolver cache
    final colorResolver = sl<ColorResolverService>();
    if (colorResolver is ColorResolverServiceImpl) {
      colorResolver.clearCache();
    }
  } catch (e) {
    final logger = AppLogger();
    logger.warning('Error during service cleanup', e);
  }
  
  // Reset GetIt instance
  sl.reset();
}