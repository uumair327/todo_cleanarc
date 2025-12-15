# Integration Tests

This directory contains integration tests for the Flutter Todo App. Integration tests verify complete user workflows and system behavior across all layers of the application.

## Test Structure

### Test Files

- **`test_config.dart`**: Shared configuration, utilities, and test data generators
- **`user_workflow_test.dart`**: Complete user workflow tests (signup → task creation → sync)
- **`performance_test.dart`**: Performance benchmarking tests for critical operations
- **`platform_test.dart`**: Cross-platform compatibility tests
- **`sync_test.dart`**: Offline-online synchronization tests

### Test Driver

- **`integration_test_driver/integration_test.dart`**: Test driver for running integration tests with performance profiling

## Running Integration Tests

### Prerequisites

1. Ensure Flutter SDK is installed and configured
2. Install dependencies: `flutter pub get`
3. Ensure a device/emulator is connected or web server is running

### Run All Integration Tests

```bash
# Run on connected device/emulator
flutter test integration_test

# Run on specific platform
flutter test integration_test --platform android
flutter test integration_test --platform ios
flutter test integration_test --platform web
```

### Run Specific Test File

```bash
# User workflow tests
flutter test integration_test/user_workflow_test.dart

# Performance tests
flutter test integration_test/performance_test.dart

# Platform tests
flutter test integration_test/platform_test.dart

# Sync tests
flutter test integration_test/sync_test.dart
```

### Run with Performance Profiling

```bash
# Run with driver for performance profiling
flutter drive \
  --driver=integration_test_driver/integration_test.dart \
  --target=integration_test/performance_test.dart
```

## Test Coverage

### User Workflows (user_workflow_test.dart)

Tests complete user journeys through the application:

- **Signup → Dashboard → Create Task → View Task**: Validates the complete onboarding and task creation flow
- **Login → View Tasks → Edit Task → Logout**: Tests authentication and task management
- **Create Multiple Tasks → Filter → Search**: Validates task list operations

**Requirements Validated**: 1.1, 2.1, 4.1, 4.2, 5.2, 5.4, 7.3

### Performance Benchmarks (performance_test.dart)

Tests critical operations against performance requirements:

- **Database Read Operations**: Must complete within 50ms (Requirement 10.1)
- **Search Operations**: Must complete within 100ms (Requirement 10.4)
- **Task Creation**: Should complete within 100ms
- **Batch Operations**: Should handle 1000+ tasks efficiently (Requirement 10.2)
- **App Startup**: Should complete within 2 seconds
- **Sync Operations**: Should handle conflicts efficiently (Requirements 7.3, 7.4)

**Requirements Validated**: 3.5, 7.1, 10.1, 10.2, 10.4

### Cross-Platform Tests (platform_test.dart)

Tests app behavior across different platforms:

- **Platform Rendering**: Verifies app renders correctly on current platform
- **Navigation Consistency**: Tests navigation works across platforms
- **Touch/Click Interactions**: Validates input handling
- **Text Input**: Tests keyboard input on different platforms
- **Scrolling**: Verifies smooth scrolling behavior
- **Theme Consistency**: Validates consistent styling (Requirements 8.1, 8.4)
- **Back Navigation**: Tests platform-specific navigation patterns
- **Screen Size Adaptation**: Verifies responsive layout

**Requirements Validated**: 8.1, 8.2, 8.4

### Sync Tests (sync_test.dart)

Tests offline-online synchronization:

- **Offline Task Creation**: Tasks created offline should sync when online (Requirement 7.3)
- **Conflict Resolution**: Uses latest timestamp for conflict resolution (Requirement 7.4)
- **Operation Queuing**: Multiple offline operations queue correctly
- **Non-Blocking Sync**: App remains functional during sync
- **Sync Status**: User feedback for sync operations (Requirement 2.5)

**Requirements Validated**: 6.5, 7.3, 7.4, 2.5

## Test Configuration

### IntegrationTestConfig

Provides shared utilities for all integration tests:

- **`initialize()`**: Sets up test environment (Hive, HydratedBloc, DI)
- **`cleanup()`**: Tears down test environment
- **`clearTestData()`**: Clears all test data between tests
- **`waitForAppToSettle()`**: Waits for animations and async operations
- **Helper methods**: `tapAndSettle()`, `enterTextAndSettle()`, `scrollUntilVisible()`

### IntegrationTestData

Generates test data:

- **`generateTestEmail()`**: Creates unique test email addresses
- **`generateTestPassword()`**: Returns valid test password
- **`generateTestTaskTitle()`**: Creates unique task titles
- **`generateTestTaskDescription()`**: Returns test task descriptions

### PerformanceBenchmark

Measures operation performance:

- **`start()`**: Begins timing
- **`stop()`**: Ends timing and returns duration
- **`assertWithinTime()`**: Asserts operation completed within expected time
- **`printResults()`**: Outputs benchmark results

## Best Practices

### Test Isolation

- Each test should be independent and not rely on other tests
- Use `setUp()` and `tearDown()` to initialize and clean up test environment
- Clear test data between tests to avoid interference

### Test Data

- Use unique identifiers (timestamps, seeds) for test data
- Avoid hardcoded test data that might conflict with existing data
- Clean up test data after tests complete

### Performance Testing

- Run performance tests on real devices when possible
- Avoid running performance tests on slow emulators
- Consider device capabilities when setting performance thresholds
- Run multiple iterations to get consistent results

### Platform Testing

- Test on multiple platforms (Android, iOS, Web, Desktop)
- Consider platform-specific behaviors and UI patterns
- Test on different screen sizes and orientations
- Verify accessibility features work across platforms

### Debugging

- Use `printResults()` to output performance metrics
- Add debug prints to track test execution flow
- Use `tester.pumpAndSettle()` to wait for async operations
- Check test logs for error messages and stack traces

## Continuous Integration

### CI/CD Integration

Integration tests can be run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Integration Tests
  run: |
    flutter test integration_test
    
# With performance profiling
- name: Run Performance Tests
  run: |
    flutter drive \
      --driver=integration_test_driver/integration_test.dart \
      --target=integration_test/performance_test.dart
```

### Test Reports

- Integration test results are output to console
- Performance metrics are printed during test execution
- Failed tests include error messages and stack traces
- Consider using test reporting tools for CI/CD integration

## Troubleshooting

### Common Issues

1. **Tests timeout**: Increase timeout duration in test configuration
2. **Device not found**: Ensure device/emulator is connected and running
3. **Dependency errors**: Run `flutter pub get` to install dependencies
4. **State persistence**: Ensure `cleanup()` is called in `tearDown()`
5. **Performance failures**: Check device capabilities and adjust thresholds

### Debug Mode

Run tests with verbose output:

```bash
flutter test integration_test --verbose
```

### Test Specific Scenarios

To test specific scenarios, modify test data generators or add new test cases following the existing patterns.

## Requirements Mapping

All integration tests map to specific requirements from the requirements document:

- **Authentication**: Requirements 1.1, 1.2, 1.3, 2.1, 2.2, 2.3
- **Task Management**: Requirements 4.1, 4.2, 4.3, 5.1, 5.2, 5.4, 6.1, 6.2, 6.3
- **Offline/Sync**: Requirements 6.5, 7.1, 7.2, 7.3, 7.4
- **UI/UX**: Requirements 8.1, 8.2, 8.3, 8.4, 8.5
- **Performance**: Requirements 3.5, 10.1, 10.2, 10.3, 10.4

## Future Enhancements

- Add more edge case scenarios
- Implement visual regression testing
- Add accessibility testing
- Expand performance benchmarks
- Add network condition simulation
- Implement automated screenshot capture
- Add test coverage reporting
