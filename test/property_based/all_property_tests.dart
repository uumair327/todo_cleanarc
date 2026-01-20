/// Main entry point for all property-based tests
/// 
/// This file imports and runs all property-based tests for the Flutter Todo App.
/// Run with: flutter test test/property_based/all_property_tests.dart

import 'package:flutter_test/flutter_test.dart';

// Import all property-based test files
import 'examples/task_entity_properties_test.dart' as task_entity_tests;
import 'auth_properties_test.dart' as auth_properties_tests;
import 'input_validation_properties_test.dart' as input_validation_tests;
import 'task_persistence_properties_test.dart' as task_persistence_tests;
import 'sync_properties_test.dart' as sync_properties_tests;
import 'performance_properties_test.dart' as performance_properties_tests;
import 'ui_theme_properties_test.dart' as ui_theme_properties_tests;
import 'session_management_properties_test.dart' as session_management_tests;
import 'dashboard_statistics_properties_test.dart' as dashboard_statistics_tests;
import 'search_filter_properties_test.dart' as search_filter_properties_tests;
import 'form_population_properties_test.dart' as form_population_tests;

void main() {
  group('Flutter Todo App - All Property-Based Tests', () {
    
    group('Task Entity Properties', () {
      task_entity_tests.main();
    });
    
    group('Authentication Properties', () {
      auth_properties_tests.main();
    });
    
    group('Input Validation Properties', () {
      input_validation_tests.main();
    });
    
    group('Task Persistence Properties', () {
      task_persistence_tests.main();
    });
    
    group('Sync Properties', () {
      sync_properties_tests.main();
    });
    
    group('Performance Properties', () {
      performance_properties_tests.main();
    });
    
    group('UI Theme Properties', () {
      ui_theme_properties_tests.main();
    });
    
    group('Session Management Properties', () {
      session_management_tests.main();
    });
    
    group('Dashboard Statistics Properties', () {
      dashboard_statistics_tests.main();
    });
    
    group('Search and Filter Properties', () {
      search_filter_properties_tests.main();
    });
    
    group('Form Population Properties', () {
      form_population_tests.main();
    });
    
    // Additional property test groups will be added here as they are implemented
    // Examples:
    // group('UI Properties', () {
    //   ui_properties_tests.main();
    // });
  });
}
