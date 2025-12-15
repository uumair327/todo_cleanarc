import 'package:flutter_test/flutter_test.dart';
import 'generators/task_generators.dart';
import 'generators/user_generators.dart';
import 'generators/category_generators.dart';
import 'property_test_runner.dart';
import 'property_test_config.dart';

/// Verification test to ensure the property-based testing framework is working correctly
void main() {
  group('Property-Based Testing Framework Verification', () {
    
    test('TaskGenerators can generate valid tasks', () {
      for (int i = 0; i < 10; i++) {
        final task = TaskGenerators.generateValidTask();
        
        // Verify basic properties
        expect(task.title, isNotEmpty);
        expect(task.progressPercentage, inInclusiveRange(0, 100));
        expect(task.updatedAt.isAfter(task.createdAt) || 
               task.updatedAt.isAtSameMomentAs(task.createdAt), isTrue);
      }
    });
    
    test('UserGenerators can generate valid users', () {
      for (int i = 0; i < 10; i++) {
        final user = UserGenerators.generateValidUser();
        
        // Verify basic properties
        expect(user.email.value, contains('@'));
        expect(user.displayName, isNotEmpty);
        expect(user.createdAt, isNotNull);
      }
    });
    
    test('CategoryGenerators can generate valid categories', () {
      for (int i = 0; i < 10; i++) {
        final category = CategoryGenerators.generateValidCategory();
        
        // Verify basic properties
        expect(category.name, isNotEmpty);
        expect(category.taskCount, greaterThanOrEqualTo(0));
      }
    });
    
    PropertyTestRunner.runPropertyWithGenerator<int>(
      description: 'Simple property test - numbers are equal to themselves',
      generator: () => DateTime.now().millisecondsSinceEpoch % 1000,
      property: (number) => number == number,
      iterations: 50,
    );
    
    test('Property test configuration is accessible', () {
      expect(PropertyTestConfig.defaultIterations, equals(100));
      expect(PropertyTestConfig.featureName, equals('flutter-todo-app'));
      
      final settings = PropertyTestConfig.getSettingsFor('authentication');
      expect(settings.iterations, equals(100));
    });
    
    test('Property test metadata can be created', () {
      final metadata = PropertyTestMetadata.forTodoApp(
        propertyNumber: 1,
        propertyText: 'Test property',
        validates: 'Requirements 1.1',
        description: 'Test description',
      );
      
      expect(metadata.featureName, equals('flutter-todo-app'));
      expect(metadata.propertyNumber, equals(1));
      expect(metadata.formattedComment, contains('**Feature: flutter-todo-app, Property 1: Test property**'));
    });
  });
}
