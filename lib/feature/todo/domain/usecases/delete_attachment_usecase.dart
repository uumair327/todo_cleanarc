import '../../../../core/utils/typedef.dart';
import '../repositories/attachment_repository.dart';

class DeleteAttachmentUseCase {
  final AttachmentRepository _repository;

  DeleteAttachmentUseCase(this._repository);

  ResultVoid call(String attachmentId) async {
    return _repository.deleteAttachment(attachmentId);
  }
}
