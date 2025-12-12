import 'package:flutter/material.dart';
import '../utils/loading_manager.dart';
import 'error_retry_widget.dart';

/// Global error handler widget that listens to loading manager errors
class GlobalErrorHandler extends StatelessWidget {
  final Widget child;
  final bool showSnackBars;

  const GlobalErrorHandler({
    super.key,
    required this.child,
    this.showSnackBars = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoadingState>(
      stream: loadingManager.stateStream,
      builder: (context, snapshot) {
        final loadingState = snapshot.data ?? const LoadingState.idle();
        
        // Show error snackbars for global errors
        if (showSnackBars && loadingState.hasError && loadingState.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SnackBarHelper.showError(
              context,
              loadingState.errorMessage!,
              onRetry: () {
                loadingManager.clearError();
              },
            );
          });
        }
        
        return child;
      },
    );
  }
}

/// Mixin for handling common error scenarios in screens
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  /// Handle and display error with appropriate UI
  void handleError(String error, {VoidCallback? onRetry}) {
    final isNetworkError = error.toLowerCase().contains('network') || 
                          error.toLowerCase().contains('internet') ||
                          error.toLowerCase().contains('connection');
    
    if (isNetworkError) {
      SnackBarHelper.showError(
        context,
        'Connection lost. Please check your internet connection.',
        onRetry: onRetry,
      );
    } else {
      SnackBarHelper.showError(context, error, onRetry: onRetry);
    }
  }

  /// Show success message
  void showSuccess(String message) {
    SnackBarHelper.showSuccess(context, message);
  }

  /// Show info message
  void showInfo(String message) {
    SnackBarHelper.showInfo(context, message);
  }

  /// Show warning message
  void showWarning(String message) {
    SnackBarHelper.showWarning(context, message);
  }

  /// Handle operation with loading and error states
  Future<void> handleOperation(
    Future<void> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    final operationId = 'operation_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      loadingManager.startOperation(operationId, message: loadingMessage);
      
      await operation();
      
      loadingManager.completeOperation(operationId);
      
      if (successMessage != null) {
        showSuccess(successMessage);
      }
      
      onSuccess?.call();
    } catch (e) {
      loadingManager.failOperation(operationId, e.toString());
      
      if (onError != null) {
        onError(e.toString());
      } else {
        handleError(e.toString());
      }
    }
  }
}

/// Widget for wrapping operations with loading states
class OperationWrapper extends StatefulWidget {
  final Future<void> Function() operation;
  final Widget Function(BuildContext context, VoidCallback execute) builder;
  final String? loadingMessage;
  final String? successMessage;
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const OperationWrapper({
    super.key,
    required this.operation,
    required this.builder,
    this.loadingMessage,
    this.successMessage,
    this.onSuccess,
    this.onError,
  });

  @override
  State<OperationWrapper> createState() => _OperationWrapperState();
}

class _OperationWrapperState extends State<OperationWrapper> with ErrorHandlingMixin {
  bool _isExecuting = false;

  void _execute() async {
    if (_isExecuting) return;
    
    setState(() {
      _isExecuting = true;
    });

    await handleOperation(
      widget.operation,
      loadingMessage: widget.loadingMessage,
      successMessage: widget.successMessage,
      onSuccess: () {
        widget.onSuccess?.call();
        setState(() {
          _isExecuting = false;
        });
      },
      onError: (error) {
        widget.onError?.call(error);
        setState(() {
          _isExecuting = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _execute);
  }
}