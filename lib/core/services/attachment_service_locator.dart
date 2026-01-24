import 'package:get_it/get_it.dart';
import '../../feature/todo/data/datasources/supabase_attachment_datasource.dart';
import '../../feature/todo/data/repositories/attachment_repository_impl.dart';
import '../../feature/todo/domain/repositories/attachment_repository.dart';
import '../../feature/todo/domain/usecases/get_attachments_usecase.dart';
import '../../feature/todo/domain/usecases/upload_attachment_usecase.dart';
import '../../feature/todo/domain/usecases/delete_attachment_usecase.dart';
import '../../feature/todo/presentation/bloc/attachment/attachment_bloc.dart';

final sl = GetIt.instance;

/// Register attachment services with user context
/// Call this after user authentication
void registerAttachmentServices(String userId) {
  // Unregister if already registered
  if (sl.isRegistered<AttachmentRepository>()) {
    sl.unregister<AttachmentRepository>();
  }
  if (sl.isRegistered<GetAttachmentsUseCase>()) {
    sl.unregister<GetAttachmentsUseCase>();
  }
  if (sl.isRegistered<UploadAttachmentUseCase>()) {
    sl.unregister<UploadAttachmentUseCase>();
  }
  if (sl.isRegistered<DeleteAttachmentUseCase>()) {
    sl.unregister<DeleteAttachmentUseCase>();
  }

  // Register attachment repository with user context
  sl.registerLazySingleton<AttachmentRepository>(
    () => AttachmentRepositoryImpl(
      sl<SupabaseAttachmentDataSource>(),
      userId,
    ),
  );

  // Register attachment use cases
  sl.registerLazySingleton(() => GetAttachmentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAttachmentUseCase(sl()));
}

/// Create attachment BLoC
/// Call this when needed in the UI
AttachmentBloc createAttachmentBloc() {
  return AttachmentBloc(
    getAttachments: sl<GetAttachmentsUseCase>(),
    uploadAttachment: sl<UploadAttachmentUseCase>(),
    deleteAttachment: sl<DeleteAttachmentUseCase>(),
  );
}
