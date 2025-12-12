import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';
import 'background_sync_service.dart';
import 'connectivity_service.dart';
import 'sync_manager.dart';
import '../../feature/auth/data/models/user_model.dart';
import '../../feature/todo/data/models/task_model.dart';

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
import '../../feature/todo/presentation/bloc/task_list/task_list_bloc.dart';
import '../../feature/todo/presentation/bloc/task_form/task_form_bloc.dart';
import '../../feature/todo/presentation/bloc/dashboard/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  
  // Open Hive boxes
  await Hive.openBox<TaskModel>(AppConstants.hiveBoxName);
  await Hive.openBox<UserModel>(AppConstants.userBoxName);
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => Hive.box<TaskModel>(AppConstants.hiveBoxName));
  sl.registerLazySingleton(() => Hive.box<UserModel>(AppConstants.userBoxName));
  sl.registerLazySingleton(() => Connectivity());
  
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
  
  // Todo Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      hiveDataSource: sl(),
      supabaseDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
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
}