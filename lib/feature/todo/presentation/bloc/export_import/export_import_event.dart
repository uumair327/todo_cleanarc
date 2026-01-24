import 'package:equatable/equatable.dart';

abstract class ExportImportEvent extends Equatable {
  const ExportImportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to export tasks to CSV format
class ExportTasksToCsvEvent extends ExportImportEvent {
  const ExportTasksToCsvEvent();
}

/// Event to export tasks to JSON format
class ExportTasksToJsonEvent extends ExportImportEvent {
  const ExportTasksToJsonEvent();
}

/// Event to import tasks from CSV format
class ImportTasksFromCsvEvent extends ExportImportEvent {
  final String data;

  const ImportTasksFromCsvEvent(this.data);

  @override
  List<Object?> get props => [data];
}

/// Event to import tasks from JSON format
class ImportTasksFromJsonEvent extends ExportImportEvent {
  final String data;

  const ImportTasksFromJsonEvent(this.data);

  @override
  List<Object?> get props => [data];
}

/// Event to reset the export/import state
class ResetExportImportStateEvent extends ExportImportEvent {
  const ResetExportImportStateEvent();
}
