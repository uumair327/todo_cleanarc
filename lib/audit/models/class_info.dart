import 'method_info.dart';
import 'field_info.dart';

/// Metadata about a class declaration
class ClassInfo {
  /// Class name
  final String name;
  
  /// File path where the class is defined
  final String filePath;
  
  /// Superclass name (if any)
  final String? superclass;
  
  /// Implemented interfaces
  final List<String> interfaces;
  
  /// Applied mixins
  final List<String> mixins;
  
  /// Methods in the class
  final List<MethodInfo> methods;
  
  /// Fields in the class
  final List<FieldInfo> fields;
  
  /// Line number where class is declared
  final int lineNumber;
  
  /// Total lines of code in the class
  final int lineCount;
  
  ClassInfo({
    required this.name,
    required this.filePath,
    this.superclass,
    List<String>? interfaces,
    List<String>? mixins,
    List<MethodInfo>? methods,
    List<FieldInfo>? fields,
    required this.lineNumber,
    required this.lineCount,
  })  : interfaces = interfaces ?? [],
        mixins = mixins ?? [],
        methods = methods ?? [],
        fields = fields ?? [];
  
  @override
  String toString() => 'ClassInfo($name at $filePath:$lineNumber)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          filePath == other.filePath &&
          lineNumber == other.lineNumber;
  
  @override
  int get hashCode => Object.hash(name, filePath, lineNumber);
}
