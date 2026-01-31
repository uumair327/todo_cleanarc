/// Metadata about a method parameter
class ParameterInfo {
  /// Parameter name
  final String name;
  
  /// Parameter type
  final String type;
  
  /// Whether the parameter is required
  final bool isRequired;
  
  /// Whether the parameter is named
  final bool isNamed;
  
  /// Default value (if any)
  final String? defaultValue;
  
  ParameterInfo({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.isNamed,
    this.defaultValue,
  });
  
  @override
  String toString() => 'ParameterInfo($type $name)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;
  
  @override
  int get hashCode => Object.hash(name, type);
}
