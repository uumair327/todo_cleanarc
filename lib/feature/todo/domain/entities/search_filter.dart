import 'package:equatable/equatable.dart';
import '../../../../core/domain/enums/task_enums.dart';

/// Entity representing advanced search filters for tasks
class SearchFilter extends Equatable {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TaskCategory>? categories;
  final List<TaskPriority>? priorities;
  final int? minProgress;
  final int? maxProgress;
  final bool? isCompleted;

  const SearchFilter({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.categories,
    this.priorities,
    this.minProgress,
    this.maxProgress,
    this.isCompleted,
  });

  bool get isEmpty =>
      searchQuery == null &&
      startDate == null &&
      endDate == null &&
      (categories == null || categories!.isEmpty) &&
      (priorities == null || priorities!.isEmpty) &&
      minProgress == null &&
      maxProgress == null &&
      isCompleted == null;

  SearchFilter copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<TaskCategory>? categories,
    List<TaskPriority>? priorities,
    int? minProgress,
    int? maxProgress,
    bool? isCompleted,
    bool clearSearchQuery = false,
    bool clearDates = false,
    bool clearCategories = false,
    bool clearPriorities = false,
    bool clearProgress = false,
    bool clearCompleted = false,
  }) {
    return SearchFilter(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      categories: clearCategories ? null : (categories ?? this.categories),
      priorities: clearPriorities ? null : (priorities ?? this.priorities),
      minProgress: clearProgress ? null : (minProgress ?? this.minProgress),
      maxProgress: clearProgress ? null : (maxProgress ?? this.maxProgress),
      isCompleted: clearCompleted ? null : (isCompleted ?? this.isCompleted),
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        startDate,
        endDate,
        categories,
        priorities,
        minProgress,
        maxProgress,
        isCompleted,
      ];
}
