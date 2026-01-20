import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// Property-based test runner that executes properties with multiple iterations
class PropertyTestRunner {
  static const int defaultIterations = 100;
  static const int defaultSeed = 42;
  
  /// Runs a property-based test with the specified number of iterations
  /// 
  /// [property] - The property function to test
  /// [iterations] - Number of test iterations (default: 100)
  /// [seed] - Random seed for reproducible tests (optional)
  /// [description] - Test description for reporting
  static void runProperty<T>({
    required String description,
    required bool Function() property,
    int iterations = defaultIterations,
    int? seed,
    String? featureName,
    int? propertyNumber,
    String? propertyText,
    String? validates,
  }) {
    test(description, () {
      if (seed != null) {
        // Set seed for reproducible tests
        Random(seed);
      }
      
      final failures = <PropertyFailure>[];
      
      for (int i = 0; i < iterations; i++) {
        try {
          final result = property();
          if (!result) {
            failures.add(PropertyFailure(
              iteration: i + 1,
              message: 'Property returned false',
            ));
          }
        } catch (e, stackTrace) {
          failures.add(PropertyFailure(
            iteration: i + 1,
            message: 'Property threw exception: $e',
            stackTrace: stackTrace,
          ));
        }
      }
      
      if (failures.isNotEmpty) {
        final failureReport = _generateFailureReport(
          description: description,
          iterations: iterations,
          failures: failures,
          featureName: featureName,
          propertyNumber: propertyNumber,
          propertyText: propertyText,
          validates: validates,
        );
        fail(failureReport);
      }
    });
  }
  
  /// Runs a property-based test with generated input data
  /// 
  /// [generator] - Function that generates test input
  /// [property] - The property function to test with generated input
  /// [iterations] - Number of test iterations (default: 100)
  /// [seed] - Random seed for reproducible tests (optional)
  /// [description] - Test description for reporting
  static void runPropertyWithGenerator<T>({
    required String description,
    required T Function() generator,
    required bool Function(T) property,
    int iterations = defaultIterations,
    int? seed,
    String? featureName,
    int? propertyNumber,
    String? propertyText,
    String? validates,
  }) {
    test(description, () {
      if (seed != null) {
        // Set seed for reproducible tests
        Random(seed);
      }
      
      final failures = <PropertyFailureWithInput<T>>[];
      
      for (int i = 0; i < iterations; i++) {
        try {
          final input = generator();
          final result = property(input);
          if (!result) {
            failures.add(PropertyFailureWithInput<T>(
              iteration: i + 1,
              message: 'Property returned false',
              input: input,
            ));
          }
        } catch (e, stackTrace) {
          try {
            final input = generator();
            failures.add(PropertyFailureWithInput<T>(
              iteration: i + 1,
              message: 'Property threw exception: $e',
              stackTrace: stackTrace,
              input: input,
            ));
          } catch (generatorError) {
            failures.add(PropertyFailureWithInput<T>(
              iteration: i + 1,
              message: 'Generator threw exception: $generatorError, Property exception: $e',
              stackTrace: stackTrace,
              input: null,
            ));
          }
        }
      }
      
      if (failures.isNotEmpty) {
        final failureReport = _generateFailureReportWithInput<T>(
          description: description,
          iterations: iterations,
          failures: failures,
          featureName: featureName,
          propertyNumber: propertyNumber,
          propertyText: propertyText,
          validates: validates,
        );
        fail(failureReport);
      }
    });
  }
  
  /// Generates a failure report for property-based tests
  static String _generateFailureReport({
    required String description,
    required int iterations,
    required List<PropertyFailure> failures,
    String? featureName,
    int? propertyNumber,
    String? propertyText,
    String? validates,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Property-based test failed: $description');
    
    if (featureName != null && propertyNumber != null && propertyText != null) {
      buffer.writeln('**Feature: $featureName, Property $propertyNumber: $propertyText**');
    }
    
    if (validates != null) {
      buffer.writeln('**Validates: $validates**');
    }
    
    buffer.writeln('Failed ${failures.length} out of $iterations iterations');
    buffer.writeln();
    
    // Show first few failures for debugging
    const maxFailuresToShow = 5;
    final failuresToShow = failures.take(maxFailuresToShow);
    
    for (final failure in failuresToShow) {
      buffer.writeln('Iteration ${failure.iteration}: ${failure.message}');
      if (failure.stackTrace != null) {
        buffer.writeln('Stack trace: ${failure.stackTrace}');
      }
      buffer.writeln();
    }
    
    if (failures.length > maxFailuresToShow) {
      buffer.writeln('... and ${failures.length - maxFailuresToShow} more failures');
    }
    
    return buffer.toString();
  }
  
  /// Generates a failure report for property-based tests with input data
  static String _generateFailureReportWithInput<T>({
    required String description,
    required int iterations,
    required List<PropertyFailureWithInput<T>> failures,
    String? featureName,
    int? propertyNumber,
    String? propertyText,
    String? validates,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Property-based test failed: $description');
    
    if (featureName != null && propertyNumber != null && propertyText != null) {
      buffer.writeln('**Feature: $featureName, Property $propertyNumber: $propertyText**');
    }
    
    if (validates != null) {
      buffer.writeln('**Validates: $validates**');
    }
    
    buffer.writeln('Failed ${failures.length} out of $iterations iterations');
    buffer.writeln();
    
    // Show first few failures for debugging
    const maxFailuresToShow = 5;
    final failuresToShow = failures.take(maxFailuresToShow);
    
    for (final failure in failuresToShow) {
      buffer.writeln('Iteration ${failure.iteration}: ${failure.message}');
      if (failure.input != null) {
        buffer.writeln('Input: ${failure.input}');
      }
      if (failure.stackTrace != null) {
        buffer.writeln('Stack trace: ${failure.stackTrace}');
      }
      buffer.writeln();
    }
    
    if (failures.length > maxFailuresToShow) {
      buffer.writeln('... and ${failures.length - maxFailuresToShow} more failures');
    }
    
    return buffer.toString();
  }
}

/// Represents a property test failure
class PropertyFailure {
  final int iteration;
  final String message;
  final StackTrace? stackTrace;
  
  PropertyFailure({
    required this.iteration,
    required this.message,
    this.stackTrace,
  });
}

/// Represents a property test failure with input data
class PropertyFailureWithInput<T> extends PropertyFailure {
  final T? input;
  
  PropertyFailureWithInput({
    required super.iteration,
    required super.message,
    super.stackTrace,
    this.input,
  });
}

/// Utility functions for property-based testing
class PropertyTestUtils {
  /// Checks if a property holds for all elements in a list
  static bool forAll<T>(List<T> items, bool Function(T) predicate) {
    return items.every(predicate);
  }
  
  /// Checks if a property holds for at least one element in a list
  static bool exists<T>(List<T> items, bool Function(T) predicate) {
    return items.any(predicate);
  }
  
  /// Checks if two lists are equivalent (same elements, possibly different order)
  static bool listsEquivalent<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    
    final set1 = Set<T>.from(list1);
    final set2 = Set<T>.from(list2);
    
    return set1.containsAll(set2) && set2.containsAll(set1);
  }
  
  /// Checks if a list is sorted according to a comparison function
  static bool isSorted<T>(List<T> list, int Function(T, T) compare) {
    for (int i = 0; i < list.length - 1; i++) {
      if (compare(list[i], list[i + 1]) > 0) {
        return false;
      }
    }
    return true;
  }
}
