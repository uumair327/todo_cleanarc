import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/task_id.dart';

/// Represents a file attachment for a task
class AttachmentEntity extends Equatable {
  final String id;
  final TaskId taskId;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
  final DateTime uploadedAt;

  const AttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.uploadedAt,
  });

  AttachmentEntity copyWith({
    String? id,
    TaskId? taskId,
    String? fileName,
    String? fileUrl,
    String? mimeType,
    int? fileSizeBytes,
    DateTime? uploadedAt,
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object> get props => [
        id,
        taskId,
        fileName,
        fileUrl,
        mimeType,
        fileSizeBytes,
        uploadedAt,
      ];
}
