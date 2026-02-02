import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../models/models.dart';

/// Interface for static code analysis
abstract class StaticAnalyzer {
  /// Parses a source file into an AST
  CompilationUnit parseFile(SourceFile file);
  
  /// Extracts class declarations from AST
  List<ClassInfo> extractClasses(CompilationUnit ast, String filePath);
  
  /// Extracts import statements and dependencies
  List<Dependency> extractDependencies(
    CompilationUnit ast,
    String sourceFilePath,
    Layer? sourceLayer,
  );
  
  /// Identifies widget types and composition
  WidgetAnalysis analyzeWidgets(CompilationUnit ast);
}

/// Implementation of static code analyzer
class StaticAnalyzerImpl implements StaticAnalyzer {
  @override
  CompilationUnit parseFile(SourceFile file) {
    try {
      final parseResult = parseString(
        content: file.content,
        path: file.path,
        featureSet: FeatureSet.latestLanguageVersion(),
        throwIfDiagnostics: false,
      );
      
      return parseResult.unit;
    } catch (e) {
      // Handle parsing errors gracefully
      throw ParsingException(
        'Failed to parse file ${file.relativePath}: $e',
        file.path,
      );
    }
  }
  
  @override
  List<ClassInfo> extractClasses(CompilationUnit ast, String filePath) {
    final classes = <ClassInfo>[];
    
    for (final declaration in ast.declarations) {
      if (declaration is ClassDeclaration) {
        classes.add(_extractClassInfo(declaration, filePath, ast));
      }
    }
    
    return classes;
  }
  
  ClassInfo _extractClassInfo(
    ClassDeclaration classDecl,
    String filePath,
    CompilationUnit ast,
  ) {
    // Extract superclass
    final superclass = classDecl.extendsClause?.superclass.name2.toString();
    
    // Extract interfaces
    final interfaces = classDecl.implementsClause?.interfaces
        .map((interface) => interface.name2.toString())
        .toList() ?? [];
    
    // Extract mixins
    final mixins = classDecl.withClause?.mixinTypes
        .map((mixin) => mixin.name2.toString())
        .toList() ?? [];
    
    // Extract methods
    final methods = <MethodInfo>[];
    for (final member in classDecl.members) {
      if (member is MethodDeclaration) {
        methods.add(_extractMethodInfo(member, ast));
      }
    }
    
    // Extract fields
    final fields = <FieldInfo>[];
    for (final member in classDecl.members) {
      if (member is FieldDeclaration) {
        fields.addAll(_extractFieldInfo(member, ast));
      }
    }
    
    // Calculate line count
    final lineNumber = ast.lineInfo.getLocation(classDecl.offset).lineNumber;
    final endLine = ast.lineInfo.getLocation(classDecl.end).lineNumber;
    final lineCount = endLine - lineNumber + 1;
    
    return ClassInfo(
      name: classDecl.name.lexeme,
      filePath: filePath,
      superclass: superclass,
      interfaces: interfaces,
      mixins: mixins,
      methods: methods,
      fields: fields,
      lineNumber: lineNumber,
      lineCount: lineCount,
    );
  }
  
  MethodInfo _extractMethodInfo(MethodDeclaration method, CompilationUnit ast) {
    final lineNumber = ast.lineInfo.getLocation(method.offset).lineNumber;
    
    // Extract parameters
    final parameters = <ParameterInfo>[];
    if (method.parameters != null) {
      for (final param in method.parameters!.parameters) {
        parameters.add(_extractParameterInfo(param));
      }
    }
    
    return MethodInfo(
      name: method.name.lexeme,
      returnType: method.returnType?.toString() ?? 'dynamic',
      parameters: parameters,
      isAsync: method.body is BlockFunctionBody && 
               (method.body as BlockFunctionBody).keyword?.lexeme == 'async',
      isStatic: method.isStatic,
      lineNumber: lineNumber,
      complexity: 1, // Basic complexity, can be enhanced later
    );
  }
  
  ParameterInfo _extractParameterInfo(FormalParameter param) {
    String name = '';
    String type = 'dynamic';
    bool isRequired = false;
    bool isNamed = false;
    String? defaultValue;
    
    if (param is SimpleFormalParameter) {
      name = param.name?.lexeme ?? '';
      type = param.type?.toString() ?? 'dynamic';
      isRequired = param.isRequired;
      isNamed = param.isNamed;
    } else if (param is DefaultFormalParameter) {
      final innerParam = param.parameter;
      if (innerParam is SimpleFormalParameter) {
        name = innerParam.name?.lexeme ?? '';
        type = innerParam.type?.toString() ?? 'dynamic';
      }
      isRequired = param.isRequired;
      isNamed = param.isNamed;
      defaultValue = param.defaultValue?.toString();
    } else if (param is FieldFormalParameter) {
      name = param.name.lexeme;
      type = param.type?.toString() ?? 'dynamic';
      isRequired = param.isRequired;
      isNamed = param.isNamed;
    }
    
    return ParameterInfo(
      name: name,
      type: type,
      isRequired: isRequired,
      isNamed: isNamed,
      defaultValue: defaultValue,
    );
  }
  
  List<FieldInfo> _extractFieldInfo(FieldDeclaration field, CompilationUnit ast) {
    final fields = <FieldInfo>[];
    final lineNumber = ast.lineInfo.getLocation(field.offset).lineNumber;
    
    for (final variable in field.fields.variables) {
      fields.add(FieldInfo(
        name: variable.name.lexeme,
        type: field.fields.type?.toString() ?? 'dynamic',
        isStatic: field.isStatic,
        isFinal: field.fields.isFinal,
        isConst: field.fields.isConst,
        lineNumber: lineNumber,
      ));
    }
    
    return fields;
  }
  
  @override
  List<Dependency> extractDependencies(
    CompilationUnit ast,
    String sourceFilePath,
    Layer? sourceLayer,
  ) {
    final dependencies = <Dependency>[];
    
    for (final directive in ast.directives) {
      if (directive is ImportDirective) {
        final importPath = directive.uri.stringValue ?? '';
        final lineNumber = ast.lineInfo.getLocation(directive.offset).lineNumber;
        
        // Skip dart: imports as they're not architectural dependencies
        if (importPath.startsWith('dart:')) {
          continue;
        }
        
        // Determine if it's a relative import
        final isRelative = importPath.startsWith('.') || 
                          importPath.startsWith('../');
        
        // Determine target layer from import path
        final targetLayer = _determineLayerFromImport(importPath);
        
        // For now, use import path as target file (will be resolved later)
        dependencies.add(Dependency(
          sourceFile: sourceFilePath,
          targetFile: importPath,
          importPath: importPath,
          isRelative: isRelative,
          sourceLayer: sourceLayer,
          targetLayer: targetLayer,
          lineNumber: lineNumber,
        ));
      }
    }
    
    return dependencies;
  }
  
  Layer? _determineLayerFromImport(String importPath) {
    // Check for presentation/pages layer
    if (importPath.contains('/presentation/pages/') ||
        importPath.contains('/presentation/screens/')) {
      return Layer.pages;
    }
    
    // Check for operations/use cases layer
    if (importPath.contains('/domain/usecases/') ||
        importPath.contains('/domain/operations/')) {
      return Layer.operations;
    }
    
    // Check for domain layer
    if (importPath.contains('/domain/')) {
      return Layer.domain;
    }
    
    // Check for infrastructure layer
    if (importPath.contains('/infrastructure/') ||
        importPath.contains('/data/')) {
      return Layer.infrastructure;
    }
    
    // Check for miscellaneous components
    if (importPath.contains('/utils/') ||
        importPath.contains('/helpers/') ||
        importPath.contains('/constants/')) {
      return Layer.miscellaneous;
    }
    
    return null;
  }
  
  @override
  WidgetAnalysis analyzeWidgets(CompilationUnit ast) {
    bool isStatelessWidget = false;
    bool isStatefulWidget = false;
    bool hasBusinessLogic = false;
    final directDependencies = <String>[];
    int widgetDepth = 0;
    
    // Check for widget classes
    for (final declaration in ast.declarations) {
      if (declaration is ClassDeclaration) {
        final superclass = declaration.extendsClause?.superclass.name2.toString();
        
        if (superclass == 'StatelessWidget') {
          isStatelessWidget = true;
        } else if (superclass == 'StatefulWidget') {
          isStatefulWidget = true;
        }
        
        // Check for business logic patterns
        hasBusinessLogic = _hasBusinessLogicPatterns(declaration);
        
        // Calculate widget nesting depth
        final depth = _calculateWidgetDepth(declaration);
        if (depth > widgetDepth) {
          widgetDepth = depth;
        }
      }
    }
    
    // Extract direct dependencies from imports
    for (final directive in ast.directives) {
      if (directive is ImportDirective) {
        final importPath = directive.uri.stringValue ?? '';
        if (importPath.isNotEmpty) {
          directDependencies.add(importPath);
        }
      }
    }
    
    return WidgetAnalysis(
      isStatelessWidget: isStatelessWidget,
      isStatefulWidget: isStatefulWidget,
      hasBusinessLogic: hasBusinessLogic,
      directDependencies: directDependencies,
      widgetDepth: widgetDepth,
    );
  }
  
  bool _hasBusinessLogicPatterns(ClassDeclaration classDecl) {
    // Only check widget classes for business logic
    final superclass = classDecl.extendsClause?.superclass.name2.toString();
    if (superclass != 'StatelessWidget' && superclass != 'StatefulWidget') {
      return false;
    }
    
    // Check for business logic indicators in the class
    final visitor = _BusinessLogicVisitor();
    classDecl.visitChildren(visitor);
    return visitor.hasBusinessLogic;
  }
  
  int _calculateWidgetDepth(ClassDeclaration classDecl) {
    // Find the build method and calculate nesting depth
    for (final member in classDecl.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        final visitor = _WidgetDepthVisitor();
        member.body.visitChildren(visitor);
        return visitor.maxDepth;
      }
    }
    return 0;
  }
}

/// Visitor to detect business logic patterns
class _BusinessLogicVisitor extends GeneralizingAstVisitor<void> {
  bool hasBusinessLogic = false;
  
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    
    // Check for database calls
    if (methodName.contains('query') ||
        methodName.contains('insert') ||
        methodName.contains('update') ||
        methodName.contains('delete') ||
        methodName.contains('execute')) {
      hasBusinessLogic = true;
    }
    
    // Check for HTTP/API calls
    if (methodName == 'get' ||
        methodName == 'post' ||
        methodName == 'put' ||
        methodName == 'patch' ||
        methodName == 'fetch') {
      // Check if it's from an HTTP client
      final target = node.target?.toString() ?? '';
      if (target.toLowerCase().contains('http') || 
          target.toLowerCase().contains('client') ||
          target.toLowerCase().contains('api')) {
        hasBusinessLogic = true;
      }
    }
    
    super.visitMethodInvocation(node);
  }
  
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.toString();
    
    // Check for direct repository or service instantiation
    final lowerTypeName = typeName.toLowerCase();
    if (lowerTypeName.contains('repository') ||
        lowerTypeName.contains('service') ||
        lowerTypeName.contains('datasource')) {
      hasBusinessLogic = true;
    }
    
    super.visitInstanceCreationExpression(node);
  }
  
  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // Check variable initializers for business logic
    if (node.initializer != null) {
      node.initializer!.visitChildren(this);
    }
    super.visitVariableDeclaration(node);
  }
  
  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // Visit field declarations to catch field initializers
    super.visitFieldDeclaration(node);
  }
}

/// Visitor to calculate widget nesting depth
class _WidgetDepthVisitor extends GeneralizingAstVisitor<void> {
  int maxDepth = 0;
  int currentDepth = 0;
  
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.toString();
    
    // Check if it's a widget (common Flutter widgets)
    if (_isWidgetType(typeName)) {
      currentDepth++;
      if (currentDepth > maxDepth) {
        maxDepth = currentDepth;
      }
      
      super.visitInstanceCreationExpression(node);
      
      currentDepth--;
    } else {
      super.visitInstanceCreationExpression(node);
    }
  }
  
  bool _isWidgetType(String typeName) {
    // Common Flutter widgets - check if the type name matches
    const widgetTypes = [
      'Container', 'Column', 'Row', 'Stack', 'Scaffold', 'AppBar',
      'Text', 'Button', 'IconButton', 'FloatingActionButton',
      'ListView', 'GridView', 'Card', 'Padding', 'Center',
      'Align', 'SizedBox', 'Expanded', 'Flexible', 'Wrap',
      'Material', 'InkWell', 'GestureDetector', 'SingleChildScrollView',
    ];
    
    return widgetTypes.contains(typeName);
  }
}

/// Exception thrown when parsing fails
class ParsingException implements Exception {
  final String message;
  final String filePath;
  
  ParsingException(this.message, this.filePath);
  
  @override
  String toString() => 'ParsingException: $message';
}

/// Analysis results for widget composition
class WidgetAnalysis {
  final bool isStatelessWidget;
  final bool isStatefulWidget;
  final bool hasBusinessLogic;
  final List<String> directDependencies;
  final int widgetDepth;
  
  WidgetAnalysis({
    required this.isStatelessWidget,
    required this.isStatefulWidget,
    required this.hasBusinessLogic,
    required this.directDependencies,
    required this.widgetDepth,
  });
  
  @override
  String toString() => 'WidgetAnalysis('
      'stateless: $isStatelessWidget, '
      'stateful: $isStatefulWidget, '
      'hasBusinessLogic: $hasBusinessLogic, '
      'depth: $widgetDepth)';
}
