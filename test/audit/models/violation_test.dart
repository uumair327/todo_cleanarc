import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/violation.dart';
import 'package:todo_cleanarc/audit/models/severity.dart';

void main() {
  group('Violation', () {
    test('should create instance with required fields', () {
      final violation = Violation(
        id: 'v1',
        ruleId: 'pages-001',
        ruleName: 'Pages contain only presentation logic',
        severity: Severity.critical,
        file: 'lib/pages/home.dart',
        lineNumber: 42,
        message: 'Direct database access in page',
        recommendation: 'Move database logic to operations layer',
      );

      expect(violation.id, 'v1');
      expect(violation.ruleId, 'pages-001');
      expect(violation.ruleName, 'Pages contain only presentation logic');
      expect(violation.severity, Severity.critical);
      expect(violation.file, 'lib/pages/home.dart');
      expect(violation.lineNumber, 42);
      expect(violation.message, 'Direct database access in page');
      expect(violation.recommendation, 'Move database logic to operations layer');
      expect(violation.metadata, isEmpty);
    });

    test('should create instance with metadata', () {
      final violation = Violation(
        id: 'v2',
        ruleId: 'solid-001',
        ruleName: 'Single Responsibility Principle',
        severity: Severity.major,
        file: 'lib/utils/helper.dart',
        lineNumber: 10,
        message: 'Class has multiple responsibilities',
        recommendation: 'Split into focused classes',
        metadata: {'methodCount': 15, 'cohesion': 0.3},
      );

      expect(violation.metadata['methodCount'], 15);
      expect(violation.metadata['cohesion'], 0.3);
    });

    test('should support equality comparison', () {
      final v1 = Violation(
        id: 'v1',
        ruleId: 'test',
        ruleName: 'Test',
        severity: Severity.minor,
        file: 'test.dart',
        lineNumber: 1,
        message: 'test',
        recommendation: 'test',
      );

      final v2 = Violation(
        id: 'v1',
        ruleId: 'different',
        ruleName: 'Different',
        severity: Severity.critical,
        file: 'other.dart',
        lineNumber: 99,
        message: 'different',
        recommendation: 'different',
      );

      expect(v1, equals(v2)); // Same id means equal
      expect(v1.hashCode, equals(v2.hashCode));
    });

    test('should support copyWith', () {
      final original = Violation(
        id: 'v1',
        ruleId: 'test',
        ruleName: 'Test',
        severity: Severity.minor,
        file: 'test.dart',
        lineNumber: 1,
        message: 'test',
        recommendation: 'test',
      );

      final updated = original.copyWith(
        severity: Severity.critical,
        lineNumber: 42,
      );

      expect(updated.id, 'v1');
      expect(updated.severity, Severity.critical);
      expect(updated.lineNumber, 42);
      expect(updated.file, 'test.dart');
    });

    test('should have meaningful toString', () {
      final violation = Violation(
        id: 'v1',
        ruleId: 'test',
        ruleName: 'Test Rule',
        severity: Severity.major,
        file: 'lib/test.dart',
        lineNumber: 10,
        message: 'test',
        recommendation: 'test',
      );

      final str = violation.toString();
      expect(str, contains('Test Rule'));
      expect(str, contains('lib/test.dart'));
      expect(str, contains('10'));
      expect(str, contains('major'));
    });
  });
}
