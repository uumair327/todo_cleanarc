import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/todo/presentation/bloc/task_form/task_form_bloc.dart';
import 'package:todo_cleanarc/feature/todo/presentation/bloc/task_form/task_form_event.dart';
import 'package:todo_cleanarc/feature/todo/presentation/bloc/task_form/task_form_state.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/create_task_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/update_task_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/usecases/get_task_by_id_usecase.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';

import 'package:todo_cleanarc/core/domain/value_objects/task_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/enums/task_enums.dart';

import 'task_form_bloc_test.mocks.dart';

@GenerateMocks([CreateTaskUseCase, UpdateTaskUseCase, GetTaskByIdUseCase])
void main() {
  late TaskFormBloc bloc;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockGetTaskByIdUseCase mockGetTaskByIdUseCase;

  setUp(() {
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockGetTaskByIdUseCase = MockGetTaskByIdUseCase();
    bloc = TaskFormBloc(
      createTaskUseCase: mockCreateTaskUseCase,
      updateTaskUseCase: mockUpdateTaskUseCase,
      getTaskByIdUseCase: mockGetTaskByIdUseCase,
      currentUserId: UserId.fromString('user123'),
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testTask = TaskEntity(
    id: const TaskId('123'),
    userId: UserId.fromString('user123'),
    title: 'Test Task',
    description: 'Test Description',
    dueDate: DateTime.now(),
    dueTime: const DomainTime(hour: 10, minute: 0),
    category: TaskCategory.ongoing,
    priority: TaskPriority.medium,
    progressPercentage: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('TaskFormBloc', () {
    test('initial state should be TaskFormState with default values', () {
      expect(bloc.state, equals(TaskFormState()));
    });

    blocTest<TaskFormBloc, TaskFormState>(
      'should update title when TaskFormTitleChanged is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const TaskFormTitleChanged('New Title')),
      expect: () => [
        isA<TaskFormState>()
            .having((s) => s.title, 'title', 'New Title')
            .having((s) => s.isValid, 'isValid', true),
      ],
    );

    blocTest<TaskFormBloc, TaskFormState>(
      'should emit [isLoading: true, isSubmissionSuccess: true] when task creation is successful',
      build: () {
        when(mockCreateTaskUseCase.call(any))
            .thenAnswer((_) async => const Right(unit));
        // Need to set a valid title so isValid becomes true
        return bloc;
      },
      act: (bloc) {
        bloc.add(const TaskFormTitleChanged('Valid title'));
        bloc.add(const TaskFormSubmitted());
      },
      expect: () => [
        isA<TaskFormState>().having((s) => s.title, 'title', 'Valid title'),
        isA<TaskFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TaskFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.isSubmissionSuccess, 'isSubmissionSuccess', true),
      ],
    );

    blocTest<TaskFormBloc, TaskFormState>(
      'should emit [isLoading: true, errorMessage] when task creation fails',
      build: () {
        when(mockCreateTaskUseCase.call(any)).thenAnswer((_) async =>
            const Left(CacheFailure(message: 'Failed to create task')));
        return bloc;
      },
      act: (bloc) {
        bloc.add(const TaskFormTitleChanged('Valid title'));
        bloc.add(const TaskFormSubmitted());
      },
      expect: () => [
        isA<TaskFormState>().having((s) => s.title, 'title', 'Valid title'),
        isA<TaskFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TaskFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
                (s) => s.errorMessage, 'errorMessage', 'Failed to create task'),
      ],
    );

    blocTest<TaskFormBloc, TaskFormState>(
      'should update state when task is loaded for editing',
      build: () {
        when(mockGetTaskByIdUseCase.call(any))
            .thenAnswer((_) async => Right(testTask));
        return bloc;
      },
      act: (bloc) => bloc.add(const TaskFormLoadById('123')),
      expect: () => [
        isA<TaskFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TaskFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.isEditing, 'isEditing', true)
            .having((s) => s.title, 'title', testTask.title)
            .having((s) => s.originalTask, 'originalTask', testTask),
      ],
      verify: (_) {
        verify(mockGetTaskByIdUseCase.call(any));
      },
    );
  });
}
