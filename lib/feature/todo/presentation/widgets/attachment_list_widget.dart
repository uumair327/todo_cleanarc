import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../bloc/attachment/attachment_bloc.dart';
import '../bloc/attachment/attachment_event.dart';
import '../bloc/attachment/attachment_state.dart';
import 'attachment_preview_widget.dart';

class AttachmentListWidget extends StatelessWidget {
  final TaskId taskId;

  const AttachmentListWidget({
    super.key,
    required this.taskId,
  });

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        if (!context.mounted) return;
        context.read<AttachmentBloc>().add(
              UploadAttachmentEvent(
                taskId: taskId,
                fileName: file.name,
                fileBytes: file.bytes!,
                mimeType: file.extension != null
                    ? _getMimeType(file.extension!)
                    : 'application/octet-stream',
              ),
            );
      }
    }
  }

  String _getMimeType(String extension) {
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'txt': 'text/plain',
      'zip': 'application/zip',
    };
    return mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttachmentBloc, AttachmentState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () => _pickAndUploadFile(context),
                  tooltip: 'Add attachment',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state is AttachmentLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is AttachmentUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: state.progress),
                  const SizedBox(height: 8),
                  const Text('Uploading...'),
                ],
              )
            else if (state is AttachmentError)
              Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (state is AttachmentLoaded)
              state.attachments.isEmpty
                  ? const Text('No attachments')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = state.attachments[index];
                        return AttachmentPreviewWidget(
                          attachment: attachment,
                          onDelete: () {
                            context.read<AttachmentBloc>().add(
                                  DeleteAttachmentEvent(attachment.id),
                                );
                          },
                        );
                      },
                    )
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
