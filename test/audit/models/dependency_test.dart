import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/dependency.dart';
import 'package:todo_cleanarc/audit/models/layer.dart';

void main() {
  group('Dependency', () {
    test('should create instance with required fields', () {
      final dependency = Dependency(
        sourceFile: 'lib/pages/home.dart',
        targetFile: 'lib/domain/usecases/get_tasks.dart',
        importPath: '../domain/usecases/get_tasks.dart',
        isRelative: true,
        lineNumber: 5,
      );

      expect(dependency.sourceFile, 'lib/pages/home.dart');
      expect(dependency.targetFile, 'lib/domain/usecases/get_tasks.dart');
      expect(dependency.importPath, '../domain/usecases/get_tasks.dart');
      expect(dependency.isRelative, true);
      expect(dependency.lineNumber, 5);
      expect(dependency.sourceLayer, isNull);
      expect(dependency.targetLayer, isNull);
    });

    test('should create instance with layer information', () {
      final dependency = Dependency(
        sourceFile: 'lib/pages/home.dart',
        targetFile: 'lib/domain/usecases/get_tasks.dart',
        importPath: 'package:todo_cleanarc/domain/usecases/get_tasks.dart',
        isRelative: false,
        sourceLayer: Layer.pages,
        targetLayer: Layer.operations,
        lineNumber: 5,
      );

      expect(dependency.sourceLayer, Layer.pages);
      expect(dependency.targetLayer, Layer.operations);
      expect(dependency.isRelative, false);
    });

    test('should support equality comparison', () {
      final d1 = Dependency(
        sourceFile: 'lib/a.dart',
        targetFile: 'lib/b.dart',
        importPath: 'b.dart',
        isRelative: true,
        lineNumber: 1,
      );

      final d2 = Dependency(
        sourceFile: 'lib/a.dart',
        targetFile: 'lib/b.dart',
        importPath: 'different.dart',
        isRelative: false,
        lineNumber: 1,
      );

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
    });
  });
}
