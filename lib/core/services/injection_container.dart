import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';
import '../../feature/auth/data/models/user_model.dart';
import '../../feature/todo/data/models/task_model.dart';

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
  
  // TODO: Register repositories, use cases, and blocs in subsequent tasks
}