import 'package:flutter/material.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/attachment_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentPreviewWidget extends StatelessWidget {
  final AttachmentEntity attachment;
  final VoidCallback onDelete;

  const AttachmentPreviewWidget({
    super.key,
    required this.attachment,
    required this.onDelete,
  });

  IconData _getFileIcon() {
    if (attachment.mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (attachment.mimeType.startsWith('video/')) {
      return Icons.video_file;
    } else if (attachment.mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (attachment.mimeType.contains('word') ||
        attachment.mimeType.contains('document')) {
      return Icons.description;
    } else if (attachment.mimeType.contains('sheet') ||
        attachment.mimeType.contains('excel')) {
      return Icons.table_chart;
    } else if (attachment.mimeType.startsWith('text/')) {
      return Icons.text_snippet;
    } else if (attachment.mimeType.contains('zip') ||
        attachment.mimeType.contains('compressed')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _openAttachment() async {
    final uri = Uri.parse(attachment.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(_getFileIcon(), size: 32),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatFileSize(attachment.fileSizeBytes)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _openAttachment,
              tooltip: 'Open',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Attachment'),
                    content: const Text(
                      'Are you sure you want to delete this attachment?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
