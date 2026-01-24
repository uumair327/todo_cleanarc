import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_attachments_usecase.dart';
import '../../../domain/usecases/upload_attachment_usecase.dart';
import '../../../domain/usecases/delete_attachment_usecase.dart';
import 'attachment_event.dart';
import 'attachment_state.dart';

class AttachmentBloc extends Bloc<AttachmentEvent, AttachmentState> {
  final GetAttachmentsUseCase _getAttachments;
  final UploadAttachmentUseCase _uploadAttachment;
  final DeleteAttachmentUseCase _deleteAttachment;

  AttachmentBloc({
    required GetAttachmentsUseCase getAttachments,
    required UploadAttachmentUseCase uploadAttachment,
    required DeleteAttachmentUseCase deleteAttachment,
  })  : _getAttachments = getAttachments,
        _uploadAttachment = uploadAttachment,
        _deleteAttachment = deleteAttachment,
        super(AttachmentInitial()) {
    on<LoadAttachmentsEvent>(_onLoadAttachments);
    on<UploadAttachmentEvent>(_onUploadAttachment);
    on<DeleteAttachmentEvent>(_onDeleteAttachment);
  }

  Future<void> _onLoadAttachments(
    LoadAttachmentsEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentLoading());

    final result = await _getAttachments(event.taskId);

    result.fold(
      (failure) => emit(AttachmentError(failure.message)),
      (attachments) => emit(AttachmentLoaded(attachments)),
    );
  }

  Future<void> _onUploadAttachment(
    UploadAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(const AttachmentUploading(0.5));

    final result = await _uploadAttachment(
      taskId: event.taskId,
      fileName: event.fileName,
      fileBytes: event.fileBytes,
      mimeType: event.mimeType,
    );

    result.fold(
      (failure) => emit(AttachmentError(failure.message)),
      (attachment) {
        // Reload attachments after successful upload
        add(LoadAttachmentsEvent(event.taskId));
      },
    );
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttachmentLoaded) return;

    final result = await _deleteAttachment(event.attachmentId);

    result.fold(
      (failure) => emit(AttachmentError(failure.message)),
      (_) {
        // Remove deleted attachment from current list
        final updatedAttachments = currentState.attachments
            .where((a) => a.id != event.attachmentId)
            .toList();
        emit(AttachmentLoaded(updatedAttachments));
      },
    );
  }
}
