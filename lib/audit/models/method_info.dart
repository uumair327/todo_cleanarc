import 'parameter_info.dart';

/// Metadata about a method declaration
class MethodInfo {
  /// Method name
  final String name;
  
  /// Return type
  final String returnType;
  
  /// Method parameters
  final List<ParameterInfo> parameters;
  
  /// Whether the method is async
  final bool isAsync;
  
  /// Whether the method is static
  final bool isStatic;
  
  /// Line number where method is declared
  final int lineNumber;
  
  /// Cyclomatic complexity of the method
  final int complexity;
  
  MethodInfo({
    required this.name,
    required this.returnType,
    List<ParameterInfo>? parameters,
    required this.isAsync,
    required this.isStatic,
    required this.lineNumber,
    this.complexity = 1,
  }) : parameters = parameters ?? [];
  
  @override
  String toString() => 'MethodInfo($name at line $lineNumber)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MethodInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lineNumber == other.lineNumber;
  
  @override
  int get hashCode => Object.hash(name, lineNumber);
}
