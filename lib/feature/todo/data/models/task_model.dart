import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/task_id.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/domain/enums/task_enums.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  DateTime dueDate;
  
  @HiveField(5)
  String dueTime; // Stored as "HH:mm" format
  
  @HiveField(6)
  String category;
  
  @HiveField(7)
  int priority;
  
  @HiveField(8)
  int progressPercentage;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
  
  @HiveField(11)
  bool isDeleted;
  
  @HiveField(12)
  bool needsSync;

  @HiveField(13)
  List<String> attachmentIds;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.category,
    required this.priority,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.needsSync = false,
    this.attachmentIds = const [],
  });

  factory TaskModel.fromJson(DataMap json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['due_date'] as String),
      dueTime: json['due_time'] as String? ?? '09:00',
      category: json['category'] as String,
      priority: json['priority'] as int,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      attachmentIds: json['attachment_ids'] != null
          ? List<String>.from(json['attachment_ids'] as List)
          : [],
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'due_time': dueTime,
      'category': category,
      'priority': priority,
      'progress_percentage': progressPercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'attachment_ids': attachmentIds,
    };
  }

  TaskEntity toEntity() {
    final timeParts = dueTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return TaskEntity(
      id: TaskId.fromString(id),
      userId: UserId.fromString(userId),
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: DomainTime(hour: hour, minute: minute),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => TaskCategory.ongoing,
      ),
      priority: TaskPriority.values[priority],
      progressPercentage: progressPercentage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      attachmentIds: attachmentIds,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id.value,
      userId: entity.userId.value,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime.toString(),
      category: entity.category.name,
      priority: entity.priority.index,
      progressPercentage: entity.progressPercentage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      attachmentIds: entity.attachmentIds,
    );
  }
}