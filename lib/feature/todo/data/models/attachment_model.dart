import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../domain/entities/attachment_entity.dart';

class AttachmentModel {
  final String id;
  final String taskId;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
  final DateTime uploadedAt;

  AttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.uploadedAt,
  });

  factory AttachmentModel.fromJson(DataMap json) {
    return AttachmentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      mimeType: json['mime_type'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'file_name': fileName,
      'file_url': fileUrl,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  AttachmentEntity toEntity() {
    return AttachmentEntity(
      id: id,
      taskId: TaskId.fromString(taskId),
      fileName: fileName,
      fileUrl: fileUrl,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      uploadedAt: uploadedAt,
    );
  }

  factory AttachmentModel.fromEntity(AttachmentEntity entity) {
    return AttachmentModel(
      id: entity.id,
      taskId: entity.taskId.value,
      fileName: entity.fileName,
      fileUrl: entity.fileUrl,
      mimeType: entity.mimeType,
      fileSizeBytes: entity.fileSizeBytes,
      uploadedAt: entity.uploadedAt,
    );
  }
}
