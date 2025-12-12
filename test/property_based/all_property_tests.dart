/// Main entry point for all property-based tests
/// 
/// This file imports and runs all property-based tests for the Flutter Todo App.
/// Run with: flutter test test/property_based/all_property_tests.dart

import 'package:flutter_test/flutter_test.dart';

// Import all property-based test files
import 'examples/task_entity_properties_test.dart' as task_entity_tests;

void main() {
  group('Flutter Todo App - All Property-Based Tests', () {
    
    group('Task Entity Properties', () {
      task_entity_tests.main();
    });
    
    // Additional property test groups will be added here as they are implemented
    // Examples:
    // group('User Entity Properties', () {
    //   user_entity_tests.main();
    // });
    
    // group('Authentication Properties', () {
    //   auth_properties_tests.main();
    // });
    
    // group('Sync Properties', () {
    //   sync_properties_tests.main();
    // });
    
    // group('UI Properties', () {
    //   ui_properties_tests.main();
    // });
    
    // group('Performance Properties', () {
    //   performance_properties_tests.main();
    // });
  });
}