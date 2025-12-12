import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../domain/usecases/get_tasks_usecase.dart';
import '../../../domain/usecases/get_tasks_paginated_usecase.dart';
import '../../../domain/usecases/search_tasks_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import '../../../domain/usecases/sync_tasks_usecase.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../../../core/domain/enums/task_enums.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

class TaskListBloc extends HydratedBloc<TaskListEvent, TaskListState> {
  final GetTasksUseCase _getTasksUseCase;
  final GetTasksPaginatedUseCase _getTasksPaginatedUseCase;
  final SearchTasksUseCase _searchTasksUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final SyncTasksUseCase _syncTasksUseCase;

  TaskListBloc({
    required GetTasksUseCase getTasksUseCase,
    required GetTasksPaginatedUseCase getTasksPaginatedUseCase,
    required SearchTasksUseCase searchTasksUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required SyncTasksUseCase syncTasksUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _getTasksPaginatedUseCase = getTasksPaginatedUseCase,
        _searchTasksUseCase = searchTasksUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _syncTasksUseCase = syncTasksUseCase,
        super(const TaskListInitial()) {
    on<TaskListLoadRequested>(_onTaskListLoadRequested);
    on<TaskListLoadPaginatedRequested>(_onTaskListLoadPaginatedRequested);
    on<TaskListLoadMoreRequested>(_onTaskListLoadMoreRequested);
    on<TaskListRefreshRequested>(_onTaskListRefreshRequested);
    on<TaskListSearchRequested>(_onTaskListSearchRequested);
    on<TaskListFilterByDateRequested>(_onTaskListFilterByDateRequested);
    on<TaskListTaskDeleted>(_onTaskListTaskDeleted);
    on<TaskListTaskCompleted>(_onTaskListTaskCompleted);
    on<TaskListClearFilters>(_onTaskListClearFilters);
    on<TaskListSyncRequested>(_onTaskListSyncRequested);
  }

  Future<void> _onTaskListLoadRequested(
    TaskListLoadRequested event,
    Emitter<TaskListState> emit,
  ) async {
    emit(const TaskListLoading());
    await _loadTasks(emit);
  }

  Future<void> _onTaskListLoadPaginatedRequested(
    TaskListLoadPaginatedRequested event,
    Emitter<TaskListState> emit,
  ) async {
    emit(const TaskListLoading());
    await _loadTasksPaginated(
      emit,
      page: event.page,
      pageSize: event.pageSize,
      searchQuery: event.searchQuery,
      startDate: event.startDate,
      endDate: event.endDate,
    );
  }

  Future<void> _onTaskListLoadMoreRequested(
    TaskListLoadMoreRequested event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;
      
      try {
        final result = await _getTasksPaginatedUseCase(
          page: event.page,
          pageSize: event.pageSize,
          searchQuery: event.searchQuery,
          startDate: event.startDate,
          endDate: event.endDate,
        );
        
        result.fold(
          (failure) => emit(TaskListError(_getFailureMessage(failure))),
          (paginatedResult) {
            final allTasks = [...currentState.tasks, ...paginatedResult.data];
            
            if (allTasks.isEmpty) {
              emit(const TaskListEmpty());
            } else {
              emit(TaskListLoaded(
                tasks: allTasks,
                searchQuery: event.searchQuery,
                filterStartDate: event.startDate,
                filterEndDate: event.endDate,
                hasMore: paginatedResult.hasMore,
                currentPage: paginatedResult.currentPage,
                totalCount: paginatedResult.totalCount,
              ));
            }
          },
        );
      } catch (e) {
        emit(TaskListError(e.toString()));
      }
    }
  }

  Future<void> _onTaskListRefreshRequested(
    TaskListRefreshRequested event,
    Emitter<TaskListState> emit,
  ) async {
    await _loadTasks(emit);
  }

  Future<void> _onTaskListSearchRequested(
    TaskListSearchRequested event,
    Emitter<TaskListState> emit,
  ) async {
    emit(const TaskListLoading());
    
    try {
      final result = await _searchTasksUseCase(event.query);
      
      result.fold(
        (failure) => emit(TaskListError(_getFailureMessage(failure))),
        (tasks) {
          final filteredTasks = _applyCurrentFilters(
            tasks,
            searchQuery: event.query,
          );
          
          if (filteredTasks.isEmpty) {
            emit(const TaskListEmpty());
          } else {
            emit(TaskListLoaded(
              tasks: filteredTasks,
              searchQuery: event.query.isEmpty ? null : event.query,
            ));
          }
        },
      );
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _onTaskListFilterByDateRequested(
    TaskListFilterByDateRequested event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;
      
      try {
        final result = await _getTasksUseCase();
        
        result.fold(
          (failure) => emit(TaskListError(_getFailureMessage(failure))),
          (tasks) {
            final filteredTasks = _applyCurrentFilters(
              tasks,
              searchQuery: currentState.searchQuery,
              startDate: event.startDate,
              endDate: event.endDate,
            );
            
            if (filteredTasks.isEmpty) {
              emit(const TaskListEmpty());
            } else {
              emit(TaskListLoaded(
                tasks: filteredTasks,
                searchQuery: currentState.searchQuery,
                filterStartDate: event.startDate,
                filterEndDate: event.endDate,
              ));
            }
          },
        );
      } catch (e) {
        emit(TaskListError(e.toString()));
      }
    } else {
      // If not loaded yet, load tasks first then apply filter
      await _loadTasks(emit, 
        startDate: event.startDate, 
        endDate: event.endDate
      );
    }
  }

  Future<void> _onTaskListTaskDeleted(
    TaskListTaskDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    try {
      final result = await _deleteTaskUseCase(event.taskId);
      
      result.fold(
        (failure) => emit(TaskListError(_getFailureMessage(failure))),
        (_) {
          // Refresh the task list after deletion
          add(const TaskListRefreshRequested());
        },
      );
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _onTaskListTaskCompleted(
    TaskListTaskCompleted event,
    Emitter<TaskListState> emit,
  ) async {
    try {
      final completedTask = event.task.copyWith(
        category: TaskCategory.completed,
        progressPercentage: 100,
        updatedAt: DateTime.now(),
      );
      
      final result = await _updateTaskUseCase(completedTask);
      
      result.fold(
        (failure) => emit(TaskListError(_getFailureMessage(failure))),
        (_) {
          // Refresh the task list after completion
          add(const TaskListRefreshRequested());
        },
      );
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _onTaskListClearFilters(
    TaskListClearFilters event,
    Emitter<TaskListState> emit,
  ) async {
    await _loadTasks(emit);
  }

  Future<void> _onTaskListSyncRequested(
    TaskListSyncRequested event,
    Emitter<TaskListState> emit,
  ) async {
    try {
      // Trigger sync operation
      final syncResult = await _syncTasksUseCase();
      
      syncResult.fold(
        (failure) {
          // Sync failed, but don't change the current state
          // The sync status will be handled by the SyncManager
        },
        (_) {
          // Sync succeeded, refresh the task list to show updated data
          add(const TaskListRefreshRequested());
        },
      );
    } catch (e) {
      // Handle sync error silently - SyncManager will handle user feedback
    }
  }

  Future<void> _loadTasks(
    Emitter<TaskListState> emit, {
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _getTasksUseCase();
      
      result.fold(
        (failure) => emit(TaskListError(_getFailureMessage(failure))),
        (tasks) {
          final filteredTasks = _applyCurrentFilters(
            tasks,
            searchQuery: searchQuery,
            startDate: startDate,
            endDate: endDate,
          );
          
          if (filteredTasks.isEmpty) {
            emit(const TaskListEmpty());
          } else {
            emit(TaskListLoaded(
              tasks: filteredTasks,
              searchQuery: searchQuery,
              filterStartDate: startDate,
              filterEndDate: endDate,
            ));
          }
        },
      );
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  Future<void> _loadTasksPaginated(
    Emitter<TaskListState> emit, {
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _getTasksPaginatedUseCase(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      );
      
      result.fold(
        (failure) => emit(TaskListError(_getFailureMessage(failure))),
        (paginatedResult) {
          if (paginatedResult.data.isEmpty) {
            emit(const TaskListEmpty());
          } else {
            emit(TaskListLoaded(
              tasks: paginatedResult.data,
              searchQuery: searchQuery,
              filterStartDate: startDate,
              filterEndDate: endDate,
              hasMore: paginatedResult.hasMore,
              currentPage: paginatedResult.currentPage,
              totalCount: paginatedResult.totalCount,
            ));
          }
        },
      );
    } catch (e) {
      emit(TaskListError(e.toString()));
    }
  }

  List<TaskEntity> _applyCurrentFilters(
    List<TaskEntity> tasks, {
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filteredTasks = tasks.where((task) => !task.isDeleted).toList();

    // Apply date filter
    if (startDate != null || endDate != null) {
      filteredTasks = filteredTasks.where((task) {
        final taskDate = task.dueDate;
        
        if (startDate != null && endDate != null) {
          return taskDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 taskDate.isBefore(endDate.add(const Duration(days: 1)));
        } else if (startDate != null) {
          return taskDate.isAfter(startDate.subtract(const Duration(days: 1)));
        } else if (endDate != null) {
          return taskDate.isBefore(endDate.add(const Duration(days: 1)));
        }
        
        return true;
      }).toList();
    }

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(query) ||
               task.description.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by due date (ascending)
    filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return filteredTasks;
  }

  @override
  TaskListState? fromJson(Map<String, dynamic> json) {
    try {
      final stateType = json['type'] as String?;
      
      switch (stateType) {
        case 'loaded':
          // For offline persistence, we'll restore to initial state
          // and let the app reload tasks from local storage
          return const TaskListInitial();
        case 'empty':
          return const TaskListEmpty();
        default:
          return const TaskListInitial();
      }
    } catch (e) {
      return const TaskListInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskListState state) {
    try {
      if (state is TaskListLoaded) {
        return {'type': 'loaded'};
      } else if (state is TaskListEmpty) {
        return {'type': 'empty'};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getFailureMessage(dynamic failure) {
    if (failure.runtimeType.toString().contains('ServerFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('NetworkFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('CacheFailure')) {
      return (failure as dynamic).message;
    }
    return 'An unexpected error occurred';
  }
}