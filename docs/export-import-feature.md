# Data Export/Import Feature

## Overview

The Data Export/Import feature allows users to backup and restore their tasks in CSV or JSON formats. This feature is useful for:
- Creating backups of task data
- Transferring tasks between devices
- Migrating data to other applications
- Archiving completed projects

## Architecture

### Domain Layer

#### Use Cases
- **ExportTasksUseCase**: Exports all tasks to a specified format (CSV or JSON)
- **ImportTasksUseCase**: Imports tasks from a data string in a specified format

#### Repository Interface
The `TaskRepository` interface has been extended with:
```dart
ResultFuture<String> exportTasks(String format);
ResultFuture<int> importTasks(String data, String format);
```

### Data Layer

#### TaskExportImportService
A service class that handles the conversion between task entities and export formats:

**CSV Export**:
- Generates CSV with headers
- Handles special characters (commas, quotes, newlines)
- Escapes fields properly

**JSON Export**:
- Converts tasks to JSON array
- Uses existing TaskModel serialization

**CSV Import**:
- Parses CSV rows
- Handles quoted fields
- Skips invalid rows

**JSON Import**:
- Parses JSON array
- Validates each entry
- Skips invalid entries

#### Repository Implementation
The `TaskRepositoryImpl` has been updated to:
- Use `TaskExportImportService` for format conversion
- Export all tasks from local storage
- Import tasks to local storage
- Trigger background sync after import

### Presentation Layer

#### BLoC
**ExportImportBloc** manages the export/import state with events:
- `ExportTasksToCsvEvent`: Triggers CSV export
- `ExportTasksToJsonEvent`: Triggers JSON export
- `ImportTasksFromCsvEvent`: Triggers CSV import
- `ImportTasksFromJsonEvent`: Triggers JSON import
- `ResetExportImportStateEvent`: Resets state

States:
- `ExportImportInitial`: Initial state
- `ExportImportLoading`: Operation in progress
- `ExportSuccess`: Export completed with data
- `ImportSuccess`: Import completed with count
- `ExportImportError`: Operation failed

#### UI Screen
**ExportImportScreen** provides:
- Export section with CSV and JSON buttons
- Import section with file picker integration
- Success/error feedback via SnackBars
- Automatic file saving for exports

## Usage

### Accessing the Feature
1. Navigate to Settings screen
2. Tap on "Export / Import Data" under "Data & Privacy"
3. Choose export or import operation

### Exporting Tasks

**CSV Export**:
1. Tap "Export as CSV"
2. File is saved to app documents directory
3. Success message shows file location

**JSON Export**:
1. Tap "Export as JSON"
2. File is saved to app documents directory
3. Success message shows file location

### Importing Tasks

**CSV Import**:
1. Tap "Import CSV"
2. Select CSV file from device
3. Tasks are imported and synced
4. Success message shows count of imported tasks

**JSON Import**:
1. Tap "Import JSON"
2. Select JSON file from device
3. Tasks are imported and synced
4. Success message shows count of imported tasks

## File Formats

### CSV Format
```csv
ID,User ID,Title,Description,Due Date,Due Time,Category,Priority,Progress Percentage,Created At,Updated At,Is Deleted,Attachment IDs
task-1,user-1,Sample Task,Task description,2024-01-15,14:30,ongoing,1,50,2024-01-01T00:00:00.000,2024-01-10T00:00:00.000,false,att-1;att-2
```

**Field Escaping**:
- Fields with commas, quotes, or newlines are wrapped in double quotes
- Double quotes within fields are escaped as `""`

### JSON Format
```json
[
  {
    "id": "task-1",
    "user_id": "user-1",
    "title": "Sample Task",
    "description": "Task description",
    "due_date": "2024-01-15",
    "due_time": "14:30",
    "category": "ongoing",
    "priority": 1,
    "progress_percentage": 50,
    "created_at": "2024-01-01T00:00:00.000",
    "updated_at": "2024-01-10T00:00:00.000",
    "is_deleted": false,
    "attachment_ids": ["att-1", "att-2"]
  }
]
```

## Error Handling

### Export Errors
- **CacheFailure**: Failed to read tasks from local storage
- **ValidationFailure**: Unsupported export format

### Import Errors
- **FormatException**: Invalid CSV or JSON format
- **ValidationFailure**: Unsupported import format
- **CacheFailure**: Failed to save tasks to local storage

### Resilience
- Invalid rows/entries are skipped during import
- Partial imports are supported
- User is notified of successful import count

## Testing

### Unit Tests
- **task_export_import_service_test.dart**: Tests CSV/JSON conversion
  - Export to CSV/JSON
  - Import from CSV/JSON
  - Special character handling
  - Error handling

- **export_import_usecases_test.dart**: Tests use case logic
  - Export use case
  - Import use case
  - Failure handling

### Test Coverage
- CSV export/import with special characters
- JSON export/import with multiple tasks
- Empty data handling
- Invalid format handling
- Error recovery

## Dependencies

### Required Packages
- `file_picker`: ^8.1.4 - For file selection
- `path_provider`: ^2.1.4 - For file system access

### Internal Dependencies
- TaskRepository
- TaskExportImportService
- ExportTasksUseCase
- ImportTasksUseCase

## Future Enhancements

1. **Selective Export**: Export filtered tasks only
2. **Cloud Backup**: Direct export to cloud storage
3. **Scheduled Backups**: Automatic periodic backups
4. **Import Preview**: Preview tasks before importing
5. **Merge Options**: Choose to merge or replace on import
6. **Excel Support**: Export to .xlsx format
7. **Compression**: Compress large exports
8. **Encryption**: Encrypt exported data

## Implementation Notes

### Offline-First
- Export reads from local storage
- Import writes to local storage first
- Background sync triggered after import

### Performance
- Large datasets handled efficiently
- Streaming not required for typical use cases
- Memory usage optimized for mobile devices

### Security
- No sensitive data in exports (passwords excluded)
- Files saved to app-specific directory
- User controls file sharing

## Related Files

### Domain Layer
- `lib/feature/todo/domain/usecases/export_tasks_usecase.dart`
- `lib/feature/todo/domain/usecases/import_tasks_usecase.dart`
- `lib/feature/todo/domain/repositories/task_repository.dart`

### Data Layer
- `lib/feature/todo/data/services/task_export_import_service.dart`
- `lib/feature/todo/data/repositories/task_repository_impl.dart`

### Presentation Layer
- `lib/feature/todo/presentation/bloc/export_import/export_import_bloc.dart`
- `lib/feature/todo/presentation/bloc/export_import/export_import_event.dart`
- `lib/feature/todo/presentation/bloc/export_import/export_import_state.dart`
- `lib/feature/todo/presentation/screens/export_import_screen.dart`

### Tests
- `test/feature/todo/data/services/task_export_import_service_test.dart`
- `test/feature/todo/domain/usecases/export_import_usecases_test.dart`
