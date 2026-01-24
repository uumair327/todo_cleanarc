import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../core/domain/value_objects/task_id.dart';

abstract class AttachmentEvent extends Equatable {
  const AttachmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttachmentsEvent extends AttachmentEvent {
  final TaskId taskId;

  const LoadAttachmentsEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UploadAttachmentEvent extends AttachmentEvent {
  final TaskId taskId;
  final String fileName;
  final Uint8List fileBytes;
  final String mimeType;

  const UploadAttachmentEvent({
    required this.taskId,
    required this.fileName,
    required this.fileBytes,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [taskId, fileName, fileBytes, mimeType];
}

class DeleteAttachmentEvent extends AttachmentEvent {
  final String attachmentId;

  const DeleteAttachmentEvent(this.attachmentId);

  @override
  List<Object?> get props => [attachmentId];
}
