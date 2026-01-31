/// Metadata about a field declaration
class FieldInfo {
  /// Field name
  final String name;
  
  /// Field type
  final String type;
  
  /// Whether the field is static
  final bool isStatic;
  
  /// Whether the field is final
  final bool isFinal;
  
  /// Whether the field is const
  final bool isConst;
  
  /// Line number where field is declared
  final int lineNumber;
  
  FieldInfo({
    required this.name,
    required this.type,
    required this.isStatic,
    required this.isFinal,
    required this.isConst,
    required this.lineNumber,
  });
  
  @override
  String toString() => 'FieldInfo($type $name at line $lineNumber)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lineNumber == other.lineNumber;
  
  @override
  int get hashCode => Object.hash(name, lineNumber);
}
