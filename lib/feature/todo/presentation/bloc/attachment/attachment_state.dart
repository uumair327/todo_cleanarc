import 'package:equatable/equatable.dart';
import '../../../domain/entities/attachment_entity.dart';

abstract class AttachmentState extends Equatable {
  const AttachmentState();

  @override
  List<Object?> get props => [];
}

class AttachmentInitial extends AttachmentState {}

class AttachmentLoading extends AttachmentState {}

class AttachmentLoaded extends AttachmentState {
  final List<AttachmentEntity> attachments;

  const AttachmentLoaded(this.attachments);

  @override
  List<Object?> get props => [attachments];
}

class AttachmentUploading extends AttachmentState {
  final double progress;

  const AttachmentUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class AttachmentError extends AttachmentState {
  final String message;

  const AttachmentError(this.message);

  @override
  List<Object?> get props => [message];
}
