import 'package:hive/hive.dart';
import '../../domain/entities/saved_search.dart';
import '../../domain/entities/search_filter.dart';
import '../../../../core/domain/enums/task_enums.dart';

part 'saved_search_model.g.dart';

@HiveType(typeId: 3)
class SavedSearchModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? searchQuery;

  @HiveField(3)
  final DateTime? startDate;

  @HiveField(4)
  final DateTime? endDate;

  @HiveField(5)
  final List<String>? categories;

  @HiveField(6)
  final List<String>? priorities;

  @HiveField(7)
  final int? minProgress;

  @HiveField(8)
  final int? maxProgress;

  @HiveField(9)
  final bool? isCompleted;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  SavedSearchModel({
    required this.id,
    required this.name,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.categories,
    this.priorities,
    this.minProgress,
    this.maxProgress,
    this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedSearchModel.fromEntity(SavedSearch entity) {
    return SavedSearchModel(
      id: entity.id,
      name: entity.name,
      searchQuery: entity.filter.searchQuery,
      startDate: entity.filter.startDate,
      endDate: entity.filter.endDate,
      categories: entity.filter.categories
          ?.map((c) => c.toString().split('.').last)
          .toList(),
      priorities: entity.filter.priorities
          ?.map((p) => p.toString().split('.').last)
          .toList(),
      minProgress: entity.filter.minProgress,
      maxProgress: entity.filter.maxProgress,
      isCompleted: entity.filter.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SavedSearch toEntity() {
    return SavedSearch(
      id: id,
      name: name,
      filter: SearchFilter(
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
        categories: categories
            ?.map((c) => TaskCategory.values.firstWhere(
                  (e) => e.toString().split('.').last == c,
                  orElse: () => TaskCategory.ongoing,
                ))
            .toList(),
        priorities: priorities
            ?.map((p) => TaskPriority.values.firstWhere(
                  (e) => e.toString().split('.').last == p,
                  orElse: () => TaskPriority.medium,
                ))
            .toList(),
        minProgress: minProgress,
        maxProgress: maxProgress,
        isCompleted: isCompleted,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'searchQuery': searchQuery,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'categories': categories,
      'priorities': priorities,
      'minProgress': minProgress,
      'maxProgress': maxProgress,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedSearchModel.fromJson(Map<String, dynamic> json) {
    return SavedSearchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      searchQuery: json['searchQuery'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>(),
      priorities: (json['priorities'] as List<dynamic>?)?.cast<String>(),
      minProgress: json['minProgress'] as int?,
      maxProgress: json['maxProgress'] as int?,
      isCompleted: json['isCompleted'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
