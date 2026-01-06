/// Build-time color validation integration
/// 
/// This module provides integration with the Dart build system to run
/// color validation as part of the build process.

import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'color_lint_rules.dart';

/// Builder for color validation during build process
class ColorValidationBuilder implements Builder {
  static const String _outputExtension = '.color_validation';
  
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': [_outputExtension],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only run validation on the main library entry point
    if (buildStep.inputId.path != 'lib/\$lib\$') {
      return;
    }

    log.info('Running color validation...');
    
    try {
      final result = await ColorLintScanner.scanProject(
        rootPath: '.',
        includeTests: false,
      );
      
      if (!result.isValid) {
        final report = ColorLintScanner.generateReport(result);
        
        // Write detailed report to build output
        final outputId = buildStep.inputId.changeExtension(_outputExtension);
        await buildStep.writeAsString(outputId, report);
        
        // Log violations
        log.severe('Color validation failed with ${result.violations.length} violations:');
        for (final violation in result.violations.take(5)) { // Show first 5
          log.severe('  ${violation.filePath}:${violation.lineNumber} - ${violation.colorValue}');
        }
        
        if (result.violations.length > 5) {
          log.severe('  ... and ${result.violations.length - 5} more violations');
        }
        
        // Fail the build
        throw BuildException('Color validation failed. Found ${result.violations.length} hardcoded colors.');
      } else {
        log.info('Color validation passed (${result.filesScanned} files scanned)');
        
        // Write success report
        final outputId = buildStep.inputId.changeExtension(_outputExtension);
        await buildStep.writeAsString(outputId, 'Color validation passed');
      }
      
    } catch (e) {
      if (e is BuildException) {
        rethrow;
      }
      
      log.severe('Error during color validation: $e');
      throw BuildException('Color validation error: $e');
    }
  }
}

/// Builder factory for color validation
Builder colorValidationBuilder(BuilderOptions options) {
  return ColorValidationBuilder();
}

/// Exception thrown when build should fail due to color violations
class BuildException implements Exception {
  final String message;
  
  const BuildException(this.message);
  
  @override
  String toString() => 'BuildException: $message';
}