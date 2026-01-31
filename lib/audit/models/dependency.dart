import 'layer.dart';

/// Represents a dependency between source files
class Dependency {
  /// Source file path
  final String sourceFile;
  
  /// Target file path
  final String targetFile;
  
  /// Import path as written in code
  final String importPath;
  
  /// Whether this is a relative import
  final bool isRelative;
  
  /// Layer of the source file
  final Layer? sourceLayer;
  
  /// Layer of the target file
  final Layer? targetLayer;
  
  /// Line number where import appears
  final int lineNumber;
  
  Dependency({
    required this.sourceFile,
    required this.targetFile,
    required this.importPath,
    required this.isRelative,
    this.sourceLayer,
    this.targetLayer,
    required this.lineNumber,
  });
  
  @override
  String toString() =>
      'Dependency($sourceFile -> $targetFile at line $lineNumber)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dependency &&
          runtimeType == other.runtimeType &&
          sourceFile == other.sourceFile &&
          targetFile == other.targetFile &&
          lineNumber == other.lineNumber;
  
  @override
  int get hashCode => Object.hash(sourceFile, targetFile, lineNumber);
}
