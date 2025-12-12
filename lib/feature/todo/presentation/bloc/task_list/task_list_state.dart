import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListLoaded extends TaskListState {
  final List<TaskEntity> tasks;
  final String? searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool hasMore;
  final int currentPage;
  final int totalCount;

  const TaskListLoaded({
    required this.tasks,
    this.searchQuery,
    this.filterStartDate,
    this.filterEndDate,
    this.hasMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [
        tasks,
        searchQuery,
        filterStartDate,
        filterEndDate,
        hasMore,
        currentPage,
        totalCount,
      ];

  TaskListLoaded copyWith({
    List<TaskEntity>? tasks,
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    bool clearSearchQuery = false,
    bool clearDateFilters = false,
  }) {
    return TaskListLoaded(
      tasks: tasks ?? this.tasks,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      filterStartDate: clearDateFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDateFilters ? null : (filterEndDate ?? this.filterEndDate),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskListEmpty extends TaskListState {
  const TaskListEmpty();
}