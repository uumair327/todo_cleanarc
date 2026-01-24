import 'dart:convert';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

/// Service for exporting and importing tasks in various formats
class TaskExportImportService {
  /// Export tasks to CSV format
  String exportToCsv(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln(
      'ID,User ID,Title,Description,Due Date,Due Time,Category,Priority,'
      'Progress Percentage,Created At,Updated At,Is Deleted,Attachment IDs'
    );
    
    // CSV Rows
    for (final task in tasks) {
      buffer.writeln(_taskToCsvRow(task));
    }
    
    return buffer.toString();
  }

  /// Export tasks to JSON format
  String exportToJson(List<TaskEntity> tasks) {
    final taskModels = tasks.map((task) => TaskModel.fromEntity(task)).toList();
    final jsonList = taskModels.map((model) => model.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Import tasks from CSV format
  List<TaskEntity> importFromCsv(String csvData) {
    final lines = csvData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty || lines.length < 2) {
      throw FormatException('Invalid CSV format: No data rows found');
    }
    
    // Skip header
    final dataLines = lines.skip(1);
    final tasks = <TaskEntity>[];
    
    for (final line in dataLines) {
      try {
        final task = _csvRowToTask(line);
        tasks.add(task);
      } catch (e) {
        // Skip invalid rows but continue processing
        continue;
      }
    }
    
    return tasks;
  }

  /// Import tasks from JSON format
  List<TaskEntity> importFromJson(String jsonData) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      final tasks = <TaskEntity>[];
      
      for (final json in jsonList) {
        try {
          final model = TaskModel.fromJson(json as Map<String, dynamic>);
          tasks.add(model.toEntity());
        } catch (e) {
          // Skip invalid entries but continue processing
          continue;
        }
      }
      
      return tasks;
    } catch (e) {
      throw FormatException('Invalid JSON format: ${e.toString()}');
    }
  }

  /// Convert a task entity to a CSV row
  String _taskToCsvRow(TaskEntity task) {
    return [
      _escapeCsvField(task.id.value),
      _escapeCsvField(task.userId.value),
      _escapeCsvField(task.title),
      _escapeCsvField(task.description),
      _escapeCsvField(task.dueDate.toIso8601String().split('T')[0]),
      _escapeCsvField(task.dueTime.toString()),
      _escapeCsvField(task.category.name),
      task.priority.index.toString(),
      task.progressPercentage.toString(),
      _escapeCsvField(task.createdAt.toIso8601String()),
      _escapeCsvField(task.updatedAt.toIso8601String()),
      task.isDeleted.toString(),
      _escapeCsvField(task.attachmentIds.join(';')),
    ].join(',');
  }

  /// Convert a CSV row to a task entity
  TaskEntity _csvRowToTask(String csvRow) {
    final fields = _parseCsvRow(csvRow);
    
    if (fields.length < 13) {
      throw FormatException('Invalid CSV row: Expected 13 fields, got ${fields.length}');
    }
    
    final model = TaskModel(
      id: fields[0],
      userId: fields[1],
      title: fields[2],
      description: fields[3],
      dueDate: DateTime.parse(fields[4]),
      dueTime: fields[5],
      category: fields[6],
      priority: int.parse(fields[7]),
      progressPercentage: int.parse(fields[8]),
      createdAt: DateTime.parse(fields[9]),
      updatedAt: DateTime.parse(fields[10]),
      isDeleted: fields[11].toLowerCase() == 'true',
      attachmentIds: fields[12].isEmpty ? [] : fields[12].split(';'),
    );
    
    return model.toEntity();
  }

  /// Escape a CSV field (handle commas, quotes, newlines)
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Parse a CSV row handling quoted fields
  List<String> _parseCsvRow(String row) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < row.length; i++) {
      final char = row[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add last field
    fields.add(buffer.toString());
    
    return fields;
  }
}
