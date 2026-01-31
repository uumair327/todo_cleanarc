import 'severity.dart';

/// Represents an architectural violation
class Violation {
  /// Unique identifier for this violation instance
  final String id;
  
  /// Rule identifier that detected this violation
  final String ruleId;
  
  /// Human-readable rule name
  final String ruleName;
  
  /// Severity level of the violation
  final Severity severity;
  
  /// File path where violation occurs
  final String file;
  
  /// Line number where violation occurs
  final int lineNumber;
  
  /// Description of the violation
  final String message;
  
  /// Actionable recommendation to fix the violation
  final String recommendation;
  
  /// Additional metadata about the violation
  final Map<String, dynamic> metadata;
  
  Violation({
    required this.id,
    required this.ruleId,
    required this.ruleName,
    required this.severity,
    required this.file,
    required this.lineNumber,
    required this.message,
    required this.recommendation,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};
  
  @override
  String toString() =>
      'Violation($ruleName at $file:$lineNumber - $severity)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Violation &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  /// Creates a copy of this violation with updated fields
  Violation copyWith({
    String? id,
    String? ruleId,
    String? ruleName,
    Severity? severity,
    String? file,
    int? lineNumber,
    String? message,
    String? recommendation,
    Map<String, dynamic>? metadata,
  }) {
    return Violation(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      severity: severity ?? this.severity,
      file: file ?? this.file,
      lineNumber: lineNumber ?? this.lineNumber,
      message: message ?? this.message,
      recommendation: recommendation ?? this.recommendation,
      metadata: metadata ?? this.metadata,
    );
  }
}
