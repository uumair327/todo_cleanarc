import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../../../core/domain/value_objects/task_id.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class TaskListLoadRequested extends TaskListEvent {
  const TaskListLoadRequested();
}

class TaskListRefreshRequested extends TaskListEvent {
  const TaskListRefreshRequested();
}

class TaskListSearchRequested extends TaskListEvent {
  final String query;

  const TaskListSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class TaskListFilterByDateRequested extends TaskListEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const TaskListFilterByDateRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class TaskListTaskDeleted extends TaskListEvent {
  final TaskId taskId;

  const TaskListTaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskListTaskCompleted extends TaskListEvent {
  final TaskEntity task;

  const TaskListTaskCompleted(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskListClearFilters extends TaskListEvent {
  const TaskListClearFilters();
}

class TaskListSyncRequested extends TaskListEvent {
  const TaskListSyncRequested();
}

class TaskListLoadPaginatedRequested extends TaskListEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const TaskListLoadPaginatedRequested({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery, startDate, endDate];
}

class TaskListLoadMoreRequested extends TaskListEvent {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const TaskListLoadMoreRequested({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, pageSize, searchQuery, startDate, endDate];
}