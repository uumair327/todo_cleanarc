import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import '../../../domain/usecases/get_task_by_id_usecase.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../../../core/domain/value_objects/task_id.dart';
import '../../../../../core/domain/value_objects/user_id.dart';
import 'task_form_event.dart';
import 'task_form_state.dart';

/// Helper extension to convert between DomainTime and TimeOfDay
extension DomainTimeConversion on DomainTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayConversion on TimeOfDay {
  DomainTime toDomainTime() => DomainTime(hour: hour, minute: minute);
}

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final UserId _currentUserId;

  TaskFormBloc({
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required GetTaskByIdUseCase getTaskByIdUseCase,
    required UserId currentUserId,
  })  : _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _getTaskByIdUseCase = getTaskByIdUseCase,
        _currentUserId = currentUserId,
        super(TaskFormState()) {
    on<TaskFormInitialized>(_onTaskFormInitialized);
    on<TaskFormLoadById>(_onTaskFormLoadById);
    on<TaskFormTitleChanged>(_onTaskFormTitleChanged);
    on<TaskFormDescriptionChanged>(_onTaskFormDescriptionChanged);
    on<TaskFormDueDateChanged>(_onTaskFormDueDateChanged);
    on<TaskFormDueTimeChanged>(_onTaskFormDueTimeChanged);
    on<TaskFormCategoryChanged>(_onTaskFormCategoryChanged);
    on<TaskFormPriorityChanged>(_onTaskFormPriorityChanged);
    on<TaskFormProgressChanged>(_onTaskFormProgressChanged);
    on<TaskFormSubmitted>(_onTaskFormSubmitted);
    on<TaskFormReset>(_onTaskFormReset);
  }

  void _onTaskFormInitialized(
    TaskFormInitialized event,
    Emitter<TaskFormState> emit,
  ) {
    if (event.task != null) {
      // Edit mode - populate form with existing task data
      final task = event.task!;
      emit(TaskFormState(
        isEditing: true,
        originalTask: task,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        dueTime: task.dueTime.toTimeOfDay(),
        category: task.category,
        priority: task.priority,
        progressPercentage: task.progressPercentage,
      ).validateForm());
    } else {
      // Create mode - reset to default values
      emit(TaskFormState().validateForm());
    }
  }

  Future<void> _onTaskFormLoadById(
    TaskFormLoadById event,
    Emitter<TaskFormState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _getTaskByIdUseCase(TaskId.fromString(event.taskId));
      
      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false,
          errorMessage: _getFailureMessage(failure),
        )),
        (task) {
          if (task != null) {
            // Edit mode - populate form with loaded task data
            emit(TaskFormState(
              isLoading: false,
              isEditing: true,
              originalTask: task,
              title: task.title,
              description: task.description,
              dueDate: task.dueDate,
              dueTime: task.dueTime.toTimeOfDay(),
              category: task.category,
              priority: task.priority,
              progressPercentage: task.progressPercentage,
            ).validateForm());
          } else {
            emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Task not found',
            ));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTaskFormTitleChanged(
    TaskFormTitleChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      title: event.title,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormDescriptionChanged(
    TaskFormDescriptionChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      description: event.description,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormDueDateChanged(
    TaskFormDueDateChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      dueDate: event.dueDate,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormDueTimeChanged(
    TaskFormDueTimeChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      dueTime: event.dueTime,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormCategoryChanged(
    TaskFormCategoryChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      category: event.category,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormPriorityChanged(
    TaskFormPriorityChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      priority: event.priority,
      clearError: true,
    ).validateForm());
  }

  void _onTaskFormProgressChanged(
    TaskFormProgressChanged event,
    Emitter<TaskFormState> emit,
  ) {
    emit(state.copyWith(
      progressPercentage: event.progressPercentage,
      clearError: true,
    ).validateForm());
  }

  Future<void> _onTaskFormSubmitted(
    TaskFormSubmitted event,
    Emitter<TaskFormState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        errorMessage: 'Please fill in all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (state.isEditing && state.originalTask != null) {
        // Update existing task
        final updatedTask = state.originalTask!.copyWith(
          title: state.title.trim(),
          description: state.description.trim(),
          dueDate: state.dueDate,
          dueTime: state.dueTime.toDomainTime(),
          category: state.category,
          priority: state.priority,
          progressPercentage: state.progressPercentage,
          updatedAt: DateTime.now(),
        );

        final result = await _updateTaskUseCase(updatedTask);
        
        result.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            errorMessage: _getFailureMessage(failure),
          )),
          (_) => emit(state.copyWith(
            isLoading: false,
            isSubmissionSuccess: true,
          )),
        );
      } else {
        // Create new task
        final newTask = TaskEntity(
          id: TaskId.generate(),
          userId: _currentUserId,
          title: state.title.trim(),
          description: state.description.trim(),
          dueDate: state.dueDate,
          dueTime: state.dueTime.toDomainTime(),
          category: state.category,
          priority: state.priority,
          progressPercentage: state.progressPercentage,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _createTaskUseCase(newTask);
        
        result.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            errorMessage: _getFailureMessage(failure),
          )),
          (_) => emit(state.copyWith(
            isLoading: false,
            isSubmissionSuccess: true,
          )),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTaskFormReset(
    TaskFormReset event,
    Emitter<TaskFormState> emit,
  ) {
    emit(TaskFormState().validateForm());
  }

  String _getFailureMessage(dynamic failure) {
    if (failure.runtimeType.toString().contains('ServerFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('NetworkFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('CacheFailure')) {
      return (failure as dynamic).message;
    } else if (failure.runtimeType.toString().contains('ValidationFailure')) {
      return (failure as dynamic).message;
    }
    return 'An unexpected error occurred';
  }
}