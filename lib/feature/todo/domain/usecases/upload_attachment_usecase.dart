import 'dart:typed_data';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../entities/attachment_entity.dart';
import '../repositories/attachment_repository.dart';

class UploadAttachmentUseCase {
  final AttachmentRepository _repository;

  UploadAttachmentUseCase(this._repository);

  ResultFuture<AttachmentEntity> call({
    required TaskId taskId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    return _repository.uploadAttachment(
      taskId: taskId,
      fileName: fileName,
      fileBytes: fileBytes,
      mimeType: mimeType,
    );
  }
}
