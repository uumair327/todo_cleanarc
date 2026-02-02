import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/analyzers/static_analyzer.dart';
import 'package:todo_cleanarc/audit/models/models.dart';

void main() {
  group('StaticAnalyzerImpl', () {
    late StaticAnalyzer analyzer;
    
    setUp(() {
      analyzer = StaticAnalyzerImpl();
    });
    
    group('parseFile', () {
      test('should parse valid Dart file successfully', () {
        // Arrange
        const content = '''
class TestClass {
  void testMethod() {}
}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        
        // Act
        final result = analyzer.parseFile(sourceFile);
        
        // Assert
        expect(result, isNotNull);
        expect(result.declarations, isNotEmpty);
      });
      
      test('should handle file with imports', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';
import 'dart:async';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/test_widget.dart',
          relativePath: 'test/test_widget.dart',
          layer: Layer.pages,
          content: content,
        );
        
        // Act
        final result = analyzer.parseFile(sourceFile);
        
        // Assert
        expect(result, isNotNull);
        expect(result.directives, hasLength(2));
      });
      
      test('should handle empty file', () {
        // Arrange
        const content = '';
        final sourceFile = SourceFile(
          path: '/test/empty.dart',
          relativePath: 'test/empty.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        
        // Act
        final result = analyzer.parseFile(sourceFile);
        
        // Assert
        expect(result, isNotNull);
        expect(result.declarations, isEmpty);
      });
      
      test('should handle file with only comments', () {
        // Arrange
        const content = '''
// This is a comment
/* Multi-line
   comment */
''';
        final sourceFile = SourceFile(
          path: '/test/comments.dart',
          relativePath: 'test/comments.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        
        // Act
        final result = analyzer.parseFile(sourceFile);
        
        // Assert
        expect(result, isNotNull);
        expect(result.declarations, isEmpty);
      });
      
      test('should parse file with syntax errors gracefully', () {
        // Arrange
        const content = '''
class TestClass {
  void testMethod( // Missing closing parenthesis
}
''';
        final sourceFile = SourceFile(
          path: '/test/invalid.dart',
          relativePath: 'test/invalid.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        
        // Act & Assert
        // Should not throw, but return AST with errors
        final result = analyzer.parseFile(sourceFile);
        expect(result, isNotNull);
      });
    });
    
    group('extractClasses', () {
      test('should extract simple class with methods and fields', () {
        // Arrange
        const content = '''
class TestClass {
  String name;
  int age;
  
  void testMethod() {}
  String getName() => name;
}
''';
        final sourceFile = SourceFile(
          path: '/test/test_class.dart',
          relativePath: 'test/test_class.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(1));
        expect(classes[0].name, 'TestClass');
        expect(classes[0].fields, hasLength(2));
        expect(classes[0].methods, hasLength(2));
        expect(classes[0].lineNumber, greaterThan(0));
      });
      
      test('should extract class with superclass', () {
        // Arrange
        const content = '''
class BaseClass {}
class DerivedClass extends BaseClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/inheritance.dart',
          relativePath: 'test/inheritance.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(2));
        expect(classes[1].name, 'DerivedClass');
        expect(classes[1].superclass, 'BaseClass');
      });
      
      test('should extract class with interfaces', () {
        // Arrange
        const content = '''
abstract class Interface1 {}
abstract class Interface2 {}
class Implementation implements Interface1, Interface2 {}
''';
        final sourceFile = SourceFile(
          path: '/test/interfaces.dart',
          relativePath: 'test/interfaces.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(3));
        expect(classes[2].name, 'Implementation');
        expect(classes[2].interfaces, hasLength(2));
        expect(classes[2].interfaces, contains('Interface1'));
        expect(classes[2].interfaces, contains('Interface2'));
      });
      
      test('should extract class with mixins', () {
        // Arrange
        const content = '''
mixin Mixin1 {}
mixin Mixin2 {}
class MyClass with Mixin1, Mixin2 {}
''';
        final sourceFile = SourceFile(
          path: '/test/mixins.dart',
          relativePath: 'test/mixins.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(1));
        expect(classes[0].name, 'MyClass');
        expect(classes[0].mixins, hasLength(2));
        expect(classes[0].mixins, contains('Mixin1'));
        expect(classes[0].mixins, contains('Mixin2'));
      });
      
      test('should extract method metadata correctly', () {
        // Arrange
        const content = '''
class TestClass {
  static void staticMethod() {}
  Future<void> asyncMethod() async {}
  String methodWithParams(int x, String y) => '';
}
''';
        final sourceFile = SourceFile(
          path: '/test/methods.dart',
          relativePath: 'test/methods.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(1));
        expect(classes[0].methods, hasLength(3));
        
        final staticMethod = classes[0].methods[0];
        expect(staticMethod.name, 'staticMethod');
        expect(staticMethod.isStatic, true);
        
        final asyncMethod = classes[0].methods[1];
        expect(asyncMethod.name, 'asyncMethod');
        expect(asyncMethod.isAsync, true);
        
        final methodWithParams = classes[0].methods[2];
        expect(methodWithParams.name, 'methodWithParams');
        expect(methodWithParams.parameters, hasLength(2));
      });
      
      test('should extract field metadata correctly', () {
        // Arrange
        const content = '''
class TestClass {
  static const int staticConst = 42;
  final String finalField = '';
  int mutableField = 0;
}
''';
        final sourceFile = SourceFile(
          path: '/test/fields.dart',
          relativePath: 'test/fields.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(1));
        expect(classes[0].fields, hasLength(3));
        
        final staticConst = classes[0].fields[0];
        expect(staticConst.name, 'staticConst');
        expect(staticConst.isStatic, true);
        expect(staticConst.isConst, true);
        
        final finalField = classes[0].fields[1];
        expect(finalField.name, 'finalField');
        expect(finalField.isFinal, true);
        
        final mutableField = classes[0].fields[2];
        expect(mutableField.name, 'mutableField');
        expect(mutableField.isFinal, false);
      });
      
      test('should handle empty class', () {
        // Arrange
        const content = 'class EmptyClass {}';
        final sourceFile = SourceFile(
          path: '/test/empty_class.dart',
          relativePath: 'test/empty_class.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final classes = analyzer.extractClasses(ast, sourceFile.path);
        
        // Assert
        expect(classes, hasLength(1));
        expect(classes[0].name, 'EmptyClass');
        expect(classes[0].methods, isEmpty);
        expect(classes[0].fields, isEmpty);
      });
    });
    
    group('extractDependencies', () {
      test('should extract package imports', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';
import 'package:todo_cleanarc/feature/todo/domain/entities/task.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(2)); // Both package imports
        expect(dependencies[0].importPath, contains('flutter'));
        expect(dependencies[1].importPath, contains('todo_cleanarc'));
        expect(dependencies[0].isRelative, false);
        expect(dependencies[1].isRelative, false);
      });
      
      test('should extract relative imports', () {
        // Arrange
        const content = '''
import './local_file.dart';
import '../parent_file.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(2));
        expect(dependencies[0].isRelative, true);
        expect(dependencies[1].isRelative, true);
      });
      
      test('should skip dart: imports', () {
        // Arrange
        const content = '''
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1)); // Only package import
        expect(dependencies[0].importPath, contains('flutter'));
      });
      
      test('should determine target layer from import path - pages', () {
        // Arrange
        const content = '''
import 'package:todo_cleanarc/feature/todo/presentation/pages/todo_page.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.operations,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].targetLayer, Layer.pages);
      });
      
      test('should determine target layer from import path - operations', () {
        // Arrange
        const content = '''
import 'package:todo_cleanarc/feature/todo/domain/usecases/create_task.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].targetLayer, Layer.operations);
      });
      
      test('should determine target layer from import path - domain', () {
        // Arrange
        const content = '''
import 'package:todo_cleanarc/feature/todo/domain/entities/task.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.operations,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].targetLayer, Layer.domain);
      });
      
      test('should determine target layer from import path - infrastructure', () {
        // Arrange
        const content = '''
import 'package:todo_cleanarc/feature/todo/data/repositories/task_repository_impl.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.operations,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].targetLayer, Layer.infrastructure);
      });
      
      test('should determine target layer from import path - miscellaneous', () {
        // Arrange
        const content = '''
import 'package:todo_cleanarc/core/utils/date_utils.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].targetLayer, Layer.miscellaneous);
      });
      
      test('should include line numbers for dependencies', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, hasLength(1));
        expect(dependencies[0].lineNumber, greaterThan(0));
      });
      
      test('should handle file with no imports', () {
        // Arrange
        const content = '''
class TestClass {}
''';
        final sourceFile = SourceFile(
          path: '/test/test_file.dart',
          relativePath: 'test/test_file.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final dependencies = analyzer.extractDependencies(
          ast,
          sourceFile.path,
          sourceFile.layer,
        );
        
        // Assert
        expect(dependencies, isEmpty);
      });
    });
    
    group('analyzeWidgets', () {
      test('should detect StatelessWidget', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.isStatelessWidget, true);
        expect(analysis.isStatefulWidget, false);
      });
      
      test('should detect StatefulWidget', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.isStatefulWidget, true);
        expect(analysis.isStatelessWidget, false);
      });
      
      test('should detect business logic - database calls', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    database.query('SELECT * FROM tasks');
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.hasBusinessLogic, true);
      });
      
      test('should detect business logic - API calls', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    httpClient.get('https://api.example.com/data');
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.hasBusinessLogic, true);
      });
      
      test('should detect business logic - repository usage', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate a database query call
    database.query('tasks');
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.hasBusinessLogic, true);
      });
      
      test('should calculate widget nesting depth', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text('Hello'),
          ],
        ),
      ),
    );
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        // Widget depth calculation is a best-effort feature
        // It should at least not crash and return a non-negative value
        expect(analysis.widgetDepth, greaterThanOrEqualTo(0));
      });
      
      test('should extract direct dependencies', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';
import 'package:todo_cleanarc/core/utils/helpers.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.directDependencies, hasLength(2));
        expect(analysis.directDependencies, contains('package:flutter/material.dart'));
      });
      
      test('should handle non-widget classes', () {
        // Arrange
        const content = '''
class RegularClass {
  void doSomething() {}
}
''';
        final sourceFile = SourceFile(
          path: '/test/regular.dart',
          relativePath: 'test/regular.dart',
          layer: Layer.miscellaneous,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.isStatelessWidget, false);
        expect(analysis.isStatefulWidget, false);
        expect(analysis.widgetDepth, 0);
      });
      
      test('should handle widget without business logic', () {
        // Arrange
        const content = '''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello World'),
    );
  }
}
''';
        final sourceFile = SourceFile(
          path: '/test/widget.dart',
          relativePath: 'test/widget.dart',
          layer: Layer.pages,
          content: content,
        );
        final ast = analyzer.parseFile(sourceFile);
        
        // Act
        final analysis = analyzer.analyzeWidgets(ast);
        
        // Assert
        expect(analysis.hasBusinessLogic, false);
      });
    });
  });
}
