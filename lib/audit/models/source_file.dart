import 'package:analyzer/dart/ast/ast.dart';
import 'layer.dart';

/// Represents a source file in the codebase
class SourceFile {
  /// Absolute path to the file
  final String path;
  
  /// Path relative to project root
  final String relativePath;
  
  /// Architectural layer this file belongs to
  final Layer layer;
  
  /// Feature module name (if applicable)
  final String? feature;
  
  /// File content
  final String content;
  
  /// Parsed AST (lazy-loaded)
  CompilationUnit? _ast;
  
  SourceFile({
    required this.path,
    required this.relativePath,
    required this.layer,
    this.feature,
    required this.content,
    CompilationUnit? ast,
  }) : _ast = ast;
  
  /// Gets the parsed AST for this file
  CompilationUnit? get ast => _ast;
  
  /// Sets the parsed AST for this file
  set ast(CompilationUnit? value) => _ast = value;
  
  @override
  String toString() => 'SourceFile($relativePath, $layer, feature: $feature)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceFile &&
          runtimeType == other.runtimeType &&
          path == other.path;
  
  @override
  int get hashCode => path.hashCode;
}
