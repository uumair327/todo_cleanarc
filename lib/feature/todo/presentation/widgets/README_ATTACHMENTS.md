# Task Attachments Widgets

This directory contains widgets for managing task file attachments.

## Widgets

### AttachmentListWidget

Displays a list of attachments for a task with upload functionality.

**Features:**
- File picker integration for selecting files
- Upload progress indicator
- List of existing attachments
- Error handling and display

**Usage:**
```dart
BlocProvider(
  create: (_) => createAttachmentBloc()
    ..add(LoadAttachmentsEvent(taskId)),
  child: AttachmentListWidget(taskId: taskId),
)
```

### AttachmentPreviewWidget

Shows an individual attachment with preview and actions.

**Features:**
- File type icon based on MIME type
- File name and size display
- Open attachment in external app
- Delete attachment with confirmation

**Supported File Types:**
- Images (JPG, PNG, GIF)
- Documents (PDF, DOC, DOCX)
- Spreadsheets (XLS, XLSX)
- Text files (TXT)
- Archives (ZIP)
- Videos
- Generic files

## Integration

To integrate attachments into a screen:

1. Register attachment services after user login:
```dart
import 'package:todo_cleanarc/core/services/attachment_service_locator.dart';

registerAttachmentServices(userId);
```

2. Add the attachment widget to your UI:
```dart
import 'package:todo_cleanarc/feature/todo/presentation/widgets/attachment_list_widget.dart';

// In your build method
AttachmentListWidget(taskId: taskId)
```

## Dependencies

- `file_picker` - For file selection
- `url_launcher` - For opening attachments
- `flutter_bloc` - For state management

## State Management

The attachment widgets use `AttachmentBloc` for state management:

**States:**
- `AttachmentInitial` - Initial state
- `AttachmentLoading` - Loading attachments
- `AttachmentLoaded` - Attachments loaded successfully
- `AttachmentUploading` - File upload in progress
- `AttachmentError` - Error occurred

**Events:**
- `LoadAttachmentsEvent` - Load attachments for a task
- `UploadAttachmentEvent` - Upload a new file
- `DeleteAttachmentEvent` - Delete an attachment

## Security

All attachment operations are secured with Row Level Security (RLS) policies:
- Users can only view/upload/delete attachments for their own tasks
- File storage is isolated by user ID
- Public URLs are generated but access is controlled by RLS
