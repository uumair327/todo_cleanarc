import 'dart:async';
import 'package:flutter/foundation.dart';

/// Loading state manager for tracking multiple concurrent operations
class LoadingManager {
  final Map<String, LoadingOperation> _operations = {};
  final StreamController<LoadingState> _stateController = StreamController.broadcast();

  /// Stream of loading state changes
  Stream<LoadingState> get stateStream => _stateController.stream;

  /// Current loading state
  LoadingState get currentState {
    if (_operations.isEmpty) {
      return const LoadingState.idle();
    }

    final operations = _operations.values.toList();
    final hasError = operations.any((op) => op.hasError);
    final totalProgress = operations.fold<double>(0, (sum, op) => sum + op.progress) / operations.length;
    
    if (hasError) {
      final errorOp = operations.firstWhere((op) => op.hasError);
      return LoadingState.error(errorOp.errorMessage ?? 'An error occurred');
    }

    return LoadingState.loading(
      message: _getPrimaryLoadingMessage(),
      progress: totalProgress,
      operationCount: operations.length,
    );
  }

  /// Start a loading operation
  void startOperation(String operationId, {String? message}) {
    _operations[operationId] = LoadingOperation(
      id: operationId,
      message: message ?? 'Loading...',
      startTime: DateTime.now(),
    );
    _notifyStateChange();
  }

  /// Update operation progress
  void updateProgress(String operationId, double progress, {String? message}) {
    final operation = _operations[operationId];
    if (operation != null) {
      _operations[operationId] = operation.copyWith(
        progress: progress.clamp(0.0, 1.0),
        message: message,
      );
      _notifyStateChange();
    }
  }

  /// Complete an operation successfully
  void completeOperation(String operationId) {
    _operations.remove(operationId);
    _notifyStateChange();
  }

  /// Mark an operation as failed
  void failOperation(String operationId, String errorMessage) {
    final operation = _operations[operationId];
    if (operation != null) {
      _operations[operationId] = operation.copyWith(
        hasError: true,
        errorMessage: errorMessage,
      );
      _notifyStateChange();
    }
  }

  /// Clear all operations
  void clearAll() {
    _operations.clear();
    _notifyStateChange();
  }

  /// Clear error state
  void clearError() {
    _operations.removeWhere((key, operation) => operation.hasError);
    _notifyStateChange();
  }

  /// Get the primary loading message to display
  String _getPrimaryLoadingMessage() {
    if (_operations.isEmpty) return 'Loading...';
    
    // Prioritize operations with custom messages
    final operationsWithMessages = _operations.values
        .where((op) => op.message.isNotEmpty && op.message != 'Loading...')
        .toList();
    
    if (operationsWithMessages.isNotEmpty) {
      return operationsWithMessages.first.message;
    }
    
    return _operations.values.first.message;
  }

  /// Notify listeners of state changes
  void _notifyStateChange() {
    if (!_stateController.isClosed) {
      _stateController.add(currentState);
    }
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
    _operations.clear();
  }
}

/// Represents a loading operation
class LoadingOperation {
  final String id;
  final String message;
  final double progress;
  final DateTime startTime;
  final bool hasError;
  final String? errorMessage;

  const LoadingOperation({
    required this.id,
    required this.message,
    this.progress = 0.0,
    required this.startTime,
    this.hasError = false,
    this.errorMessage,
  });

  LoadingOperation copyWith({
    String? message,
    double? progress,
    bool? hasError,
    String? errorMessage,
  }) {
    return LoadingOperation(
      id: id,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      startTime: startTime,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Duration since operation started
  Duration get duration => DateTime.now().difference(startTime);

  /// Whether operation is taking too long
  bool get isStale => duration > const Duration(seconds: 30);
}

/// Loading state representation
class LoadingState {
  final bool isLoading;
  final bool hasError;
  final String? message;
  final String? errorMessage;
  final double progress;
  final int operationCount;

  const LoadingState._({
    required this.isLoading,
    required this.hasError,
    this.message,
    this.errorMessage,
    this.progress = 0.0,
    this.operationCount = 0,
  });

  const LoadingState.idle()
      : isLoading = false,
        hasError = false,
        message = null,
        errorMessage = null,
        progress = 0.0,
        operationCount = 0;

  const LoadingState.loading({
    String? message,
    double progress = 0.0,
    int operationCount = 1,
  }) : isLoading = true,
        hasError = false,
        message = message,
        errorMessage = null,
        progress = progress,
        operationCount = operationCount;

  const LoadingState.error(String errorMessage)
      : isLoading = false,
        hasError = true,
        message = null,
        errorMessage = errorMessage,
        progress = 0.0,
        operationCount = 0;

  @override
  String toString() {
    if (hasError) return 'LoadingState.error($errorMessage)';
    if (isLoading) return 'LoadingState.loading($message, ${(progress * 100).toInt()}%)';
    return 'LoadingState.idle()';
  }
}

/// Global loading manager instance
final loadingManager = LoadingManager();