import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attachment_model.dart';

abstract class SupabaseAttachmentDataSource {
  Future<AttachmentModel> uploadAttachment({
    required String taskId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    required String userId,
  });

  Future<List<AttachmentModel>> getAttachmentsByTaskId(String taskId);

  Future<void> deleteAttachment(String attachmentId);

  Future<Uint8List> downloadAttachment(String filePath);
}

class SupabaseAttachmentDataSourceImpl implements SupabaseAttachmentDataSource {
  final SupabaseClient _client;
  static const String _bucketName = 'task-attachments';
  static const String _tableName = 'attachments';

  SupabaseAttachmentDataSourceImpl(this._client);

  @override
  Future<AttachmentModel> uploadAttachment({
    required String taskId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    required String userId,
  }) async {
    try {
      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/$taskId/$timestamp-$fileName';

      // Upload file to Supabase Storage
      await _client.storage.from(_bucketName).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: false,
            ),
          );

      // Get public URL
      final fileUrl = _client.storage.from(_bucketName).getPublicUrl(filePath);

      // Create attachment record in database
      final attachmentData = {
        'task_id': taskId,
        'file_name': fileName,
        'file_path': filePath,
        'file_url': fileUrl,
        'mime_type': mimeType,
        'file_size_bytes': fileBytes.length,
        'uploaded_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(_tableName)
          .insert(attachmentData)
          .select()
          .single();

      return AttachmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsByTaskId(String taskId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('task_id', taskId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((json) => AttachmentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attachments: $e');
    }
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      // Get attachment details to find file path
      final attachment = await _client
          .from(_tableName)
          .select()
          .eq('id', attachmentId)
          .single();

      final filePath = attachment['file_path'] as String;

      // Delete file from storage
      await _client.storage.from(_bucketName).remove([filePath]);

      // Delete attachment record from database
      await _client.from(_tableName).delete().eq('id', attachmentId);
    } catch (e) {
      throw Exception('Failed to delete attachment: $e');
    }
  }

  @override
  Future<Uint8List> downloadAttachment(String filePath) async {
    try {
      final bytes = await _client.storage.from(_bucketName).download(filePath);
      return bytes;
    } catch (e) {
      throw Exception('Failed to download attachment: $e');
    }
  }
}
