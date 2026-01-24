import 'package:equatable/equatable.dart';

abstract class ExportImportState extends Equatable {
  const ExportImportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExportImportInitial extends ExportImportState {
  const ExportImportInitial();
}

/// Loading state during export/import operation
class ExportImportLoading extends ExportImportState {
  const ExportImportLoading();
}

/// Success state after export operation
class ExportSuccess extends ExportImportState {
  final String data;
  final String format;

  const ExportSuccess({
    required this.data,
    required this.format,
  });

  @override
  List<Object?> get props => [data, format];
}

/// Success state after import operation
class ImportSuccess extends ExportImportState {
  final int importedCount;

  const ImportSuccess(this.importedCount);

  @override
  List<Object?> get props => [importedCount];
}

/// Error state
class ExportImportError extends ExportImportState {
  final String message;

  const ExportImportError(this.message);

  @override
  List<Object?> get props => [message];
}
