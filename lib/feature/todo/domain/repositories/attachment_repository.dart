import 'dart:typed_data';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../entities/attachment_entity.dart';

abstract class AttachmentRepository {
  /// Upload a file attachment for a task
  ResultFuture<AttachmentEntity> uploadAttachment({
    required TaskId taskId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
  });

  /// Get all attachments for a task
  ResultFuture<List<AttachmentEntity>> getAttachmentsByTaskId(TaskId taskId);

  /// Delete an attachment
  ResultVoid deleteAttachment(String attachmentId);

  /// Download attachment file bytes
  ResultFuture<Uint8List> downloadAttachment(String attachmentId);
}
