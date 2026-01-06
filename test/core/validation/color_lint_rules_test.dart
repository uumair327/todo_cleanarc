import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/validation/color_lint_rules.dart';

void main() {
  group('ColorLintScanner', () {
    late Directory tempDir;
    
    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('color_lint_test');
    });
    
    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });
    
    test('should detect hardcoded Colors.* usage', () async {
      final testFile = File('${tempDir.path}/test_file.dart');
      await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red, // This should be detected
      child: Text('Hello'),
    );
  }
}
''');
      
      final violations = await ColorLintScanner._scanFile(testFile);
      
      expect(violations, hasLength(1));
      expect(violations.first.colorValue, 'Colors.red');
      expect(violations.first.type, ColorViolationType.materialColors);
    });
    
    test('should detect hardcoded hex colors', () async {
      final testFile = File('${tempDir.path}/test_file.dart');
      await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF123456), // This should be detected
      child: Text('Hello'),
    );
  }
}
''');
      
      final violations = await ColorLintScanner._scanFile(testFile);
      
      expect(violations, hasLength(1));
      expect(violations.first.colorValue, 'Color(0xFF123456)');
      expect(violations.first.type, ColorViolationType.hexColors);
    });
    
    test('should detect RGB colors', () async {
      final testFile = File('${tempDir.path}/test_file.dart');
      await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(255, 0, 0, 1.0), // This should be detected
      child: Text('Hello'),
    );
  }
}
''');
      
      final violations = await ColorLintScanner._scanFile(testFile);
      
      expect(violations, hasLength(1));
      expect(violations.first.colorValue, 'Color.fromRGBO(255, 0, 0, 1.0)');
      expect(violations.first.type, ColorViolationType.rgbColors);
    });
    
    test('should not detect semantic color usage', () async {
      final testFile = File('${tempDir.path}/test_file.dart');
      await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.surfacePrimary.toFlutterColor(),
      child: Text(
        'Hello',
        style: TextStyle(color: context.colorScheme.onSurface),
      ),
    );
  }
}
''');
      
      final violations = await ColorLintScanner._scanFile(testFile);
      
      expect(violations, isEmpty);
    });
    
    test('should skip comments', () async {
      final testFile = File('${tempDir.path}/test_file.dart');
      await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red, // This should NOT be detected (comment)
      /// color: Colors.blue, // This should NOT be detected (doc comment)
      /* color: Colors.green, */ // This should NOT be detected (block comment)
      child: Text('Hello'),
    );
  }
}
''');
      
      final violations = await ColorLintScanner._scanFile(testFile);
      
      expect(violations, isEmpty);
    });
    
    test('should generate proper validation result', () async {
      final testFile1 = File('${tempDir.path}/file1.dart');
      await testFile1.writeAsString('Container(color: Colors.red);');
      
      final testFile2 = File('${tempDir.path}/file2.dart');
      await testFile2.writeAsString('Container(color: context.appColors.surface);');
      
      final result = await ColorLintScanner.scanProject(
        rootPath: tempDir.path,
        includeTests: true,
      );
      
      expect(result.filesScanned, 2);
      expect(result.violations, hasLength(1));
      expect(result.isValid, false);
    });
    
    test('should generate proper report', () {
      final violations = [
        HardcodedColorViolation(
          filePath: 'test.dart',
          lineNumber: 5,
          line: '  color: Colors.red,',
          colorValue: 'Colors.red',
          suggestion: 'Use semantic colors',
          type: ColorViolationType.materialColors,
        ),
      ];
      
      final result = ColorValidationResult(
        violations: violations,
        filesScanned: 1,
      );
      
      final report = ColorLintScanner.generateReport(result);
      
      expect(report, contains('Color Validation Report'));
      expect(report, contains('Files scanned: 1'));
      expect(report, contains('Violations found: 1'));
      expect(report, contains('Status: FAIL'));
      expect(report, contains('test.dart'));
      expect(report, contains('Line 5: Colors.red'));
    });
  });
}