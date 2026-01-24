import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/attachment_entity.dart';

void main() {
  group('AttachmentEntity', () {
    final taskId = TaskId.fromString('task-123');
    final uploadedAt = DateTime(2024, 1, 1);

    test('should create attachment entity with all properties', () {
      final attachment = AttachmentEntity(
        id: 'attachment-1',
        taskId: taskId,
        fileName: 'document.pdf',
        fileUrl: 'https://example.com/file.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        uploadedAt: uploadedAt,
      );

      expect(attachment.id, 'attachment-1');
      expect(attachment.taskId, taskId);
      expect(attachment.fileName, 'document.pdf');
      expect(attachment.fileUrl, 'https://example.com/file.pdf');
      expect(attachment.mimeType, 'application/pdf');
      expect(attachment.fileSizeBytes, 1024);
      expect(attachment.uploadedAt, uploadedAt);
    });

    test('should support equality comparison', () {
      final attachment1 = AttachmentEntity(
        id: 'attachment-1',
        taskId: taskId,
        fileName: 'document.pdf',
        fileUrl: 'https://example.com/file.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        uploadedAt: uploadedAt,
      );

      final attachment2 = AttachmentEntity(
        id: 'attachment-1',
        taskId: taskId,
        fileName: 'document.pdf',
        fileUrl: 'https://example.com/file.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        uploadedAt: uploadedAt,
      );

      expect(attachment1, equals(attachment2));
    });

    test('should support copyWith', () {
      final attachment = AttachmentEntity(
        id: 'attachment-1',
        taskId: taskId,
        fileName: 'document.pdf',
        fileUrl: 'https://example.com/file.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024,
        uploadedAt: uploadedAt,
      );

      final updated = attachment.copyWith(
        fileName: 'updated.pdf',
        fileSizeBytes: 2048,
      );

      expect(updated.id, attachment.id);
      expect(updated.fileName, 'updated.pdf');
      expect(updated.fileSizeBytes, 2048);
      expect(updated.mimeType, attachment.mimeType);
    });
  });
}
