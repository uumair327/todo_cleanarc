import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/export_import/export_import_bloc.dart';
import '../bloc/export_import/export_import_event.dart';
import '../bloc/export_import/export_import_state.dart';

class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportImportBloc(
        exportTasksUseCase: sl(),
        importTasksUseCase: sl(),
      ),
      child: const _ExportImportScreenContent(),
    );
  }
}

class _ExportImportScreenContent extends StatelessWidget {
  const _ExportImportScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export / Import Tasks'),
      ),
      body: BlocConsumer<ExportImportBloc, ExportImportState>(
        listener: (context, state) {
          if (state is ExportSuccess) {
            _handleExportSuccess(context, state);
          } else if (state is ImportSuccess) {
            _showSuccessMessage(
              context,
              'Successfully imported ${state.importedCount} tasks',
            );
            // Reset state after showing message
            context.read<ExportImportBloc>().add(const ResetExportImportStateEvent());
          } else if (state is ExportImportError) {
            _showErrorMessage(context, state.message);
            // Reset state after showing message
            context.read<ExportImportBloc>().add(const ResetExportImportStateEvent());
          }
        },
        builder: (context, state) {
          if (state is ExportImportLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildExportSection(context),
                const SizedBox(height: 32),
                _buildImportSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Export Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Export all your tasks to a file for backup or transfer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ExportImportBloc>().add(
                            const ExportTasksToCsvEvent(),
                          );
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export as CSV'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ExportImportBloc>().add(
                            const ExportTasksToJsonEvent(),
                          );
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('Export as JSON'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Import Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Import tasks from a CSV or JSON file',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndImportFile(context, 'csv'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Import CSV'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndImportFile(context, 'json'),
                    icon: const Icon(Icons.code),
                    label: const Text('Import JSON'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExportSuccess(
    BuildContext context,
    ExportSuccess state,
  ) async {
    try {
      // Get the downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = state.format;
      final fileName = 'tasks_export_$timestamp.$extension';
      final filePath = '${directory.path}/$fileName';

      // Write the file
      final file = File(filePath);
      await file.writeAsString(state.data);

      if (context.mounted) {
        _showSuccessMessage(
          context,
          'Tasks exported successfully to:\n$filePath',
        );
        // Reset state after showing message
        context.read<ExportImportBloc>().add(const ResetExportImportStateEvent());
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to save export file: $e');
        // Reset state after showing message
        context.read<ExportImportBloc>().add(const ResetExportImportStateEvent());
      }
    }
  }

  Future<void> _pickAndImportFile(BuildContext context, String format) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [format],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        if (context.mounted) {
          if (format == 'csv') {
            context.read<ExportImportBloc>().add(
                  ImportTasksFromCsvEvent(content),
                );
          } else {
            context.read<ExportImportBloc>().add(
                  ImportTasksFromJsonEvent(content),
                );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to read file: $e');
      }
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
