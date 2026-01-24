import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/export_tasks_usecase.dart';
import '../../../domain/usecases/import_tasks_usecase.dart';
import 'export_import_event.dart';
import 'export_import_state.dart';

class ExportImportBloc extends Bloc<ExportImportEvent, ExportImportState> {
  final ExportTasksUseCase _exportTasksUseCase;
  final ImportTasksUseCase _importTasksUseCase;

  ExportImportBloc({
    required ExportTasksUseCase exportTasksUseCase,
    required ImportTasksUseCase importTasksUseCase,
  })  : _exportTasksUseCase = exportTasksUseCase,
        _importTasksUseCase = importTasksUseCase,
        super(const ExportImportInitial()) {
    on<ExportTasksToCsvEvent>(_onExportTasksToCsv);
    on<ExportTasksToJsonEvent>(_onExportTasksToJson);
    on<ImportTasksFromCsvEvent>(_onImportTasksFromCsv);
    on<ImportTasksFromJsonEvent>(_onImportTasksFromJson);
    on<ResetExportImportStateEvent>(_onResetState);
  }

  Future<void> _onExportTasksToCsv(
    ExportTasksToCsvEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(const ExportImportLoading());

    final result = await _exportTasksUseCase('csv');

    result.fold(
      (failure) => emit(ExportImportError(failure.message)),
      (data) => emit(ExportSuccess(data: data, format: 'csv')),
    );
  }

  Future<void> _onExportTasksToJson(
    ExportTasksToJsonEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(const ExportImportLoading());

    final result = await _exportTasksUseCase('json');

    result.fold(
      (failure) => emit(ExportImportError(failure.message)),
      (data) => emit(ExportSuccess(data: data, format: 'json')),
    );
  }

  Future<void> _onImportTasksFromCsv(
    ImportTasksFromCsvEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(const ExportImportLoading());

    final result = await _importTasksUseCase(event.data, 'csv');

    result.fold(
      (failure) => emit(ExportImportError(failure.message)),
      (count) => emit(ImportSuccess(count)),
    );
  }

  Future<void> _onImportTasksFromJson(
    ImportTasksFromJsonEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(const ExportImportLoading());

    final result = await _importTasksUseCase(event.data, 'json');

    result.fold(
      (failure) => emit(ExportImportError(failure.message)),
      (count) => emit(ImportSuccess(count)),
    );
  }

  void _onResetState(
    ResetExportImportStateEvent event,
    Emitter<ExportImportState> emit,
  ) {
    emit(const ExportImportInitial());
  }
}
