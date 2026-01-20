#!/usr/bin/env dart

/// Build-time color validation script
/// 
/// This script scans the codebase for hardcoded colors and fails the build
/// if any violations are found. It can be integrated into CI/CD pipelines
/// and pre-commit hooks.

import 'dart:io';
import 'dart:convert';
import '../lib/core/validation/color_lint_rules.dart';

/// Command line arguments
class ValidationArgs {
  final bool includeTests;
  final bool jsonOutput;
  final bool failOnViolations;
  final String? outputFile;
  final String rootPath;

  const ValidationArgs({
    this.includeTests = false,
    this.jsonOutput = false,
    this.failOnViolations = true,
    this.outputFile,
    this.rootPath = '.',
  });

  static ValidationArgs fromArgs(List<String> args) {
    bool includeTests = false;
    bool jsonOutput = false;
    bool failOnViolations = true;
    String? outputFile;
    String rootPath = '.';

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--include-tests':
          includeTests = true;
          break;
        case '--json':
          jsonOutput = true;
          break;
        case '--no-fail':
          failOnViolations = false;
          break;
        case '--output':
          if (i + 1 < args.length) {
            outputFile = args[++i];
          }
          break;
        case '--root':
          if (i + 1 < args.length) {
            rootPath = args[++i];
          }
          break;
        case '--help':
        case '-h':
          _printHelp();
          exit(0);
        default:
          if (!args[i].startsWith('--')) {
            rootPath = args[i];
          }
      }
    }

    return ValidationArgs(
      includeTests: includeTests,
      jsonOutput: jsonOutput,
      failOnViolations: failOnViolations,
      outputFile: outputFile,
      rootPath: rootPath,
    );
  }

  static void _printHelp() {
    print('''
Color Validation Script

Usage: dart scripts/validate_colors.dart [options] [root_path]

Options:
  --include-tests    Include test files in validation
  --json            Output results in JSON format
  --no-fail         Don't fail on violations (warning mode)
  --output <file>   Write results to file
  --root <path>     Root path to scan (default: current directory)
  --help, -h        Show this help message

Examples:
  dart scripts/validate_colors.dart
  dart scripts/validate_colors.dart --json --output violations.json
  dart scripts/validate_colors.dart --include-tests lib/
  dart scripts/validate_colors.dart --no-fail --json
''');
  }
}

Future<void> main(List<String> arguments) async {
  final args = ValidationArgs.fromArgs(arguments);
  
  print('🔍 Scanning for hardcoded colors...');
  print('Root path: ${args.rootPath}');
  print('Include tests: ${args.includeTests}');
  
  try {
    final result = await ColorLintScanner.scanProject(
      rootPath: args.rootPath,
      includeTests: args.includeTests,
    );
    
    if (args.jsonOutput) {
      await _outputJson(result, args.outputFile);
    } else {
      await _outputText(result, args.outputFile);
    }
    
    // Exit with appropriate code
    if (args.failOnViolations && !result.isValid) {
      print('\n❌ Color validation failed!');
      exit(1);
    } else if (result.isValid) {
      print('\n✅ Color validation passed!');
      exit(0);
    } else {
      print('\n⚠️  Color validation completed with warnings');
      exit(0);
    }
    
  } catch (e, stackTrace) {
    print('❌ Error during color validation: $e');
    if (args.jsonOutput) {
      final errorResult = {
        'error': true,
        'message': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
      print(jsonEncode(errorResult));
    }
    exit(2);
  }
}

Future<void> _outputJson(ColorValidationResult result, String? outputFile) async {
  final json = jsonEncode(result.toJson());
  
  if (outputFile != null) {
    await File(outputFile).writeAsString(json);
    print('Results written to: $outputFile');
  } else {
    print(json);
  }
}

Future<void> _outputText(ColorValidationResult result, String? outputFile) async {
  final report = ColorLintScanner.generateReport(result);
  
  if (outputFile != null) {
    await File(outputFile).writeAsString(report);
    print('Report written to: $outputFile');
  } else {
    print(report);
  }
}