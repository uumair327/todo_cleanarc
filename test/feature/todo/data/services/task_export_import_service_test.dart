import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/data/services/task_export_import_service.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

void main() {
  late TaskExportImportService service;

  setUp(() {
    service = TaskExportImportService();
  });

  group('TaskExportImportService', () {
    final testTask = TaskEntity(
      id: TaskId.fromString('test-id-1'),
      userId: UserId.fromString('user-id-1'),
      title: 'Test Task',
      description: 'Test Description',
      dueDate: DateTime(2024, 1, 15),
      dueTime: const DomainTime(hour: 14, minute: 30),
      category: TaskCategory.ongoing,
      priority: TaskPriority.high,
      progressPercentage: 50,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 10),
      isDeleted: false,
      attachmentIds: ['att-1', 'att-2'],
    );

    group('CSV Export/Import', () {
      test('should export tasks to CSV format', () {
        final tasks = [testTask];
        final csv = service.exportToCsv(tasks);

        expect(csv, isNotEmpty);
        expect(csv, contains('ID,User ID,Title'));
        expect(csv, contains('test-id-1'));
        expect(csv, contains('Test Task'));
      });

      test('should import tasks from CSV format', () {
        final tasks = [testTask];
        final csv = service.exportToCsv(tasks);
        final imported = service.importFromCsv(csv);

        expect(imported, hasLength(1));
        expect(imported.first.id.value, testTask.id.value);
        expect(imported.first.title, testTask.title);
        expect(imported.first.description, testTask.description);
      });

      test('should handle empty CSV export', () {
        final csv = service.exportToCsv([]);
        expect(csv, isEmpty);
      });

      test('should handle CSV with special characters', () {
        final taskWithComma = testTask.copyWith(
          title: 'Task, with comma',
          description: 'Description "with quotes"',
        );
        final csv = service.exportToCsv([taskWithComma]);
        final imported = service.importFromCsv(csv);

        expect(imported, hasLength(1));
        expect(imported.first.title, 'Task, with comma');
        expect(imported.first.description, 'Description "with quotes"');
      });
    });

    group('JSON Export/Import', () {
      test('should export tasks to JSON format', () {
        final tasks = [testTask];
        final json = service.exportToJson(tasks);

        expect(json, isNotEmpty);
        expect(json, contains('test-id-1'));
        expect(json, contains('Test Task'));
      });

      test('should import tasks from JSON format', () {
        final tasks = [testTask];
        final json = service.exportToJson(tasks);
        final imported = service.importFromJson(json);

        expect(imported, hasLength(1));
        expect(imported.first.id.value, testTask.id.value);
        expect(imported.first.title, testTask.title);
        expect(imported.first.description, testTask.description);
      });

      test('should handle empty JSON export', () {
        final json = service.exportToJson([]);
        expect(json, equals('[]'));
      });

      test('should handle multiple tasks', () {
        final task2 = testTask.copyWith(
          id: TaskId.fromString('test-id-2'),
          title: 'Second Task',
        );
        final tasks = [testTask, task2];
        final json = service.exportToJson(tasks);
        final imported = service.importFromJson(json);

        expect(imported, hasLength(2));
        expect(imported[0].title, 'Test Task');
        expect(imported[1].title, 'Second Task');
      });
    });

    group('Error Handling', () {
      test('should throw FormatException for invalid CSV', () {
        expect(
          () => service.importFromCsv('invalid,csv'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException for invalid JSON', () {
        expect(
          () => service.importFromJson('invalid json'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should skip invalid CSV rows and continue', () {
        final validCsv = service.exportToCsv([testTask]);
        final csvWithInvalidRow = '$validCsv\ninvalid,row,data';
        
        final imported = service.importFromCsv(csvWithInvalidRow);
        expect(imported, hasLength(1));
      });
    });
  });
}
