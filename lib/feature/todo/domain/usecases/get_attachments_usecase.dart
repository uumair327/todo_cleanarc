import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../entities/attachment_entity.dart';
import '../repositories/attachment_repository.dart';

class GetAttachmentsUseCase {
  final AttachmentRepository _repository;

  GetAttachmentsUseCase(this._repository);

  ResultFuture<List<AttachmentEntity>> call(TaskId taskId) async {
    return _repository.getAttachmentsByTaskId(taskId);
  }
}
