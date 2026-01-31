import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/class_info.dart';
import 'package:todo_cleanarc/audit/models/method_info.dart';
import 'package:todo_cleanarc/audit/models/field_info.dart';

void main() {
  group('ClassInfo', () {
    test('should create instance with required fields', () {
      final classInfo = ClassInfo(
        name: 'LoginPage',
        filePath: 'lib/pages/login_page.dart',
        lineNumber: 10,
        lineCount: 50,
      );

      expect(classInfo.name, 'LoginPage');
      expect(classInfo.filePath, 'lib/pages/login_page.dart');
      expect(classInfo.lineNumber, 10);
      expect(classInfo.lineCount, 50);
      expect(classInfo.superclass, isNull);
      expect(classInfo.interfaces, isEmpty);
      expect(classInfo.mixins, isEmpty);
      expect(classInfo.methods, isEmpty);
      expect(classInfo.fields, isEmpty);
    });

    test('should create instance with optional fields', () {
      final method = MethodInfo(
        name: 'login',
        returnType: 'Future<void>',
        isAsync: true,
        isStatic: false,
        lineNumber: 20,
      );

      final field = FieldInfo(
        name: 'email',
        type: 'String',
        isStatic: false,
        isFinal: true,
        isConst: false,
        lineNumber: 15,
      );

      final classInfo = ClassInfo(
        name: 'LoginPage',
        filePath: 'lib/pages/login_page.dart',
        superclass: 'StatelessWidget',
        interfaces: ['LoginInterface'],
        mixins: ['LoginMixin'],
        methods: [method],
        fields: [field],
        lineNumber: 10,
        lineCount: 50,
      );

      expect(classInfo.superclass, 'StatelessWidget');
      expect(classInfo.interfaces, ['LoginInterface']);
      expect(classInfo.mixins, ['LoginMixin']);
      expect(classInfo.methods, hasLength(1));
      expect(classInfo.fields, hasLength(1));
    });

    test('should support equality comparison', () {
      final c1 = ClassInfo(
        name: 'Test',
        filePath: 'lib/test.dart',
        lineNumber: 1,
        lineCount: 10,
      );

      final c2 = ClassInfo(
        name: 'Test',
        filePath: 'lib/test.dart',
        lineNumber: 1,
        lineCount: 20,
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
    });
  });
}
