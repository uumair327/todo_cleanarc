import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/feature/todo/data/models/task_model.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

void main() {
  final testDate = DateTime(2026, 1, 25);
  final testCreatedAt = DateTime(2026, 1, 20);
  final testUpdatedAt = DateTime(2026, 1, 21);

  final testModel = TaskModel(
    id: '123',
    userId: 'user123',
    title: 'Test Task',
    description: 'Test Description',
    dueDate: testDate,
    dueTime: '14:30',
    category: 'ongoing',
    priority: 3,
    progressPercentage: 50,
    createdAt: testCreatedAt,
    updatedAt: testUpdatedAt,
    isDeleted: false,
    needsSync: false,
  );

  final testJson = {
    'id': '123',
    'user_id': 'user123',
    'title': 'Test Task',
    'description': 'Test Description',
    'due_date': '2026-01-25',
    'due_time': '14:30',
    'category': 'ongoing',
    'priority': 3,
    'progress_percentage': 50,
    'created_at': testCreatedAt.toIso8601String(),
    'updated_at': testUpdatedAt.toIso8601String(),
    'is_deleted': false,
  };

  group('TaskModel', () {
    group('fromJson', () {
      test('should create TaskModel from valid JSON', () {
        final result = TaskModel.fromJson(testJson);

        expect(result.id, '123');
        expect(result.userId, 'user123');
        expect(result.title, 'Test Task');
        expect(result.description, 'Test Description');
        expect(result.category, 'ongoing');
        expect(result.priority, 3);
        expect(result.progressPercentage, 50);
      });

      test('should handle missing optional fields with defaults', () {
        final jsonWithoutOptionals = {
          'id': '123',
          'user_id': 'user123',
          'title': 'Test Task',
          'due_date': '2026-01-25',
          'category': 'ongoing',
          'priority': 3,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': testUpdatedAt.toIso8601String(),
        };

        final result = TaskModel.fromJson(jsonWithoutOptionals);

        expect(result.description, '');
        expect(result.dueTime, '09:00');
        expect(result.progressPercentage, 0);
        expect(result.isDeleted, false);
      });
    });

    group('toJson', () {
      test('should convert TaskModel to JSON', () {
        final result = testModel.toJson();

        expect(result['id'], '123');
        expect(result['user_id'], 'user123');
        expect(result['title'], 'Test Task');
        expect(result['description'], 'Test Description');
        expect(result['due_date'], '2026-01-25');
        expect(result['due_time'], '14:30');
        expect(result['category'], 'ongoing');
        expect(result['priority'], 3);
        expect(result['progress_percentage'], 50);
        expect(result['is_deleted'], false);
      });
    });

    group('toEntity', () {
      test('should convert TaskModel to TaskEntity', () {
        final result = testModel.toEntity();

        expect(result.id.value, '123');
        expect(result.userId.value, 'user123');
        expect(result.title, 'Test Task');
        expect(result.description, 'Test Description');
        expect(result.category, TaskCategory.ongoing);
        expect(result.priority, TaskPriority.values[3]);
        expect(result.progressPercentage, 50);
        expect(result.dueTime.hour, 14);
        expect(result.dueTime.minute, 30);
      });
    });

    group('fromEntity', () {
      test('should convert TaskEntity to TaskModel', () {
        final entity = TaskEntity(
          id: TaskId.fromString('123'),
          userId: UserId.fromString('user123'),
          title: 'Test Task',
          description: 'Test Description',
          dueDate: testDate,
          dueTime: const DomainTime(hour: 14, minute: 30),
          category: TaskCategory.ongoing,
          priority: TaskPriority.values[3],
          progressPercentage: 50,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          isDeleted: false,
        );

        final result = TaskModel.fromEntity(entity);

        expect(result.id, '123');
        expect(result.userId, 'user123');
        expect(result.title, 'Test Task');
        expect(result.description, 'Test Description');
        expect(result.category, 'ongoing');
        expect(result.priority, 3);
        expect(result.progressPercentage, 50);
        expect(result.dueTime, '14:30');
      });
    });

    group('round trip conversion', () {
      test('should maintain data integrity through entity-model-entity conversion', () {
        final originalEntity = TaskEntity(
          id: TaskId.fromString('123'),
          userId: UserId.fromString('user123'),
          title: 'Test Task',
          description: 'Test Description',
          dueDate: testDate,
          dueTime: const DomainTime(hour: 14, minute: 30),
          category: TaskCategory.ongoing,
          priority: TaskPriority.values[3],
          progressPercentage: 50,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          isDeleted: false,
        );

        final model = TaskModel.fromEntity(originalEntity);
        final resultEntity = model.toEntity();

        expect(resultEntity.id.value, originalEntity.id.value);
        expect(resultEntity.userId.value, originalEntity.userId.value);
        expect(resultEntity.title, originalEntity.title);
        expect(resultEntity.description, originalEntity.description);
        expect(resultEntity.category, originalEntity.category);
        expect(resultEntity.priority, originalEntity.priority);
        expect(resultEntity.progressPercentage, originalEntity.progressPercentage);
      });
    });
  });
}
