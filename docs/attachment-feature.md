# Task Attachments Feature

## Overview

The task attachments feature allows users to upload, view, and delete file attachments associated with their tasks. Files are stored in Supabase Storage and metadata is tracked in the database.

## Architecture

### Domain Layer

**Entities:**
- `AttachmentEntity`: Represents a file attachment with metadata (id, taskId, fileName, fileUrl, mimeType, fileSizeBytes, uploadedAt)

**Repositories:**
- `AttachmentRepository`: Abstract interface for attachment operations

**Use Cases:**
- `GetAttachmentsUseCase`: Retrieve attachments for a task
- `UploadAttachmentUseCase`: Upload a new file attachment
- `DeleteAttachmentUseCase`: Delete an existing attachment

### Data Layer

**Models:**
- `AttachmentModel`: Data model with JSON serialization

**Data Sources:**
- `SupabaseAttachmentDataSource`: Handles Supabase Storage and database operations

**Repository Implementation:**
- `AttachmentRepositoryImpl`: Implements attachment repository with error handling

### Presentation Layer

**BLoC:**
- `AttachmentBloc`: Manages attachment state (loading, loaded, uploading, error)
- `AttachmentEvent`: Events for loading, uploading, and deleting attachments
- `AttachmentState`: States representing attachment operations

**Widgets:**
- `AttachmentListWidget`: Displays list of attachments with upload button
- `AttachmentPreviewWidget`: Shows individual attachment with preview and actions

## Database Schema

### Attachments Table

```sql
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_url TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Storage Bucket

- **Bucket Name:** `task-attachments`
- **Public Access:** Yes (with RLS policies)
- **File Structure:** `{userId}/{taskId}/{timestamp}-{fileName}`

## Security

### Row Level Security (RLS)

Users can only:
- View attachments for their own tasks
- Upload attachments to their own tasks
- Delete their own task attachments

### Storage Policies

Users can only:
- Upload files to their own user folder
- View files in their own user folder
- Delete files from their own user folder

## Usage

### Registering Attachment Services

After user authentication, register attachment services with user context:

```dart
import 'package:todo_cleanarc/core/services/attachment_service_locator.dart';

// After successful login
registerAttachmentServices(userId);
```

### Using Attachment Widget

Add the attachment widget to your task form or detail screen:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_cleanarc/core/services/attachment_service_locator.dart';
import 'package:todo_cleanarc/feature/todo/presentation/widgets/attachment_list_widget.dart';

// In your widget build method
BlocProvider(
  create: (_) => createAttachmentBloc()
    ..add(LoadAttachmentsEvent(taskId)),
  child: AttachmentListWidget(taskId: taskId),
)
```

## Supported File Types

The feature supports all file types with specific MIME type detection for:
- Documents: PDF, DOC, DOCX, XLS, XLSX
- Images: JPG, JPEG, PNG, GIF
- Text: TXT
- Archives: ZIP

## File Size Limits

File size limits are determined by Supabase Storage configuration. Default limits apply unless configured otherwise in your Supabase project.

## Dependencies

- `file_picker: ^8.1.4` - For file selection
- `url_launcher: ^6.3.1` - For opening attachments
- `mime: ^2.0.0` - For MIME type detection

## Migration

Run the migration script to set up the database schema:

```bash
# Execute the migration SQL
psql -h your-supabase-host -U postgres -d postgres -f scripts/migrations/005_attachments_table.sql
```

Or use the Supabase dashboard to execute the SQL from `scripts/migrations/005_attachments_table.sql`.

## Testing

Unit tests should cover:
- Attachment entity creation and equality
- Repository operations (upload, get, delete)
- BLoC state transitions
- Widget rendering and interactions

Integration tests should verify:
- End-to-end file upload flow
- File download and preview
- Attachment deletion with cleanup
- RLS policy enforcement
