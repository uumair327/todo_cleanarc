import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/severity.dart';

void main() {
  group('Severity enum', () {
    test('should have all expected severity values', () {
      expect(Severity.values, hasLength(3));
      expect(Severity.values, contains(Severity.critical));
      expect(Severity.values, contains(Severity.major));
      expect(Severity.values, contains(Severity.minor));
    });
  });
}
