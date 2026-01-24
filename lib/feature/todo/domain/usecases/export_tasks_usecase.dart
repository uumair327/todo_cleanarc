import '../../../../core/utils/typedef.dart';
import '../repositories/task_repository.dart';

/// Use case for exporting tasks to various formats
/// 
/// Supports CSV and JSON export formats
class ExportTasksUseCase {
  final TaskRepository _repository;

  ExportTasksUseCase(this._repository);

  /// Export all tasks to the specified format
  /// 
  /// [format] - Export format ('csv' or 'json')
  /// Returns the exported data as a string
  ResultFuture<String> call(String format) async {
    return _repository.exportTasks(format);
  }
}
