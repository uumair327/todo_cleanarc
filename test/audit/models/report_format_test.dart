import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/report_format.dart';

void main() {
  group('ReportFormat enum', () {
    test('should have all expected format values', () {
      expect(ReportFormat.values, hasLength(3));
      expect(ReportFormat.values, contains(ReportFormat.markdown));
      expect(ReportFormat.values, contains(ReportFormat.json));
      expect(ReportFormat.values, contains(ReportFormat.html));
    });
  });
}
