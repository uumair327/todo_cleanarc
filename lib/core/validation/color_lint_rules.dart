/// Custom lint rules for detecting hardcoded colors in the codebase
/// 
/// This module provides utilities to scan Dart files for hardcoded color
/// usage and enforce the use of semantic color tokens instead.
library color_lint_rules;

import 'dart:io';
import 'dart:convert';

/// Exception thrown when hardcoded colors are detected
class HardcodedColorException implements Exception {
  final String filePath;
  final int lineNumber;
  final String colorValue;
  final String suggestion;

  const HardcodedColorException({
    required this.filePath,
    required this.lineNumber,
    required this.colorValue,
    required this.suggestion,
  });

  @override
  String toString() {
    return 'HardcodedColorException: Found hardcoded color "$colorValue" at '
        '$filePath:$lineNumber. Suggestion: $suggestion';
  }
}

/// Result of color validation scan
class ColorValidationResult {
  final List<HardcodedColorViolation> violations;
  final int filesScanned;
  final bool isValid;

  const ColorValidationResult({
    required this.violations,
    required this.filesScanned,
  }) : isValid = violations.isEmpty;

  /// Convert to JSON for CI/CD reporting
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'filesScanned': filesScanned,
      'violationCount': violations.length,
      'violations': violations.map((v) => v.toJson()).toList(),
    };
  }
}

/// Individual hardcoded color violation
class HardcodedColorViolation {
  final String filePath;
  final int lineNumber;
  final String line;
  final String colorValue;
  final String suggestion;
  final ColorViolationType type;

  const HardcodedColorViolation({
    required this.filePath,
    required this.lineNumber,
    required this.line,
    required this.colorValue,
    required this.suggestion,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'lineNumber': lineNumber,
      'line': line.trim(),
      'colorValue': colorValue,
      'suggestion': suggestion,
      'type': type.name,
    };
  }

  @override
  String toString() {
    return '$filePath:$lineNumber - $colorValue ($suggestion)';
  }
}

/// Types of color violations
enum ColorViolationType {
  materialColors,    // Colors.red, Colors.blue, etc.
  hexColors,         // Color(0xFF123456)
  rgbColors,         // Color.fromRGBO(255, 0, 0, 1.0)
  argbColors,        // Color.fromARGB(255, 255, 0, 0)
}

/// Main color validation scanner
class ColorLintScanner {
  static const List<String> _excludedPaths = [
    'test/',
    '.dart_tool/',
    'build/',
    '.git/',
    'android/',
    'ios/',
    'linux/',
    'macos/',
    'web/',
    'windows/',
  ];

  static const List<String> _excludedFiles = [
    'app_colors.dart', // Legacy file - allowed during migration
    'color_lint_rules.dart', // This file itself
    'color_token_registry.dart', // Color definitions are allowed here
    'color_storage_impl.dart', // Color definitions are allowed here
  ];

  /// Patterns for detecting hardcoded colors
  static final Map<ColorViolationType, RegExp> _colorPatterns = {
    ColorViolationType.materialColors: RegExp(
      r'Colors\.\w+(?!\s*\.\s*withOpacity\s*\(\s*0\.0\s*\))',
      multiLine: true,
    ),
    ColorViolationType.hexColors: RegExp(
      r'Color\s*\(\s*0x[0-9A-Fa-f]{8}\s*\)',
      multiLine: true,
    ),
    ColorViolationType.rgbColors: RegExp(
      r'Color\.fromRGBO\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*[\d.]+\s*\)',
      multiLine: true,
    ),
    ColorViolationType.argbColors: RegExp(
      r'Color\.fromARGB\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)',
      multiLine: true,
    ),
  };

  /// Suggestions for each violation type
  static const Map<ColorViolationType, String> _suggestions = {
    ColorViolationType.materialColors: 
        'Use context.appColors.semanticColorName or context.colorScheme.colorName',
    ColorViolationType.hexColors: 
        'Define color in ColorTokenRegistry and access via semantic name',
    ColorViolationType.rgbColors: 
        'Define color in ColorTokenRegistry and access via semantic name',
    ColorViolationType.argbColors: 
        'Define color in ColorTokenRegistry and access via semantic name',
  };

  /// Scan all Dart files in the project for hardcoded colors
  static Future<ColorValidationResult> scanProject({
    String rootPath = '.',
    bool includeTests = false,
  }) async {
    final violations = <HardcodedColorViolation>[];
    int filesScanned = 0;

    final dartFiles = await _findDartFiles(rootPath, includeTests);
    
    for (final file in dartFiles) {
      if (_shouldSkipFile(file.path)) continue;
      
      filesScanned++;
      final fileViolations = await _scanFile(file);
      violations.addAll(fileViolations);
    }

    return ColorValidationResult(
      violations: violations,
      filesScanned: filesScanned,
    );
  }

  /// Scan a single file for hardcoded colors
  static Future<List<HardcodedColorViolation>> _scanFile(File file) async {
    final violations = <HardcodedColorViolation>[];
    
    try {
      final lines = await file.readAsLines();
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineNumber = i + 1;
        
        // Skip comments and strings (basic implementation)
        if (_isCommentOrString(line)) continue;
        
        // Check each pattern
        for (final entry in _colorPatterns.entries) {
          final type = entry.key;
          final pattern = entry.value;
          
          final matches = pattern.allMatches(line);
          for (final match in matches) {
            violations.add(HardcodedColorViolation(
              filePath: file.path,
              lineNumber: lineNumber,
              line: line,
              colorValue: match.group(0) ?? '',
              suggestion: _suggestions[type] ?? 'Use semantic color tokens',
              type: type,
            ));
          }
        }
      }
    } catch (e) {
      // Skip files that can't be read
      print('Warning: Could not scan file ${file.path}: $e');
    }
    
    return violations;
  }

  /// Find all Dart files in the project
  static Future<List<File>> _findDartFiles(String rootPath, bool includeTests) async {
    final files = <File>[];
    final directory = Directory(rootPath);
    
    if (!directory.existsSync()) return files;
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        if (!includeTests && entity.path.contains('/test/')) continue;
        files.add(entity);
      }
    }
    
    return files;
  }

  /// Check if a file should be skipped
  static bool _shouldSkipFile(String filePath) {
    // Skip excluded paths
    for (final excludedPath in _excludedPaths) {
      if (filePath.contains(excludedPath)) return true;
    }
    
    // Skip excluded files
    for (final excludedFile in _excludedFiles) {
      if (filePath.endsWith(excludedFile)) return true;
    }
    
    return false;
  }

  /// Basic check for comments and strings (simplified)
  static bool _isCommentOrString(String line) {
    final trimmed = line.trim();
    return trimmed.startsWith('//') || 
           trimmed.startsWith('/*') || 
           trimmed.startsWith('*') ||
           trimmed.startsWith('///');
  }

  /// Generate a detailed report
  static String generateReport(ColorValidationResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('Color Validation Report');
    buffer.writeln('======================');
    buffer.writeln('Files scanned: ${result.filesScanned}');
    buffer.writeln('Violations found: ${result.violations.length}');
    buffer.writeln('Status: ${result.isValid ? "PASS" : "FAIL"}');
    buffer.writeln();
    
    if (result.violations.isNotEmpty) {
      buffer.writeln('Violations:');
      buffer.writeln('-----------');
      
      // Group by file
      final violationsByFile = <String, List<HardcodedColorViolation>>{};
      for (final violation in result.violations) {
        violationsByFile.putIfAbsent(violation.filePath, () => []).add(violation);
      }
      
      for (final entry in violationsByFile.entries) {
        buffer.writeln('\n${entry.key}:');
        for (final violation in entry.value) {
          buffer.writeln('  Line ${violation.lineNumber}: ${violation.colorValue}');
          buffer.writeln('    Suggestion: ${violation.suggestion}');
        }
      }
    }
    
    return buffer.toString();
  }
}