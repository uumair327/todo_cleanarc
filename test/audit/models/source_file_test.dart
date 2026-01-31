import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/source_file.dart';
import 'package:todo_cleanarc/audit/models/layer.dart';

void main() {
  group('SourceFile', () {
    test('should create instance with required fields', () {
      final sourceFile = SourceFile(
        path: '/project/lib/feature/auth/presentation/pages/login_page.dart',
        relativePath: 'lib/feature/auth/presentation/pages/login_page.dart',
        layer: Layer.pages,
        content: 'class LoginPage {}',
      );

      expect(sourceFile.path, '/project/lib/feature/auth/presentation/pages/login_page.dart');
      expect(sourceFile.relativePath, 'lib/feature/auth/presentation/pages/login_page.dart');
      expect(sourceFile.layer, Layer.pages);
      expect(sourceFile.content, 'class LoginPage {}');
      expect(sourceFile.feature, isNull);
      expect(sourceFile.ast, isNull);
    });

    test('should create instance with optional feature', () {
      final sourceFile = SourceFile(
        path: '/project/lib/feature/auth/domain/usecases/login.dart',
        relativePath: 'lib/feature/auth/domain/usecases/login.dart',
        layer: Layer.operations,
        feature: 'auth',
        content: 'class Login {}',
      );

      expect(sourceFile.feature, 'auth');
    });

    test('should support equality comparison', () {
      final file1 = SourceFile(
        path: '/project/lib/test.dart',
        relativePath: 'lib/test.dart',
        layer: Layer.pages,
        content: 'test',
      );

      final file2 = SourceFile(
        path: '/project/lib/test.dart',
        relativePath: 'lib/test.dart',
        layer: Layer.operations,
        content: 'different',
      );

      expect(file1, equals(file2)); // Same path means equal
      expect(file1.hashCode, equals(file2.hashCode));
    });

    test('should have meaningful toString', () {
      final sourceFile = SourceFile(
        path: '/project/lib/test.dart',
        relativePath: 'lib/test.dart',
        layer: Layer.pages,
        feature: 'auth',
        content: 'test',
      );

      expect(sourceFile.toString(), contains('lib/test.dart'));
      expect(sourceFile.toString(), contains('pages'));
      expect(sourceFile.toString(), contains('auth'));
    });
  });
}
