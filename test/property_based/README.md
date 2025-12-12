# Property-Based Testing Framework

This directory contains the property-based testing framework for the Flutter Todo App. Property-based testing helps verify that properties (universal rules) hold across a wide range of inputs, providing more comprehensive testing than traditional example-based tests.

## Structure

```
test/property_based/
├── README.md                     # This documentation
├── property_test_runner.dart     # Core property test execution framework
├── property_test_config.dart     # Configuration and settings
├── all_property_tests.dart       # Main entry point for all property tests
├── generators/                   # Test data generators
│   ├── task_generators.dart      # TaskEntity generators
│   ├── user_generators.dart      # UserEntity generators
│   └── category_generators.dart  # CategoryEntity generators
└── examples/                     # Example property tests
    └── task_entity_properties_test.dart
```

## Key Concepts

### Properties
Properties are universal rules that should hold for all valid inputs. For example:
- "For any valid task, creating then retrieving it should return the same data"
- "For any search query, all results should match the search criteria"

### Generators
Generators create random test data that covers the input space. They help discover edge cases that manual test cases might miss.

### Iterations
Each property is tested with multiple random inputs (default: 100 iterations) to increase confidence in the property's correctness.

## Usage

### Running Property-Based Tests

```bash
# Run all property-based tests
flutter test test/property_based/all_property_tests.dart

# Run specific property test file
flutter test test/property_based/examples/task_entity_properties_test.dart

# Run with verbose output
flutter test test/property_based/all_property_tests.dart --reporter=expanded
```

### Creating New Property Tests

1. **Create a generator** (if needed) in the `generators/` directory:

```dart
// generators/my_generators.dart
class MyGenerators {
  static MyEntity generateValidEntity() {
    // Generate random valid entity
  }
}
```

2. **Write property tests** using the PropertyTestRunner:

```dart
// my_property_test.dart
import '../property_test_runner.dart';
import '../generators/my_generators.dart';

void main() {
  group('My Property Tests', () {
    PropertyTestRunner.runPropertyWithGenerator<MyEntity>(
      description: 'My property description',
      generator: () => MyGenerators.generateValidEntity(),
      property: (entity) {
        // Return true if property holds, false otherwise
        return entity.someProperty == expectedValue;
      },
      iterations: 100,
      featureName: 'flutter-todo-app',
      propertyNumber: 1,
      propertyText: 'My property text',
      validates: 'Requirements 1.1, 1.2',
    );
  });
}
```

3. **Add to main test file**:

```dart
// all_property_tests.dart
import 'my_property_test.dart' as my_tests;

void main() {
  group('Flutter Todo App - All Property-Based Tests', () {
    group('My Properties', () {
      my_tests.main();
    });
  });
}
```

### Property Test Metadata

Each property test should include metadata linking it to the design document:

- `featureName`: "flutter-todo-app"
- `propertyNumber`: Number from design document (1-10)
- `propertyText`: Brief description of the property
- `validates`: Requirements this property validates

This creates comments in the format:
```
**Feature: flutter-todo-app, Property 3: Task persistence round trip**
**Validates: Requirements 4.2, 6.2, 6.3**
```

## Design Document Properties

The following properties from the design document should be implemented:

1. **Authentication round trip** - Requirements 1.1, 2.1
2. **Input validation consistency** - Requirements 1.2, 1.3, 4.3
3. **Task persistence round trip** - Requirements 4.2, 6.2, 6.3
4. **Offline-online sync consistency** - Requirements 6.5, 7.3, 7.4
5. **Dashboard statistics accuracy** - Requirements 3.2
6. **Search and filter correctness** - Requirements 5.2, 5.4
7. **UI theme consistency** - Requirements 8.1, 8.3, 8.4
8. **Performance bounds** - Requirements 3.5, 7.1, 10.1, 10.4
9. **Session management integrity** - Requirements 2.3, 9.2, 9.5
10. **Form population accuracy** - Requirements 6.1

## Configuration

Modify `property_test_config.dart` to adjust:
- Default iteration counts
- Test timeouts
- Random seeds for reproducible tests
- Test-specific settings

## Best Practices

1. **Write meaningful properties**: Focus on business rules and invariants
2. **Use appropriate generators**: Ensure generators cover the valid input space
3. **Handle edge cases**: Include generators for boundary conditions
4. **Keep properties simple**: Complex properties are harder to debug when they fail
5. **Use descriptive names**: Make it clear what each property is testing
6. **Link to requirements**: Always specify which requirements each property validates

## Debugging Failed Properties

When a property fails:

1. **Check the failure report**: Shows which iteration failed and why
2. **Use the seed**: Reproduce the exact failure with the same random seed
3. **Simplify the input**: Try to find the minimal failing case
4. **Verify the property**: Ensure the property correctly captures the requirement
5. **Check the implementation**: The failure might indicate a bug in the code

## Integration with CI/CD

Property-based tests should be run as part of the continuous integration pipeline:

```yaml
# Example GitHub Actions step
- name: Run Property-Based Tests
  run: flutter test test/property_based/all_property_tests.dart
```

## Dependencies

The framework uses these packages:
- `flutter_test`: Core testing framework
- `test`: Dart testing utilities
- `faker`: Random data generation
- `mockito`: Mocking for isolated testing

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  test: ^1.25.8
  faker: ^2.1.0
  mockito: ^5.4.4
```