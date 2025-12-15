import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Enhanced error handler with retry mechanisms and user-friendly messages
class ErrorHandler {
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 30);

  /// Execute an operation with exponential backoff retry
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    Duration maxDelay = _maxDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration currentDelay = baseDelay;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        // Check if we should retry this error
        if (attempts >= maxRetries || (shouldRetry != null && !shouldRetry(error))) {
          rethrow;
        }

        // Log the retry attempt
        if (kDebugMode) {
          print('Retry attempt $attempts/$maxRetries after error: $error');
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * 2),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Convert exceptions to user-friendly failure messages
  static Failure handleException(dynamic exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: _getNetworkErrorMessage(exception));
    } else if (exception is ServerException) {
      return ServerFailure(message: _getServerErrorMessage(exception));
    } else if (exception is CacheException) {
      return CacheFailure(message: _getCacheErrorMessage(exception));
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(message: _getAuthErrorMessage(exception));
    } else if (exception is ValidationException) {
      return ValidationFailure(_getValidationErrorMessage(exception));
    } else if (exception is SocketException) {
      return NetworkFailure(message: 'No internet connection. Please check your network settings.');
    } else if (exception is TimeoutException) {
      return NetworkFailure(message: 'Request timed out. Please try again.');
    } else if (exception is FormatException) {
      return ServerFailure(message: 'Invalid data format received from server.');
    } else {
      return ServerFailure(message: 'An unexpected error occurred. Please try again.');
    }
  }

  /// Get user-friendly network error message
  static String _getNetworkErrorMessage(NetworkException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('no internet') || message.contains('network')) {
      return 'No internet connection. Please check your network settings and try again.';
    } else if (message.contains('timeout')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    } else if (message.contains('dns') || message.contains('host')) {
      return 'Unable to connect to server. Please try again later.';
    } else {
      return 'Network error occurred. Please check your connection and try again.';
    }
  }

  /// Get user-friendly server error message
  static String _getServerErrorMessage(ServerException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('500') || message.contains('internal server')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (message.contains('404') || message.contains('not found')) {
      return 'The requested resource was not found.';
    } else if (message.contains('403') || message.contains('forbidden')) {
      return 'You do not have permission to access this resource.';
    } else if (message.contains('401') || message.contains('unauthorized')) {
      return 'Your session has expired. Please log in again.';
    } else if (message.contains('400') || message.contains('bad request')) {
      return 'Invalid request. Please check your input and try again.';
    } else {
      return 'Server error occurred. Please try again later.';
    }
  }

  /// Get user-friendly cache error message
  static String _getCacheErrorMessage(CacheException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('storage') || message.contains('disk')) {
      return 'Storage error occurred. Please free up some space and try again.';
    } else if (message.contains('corrupt') || message.contains('invalid')) {
      return 'Local data is corrupted. The app will refresh your data.';
    } else {
      return 'Local storage error occurred. Please restart the app.';
    }
  }

  /// Get user-friendly authentication error message
  static String _getAuthErrorMessage(AuthenticationException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('invalid credentials') || message.contains('wrong password')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    } else if (message.contains('user not found')) {
      return 'No account found with this email address.';
    } else if (message.contains('email already exists')) {
      return 'An account with this email already exists.';
    } else if (message.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (message.contains('session expired')) {
      return 'Your session has expired. Please log in again.';
    } else {
      return 'Authentication error occurred. Please try logging in again.';
    }
  }

  /// Get user-friendly validation error message
  static String _getValidationErrorMessage(ValidationException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('password')) {
      return 'Password must be at least 6 characters long.';
    } else if (message.contains('required')) {
      return 'This field is required.';
    } else {
      return exception.message;
    }
  }

  /// Determine if an error should be retried
  static bool shouldRetryError(dynamic error) {
    if (error is NetworkException) {
      return true; // Retry network errors
    } else if (error is ServerException) {
      final message = error.message.toLowerCase();
      // Don't retry client errors (4xx), but retry server errors (5xx)
      return message.contains('500') || 
             message.contains('502') || 
             message.contains('503') || 
             message.contains('504');
    } else if (error is SocketException) {
      return true; // Retry connection errors
    } else if (error is TimeoutException) {
      return true; // Retry timeouts
    }
    
    return false; // Don't retry other errors
  }
}

/// Error recovery strategies
class ErrorRecovery {
  /// Attempt to recover from storage corruption
  static Future<bool> recoverFromStorageCorruption() async {
    try {
      // Clear corrupted data and reinitialize
      // This would be implemented based on your storage system
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Attempt to recover network connectivity
  static Future<bool> recoverNetworkConnectivity() async {
    try {
      // Attempt to ping a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear cache and retry operation
  static Future<T> clearCacheAndRetry<T>(Future<T> Function() operation) async {
    try {
      // Clear relevant caches
      // This would be implemented based on your caching system
      return await operation();
    } catch (e) {
      rethrow;
    }
  }
}