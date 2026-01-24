import '../../../../core/utils/typedef.dart';
import '../repositories/task_repository.dart';

/// Use case for importing tasks from various formats
/// 
/// Supports CSV and JSON import formats
class ImportTasksUseCase {
  final TaskRepository _repository;

  ImportTasksUseCase(this._repository);

  /// Import tasks from the provided data string
  /// 
  /// [data] - The data to import (CSV or JSON format)
  /// [format] - Import format ('csv' or 'json')
  /// Returns the number of tasks imported
  ResultFuture<int> call(String data, String format) async {
    return _repository.importTasks(data, format);
  }
}
