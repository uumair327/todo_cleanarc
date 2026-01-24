import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attachment_entity.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../datasources/supabase_attachment_datasource.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final SupabaseAttachmentDataSource _remoteDataSource;
  final String _userId;

  AttachmentRepositoryImpl(this._remoteDataSource, this._userId);

  @override
  ResultFuture<AttachmentEntity> uploadAttachment({
    required TaskId taskId,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    try {
      final model = await _remoteDataSource.uploadAttachment(
        taskId: taskId.value,
        fileName: fileName,
        fileBytes: fileBytes,
        mimeType: mimeType,
        userId: _userId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<AttachmentEntity>> getAttachmentsByTaskId(
      TaskId taskId) async {
    try {
      final models = await _remoteDataSource.getAttachmentsByTaskId(
        taskId.value,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteAttachment(String attachmentId) async {
    try {
      await _remoteDataSource.deleteAttachment(attachmentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Uint8List> downloadAttachment(String attachmentId) async {
    try {
      final bytes = await _remoteDataSource.downloadAttachment(attachmentId);
      return Right(bytes);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
