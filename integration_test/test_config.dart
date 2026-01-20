/// Configuration for integration tests
/// Provides shared setup, utilities, and constants for all integration tests
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_cleanarc/core/services/injection_container.dart' as di;

/// Integration test configuration and utilities
class IntegrationTestConfig {
  /// Initialize test environment
  static Future<void> initialize() async {
    // Initialize Hive for testing
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
    
    // Initialize HydratedBloc storage
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: directory,
    );
    
    // Initialize dependency injection
    await di.init();
  }
  
  /// Clean up test environment
  static Future<void> cleanup() async {
    // Close all Hive boxes
    await Hive.close();
    
    // Clear HydratedBloc storage
    await HydratedBloc.storage.clear();
    
    // Note: GetIt doesn't have a reset method in production
    // DI container will be reinitialized on next test
  }
  
  /// Clear all test data
  static Future<void> clearTestData() async {
    // Clear HydratedBloc storage
    await HydratedBloc.storage.clear();
    
    // Clear specific Hive boxes if they're open
    try {
      if (Hive.isBoxOpen('tasks')) {
        await Hive.box('tasks').clear();
      }
      if (Hive.isBoxOpen('users')) {
        await Hive.box('users').clear();
      }
    } catch (e) {
      // Boxes may not be open, ignore
    }
  }
  
  /// Wait for app to settle after navigation or state changes
  static Future<void> waitForAppToSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  
  /// Find widget by key
  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }
  
  /// Find widget by text
  static Finder findByText(String text) {
    return find.text(text);
  }
  
  /// Find widget by type
  static Finder findByType<T>() {
    return find.byType(T);
  }
  
  /// Tap on widget and wait for animation
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await waitForAppToSettle(tester);
  }
  
  /// Enter text and wait for animation
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await waitForAppToSettle(tester);
  }
  
  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
    );
    await waitForAppToSettle(tester);
  }
}

/// Test data generators for integration tests
class IntegrationTestData {
  /// Generate test email
  static String generateTestEmail([int? seed]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = seed ?? timestamp;
    return 'test_user_$uniqueId@example.com';
  }
  
  /// Generate test password
  static String generateTestPassword() {
    return 'TestPassword123!';
  }
  
  /// Generate test task title
  static String generateTestTaskTitle([int? seed]) {
    final uniqueId = seed ?? DateTime.now().millisecondsSinceEpoch;
    return 'Test Task $uniqueId';
  }
  
  /// Generate test task description
  static String generateTestTaskDescription() {
    return 'This is a test task description for integration testing';
  }
}

/// Performance benchmarking utilities
class PerformanceBenchmark {
  final String operationName;
  final Stopwatch _stopwatch = Stopwatch();
  
  PerformanceBenchmark(this.operationName);
  
  /// Start timing
  void start() {
    _stopwatch.start();
  }
  
  /// Stop timing and return duration
  Duration stop() {
    _stopwatch.stop();
    return _stopwatch.elapsed;
  }
  
  /// Assert that operation completed within expected time
  void assertWithinTime(Duration expected) {
    final elapsed = _stopwatch.elapsed;
    expect(
      elapsed.inMilliseconds,
      lessThanOrEqualTo(expected.inMilliseconds),
      reason: '$operationName took ${elapsed.inMilliseconds}ms, '
          'expected <= ${expected.inMilliseconds}ms',
    );
  }
  
  /// Print benchmark results
  void printResults() {
    // Using debugPrint instead of print for test output
    debugPrint('$operationName completed in ${_stopwatch.elapsedMilliseconds}ms');
  }
}
