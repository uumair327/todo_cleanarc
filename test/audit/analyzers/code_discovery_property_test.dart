import 'dart:io';
import 'dart:math';
import 'package:test/test.dart';
import 'package:todo_cleanarc/audit/analyzers/code_discovery.dart';
import 'package:todo_cleanarc/audit/models/layer.dart';

void main() {
  group('Code Discovery Property-Based Tests', () {
    late CodeDiscoveryImpl discovery;
    late Directory tempDir;
    late Random random;
    
    setUp(() {
      discovery = CodeDiscoveryImpl();
      random = Random(42); // Fixed seed for reproducibility
    });
    
    tearDown(() async {
      // Clean up temporary directories
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });
    
    /// **Feature: architecture-audit, Property: File Discovery Completeness**
    /// **Validates: Requirements 1.1, 2.1, 3.1**
    /// 
    /// Property: For any directory structure with Dart files, all .dart files
    /// in the lib/ directory should be discovered by the CodeDiscovery system.
    test('Property: File Discovery Completeness - all Dart files are discovered', () async {
      const iterations = 100;
      int passedIterations = 0;
      final failures = <String>[];
      
      for (int i = 0; i < iterations; i++) {
        // Generate a random directory structure
        tempDir = await _createTempDirectory('code_discovery_test_$i');
        final projectRoot = tempDir.path;
        
        // Generate random Dart files in various locations
        final expectedFiles = await _generateRandomDartFiles(
          projectRoot,
          random,
          fileCount: random.nextInt(20) + 5, // 5-24 files
        );
        
        try {
          // Discover files using the CodeDiscovery implementation
          final discoveredFiles = await discovery.discoverFiles(projectRoot);
          
          // Property: All expected Dart files should be discovered
          final discoveredPaths = discoveredFiles
              .map((f) => f.relativePath)
              .toSet();
          
          final expectedPaths = expectedFiles
              .map((f) => f.replaceAll('\\', '/').substring(projectRoot.length + 1))
              .toSet();
          
          // Check completeness: all expected files are discovered
          final allFilesDiscovered = expectedPaths.every(
            (expected) => discoveredPaths.contains(expected),
          );
          
          // Check correctness: no extra files are discovered
          final noExtraFiles = discoveredPaths.every(
            (discovered) => expectedPaths.contains(discovered),
          );
          
          if (allFilesDiscovered && noExtraFiles) {
            passedIterations++;
          } else {
            final missing = expectedPaths.difference(discoveredPaths);
            final extra = discoveredPaths.difference(expectedPaths);
            failures.add(
              'Iteration ${i + 1}: '
              'Missing files: $missing, '
              'Extra files: $extra',
            );
          }
        } catch (e) {
          failures.add('Iteration ${i + 1}: Exception - $e');
        } finally {
          // Clean up after each iteration
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      }
      
      // Report results
      if (failures.isNotEmpty) {
        fail(
          'Property failed in ${failures.length} out of $iterations iterations:\n'
          '${failures.take(5).join('\n')}'
          '${failures.length > 5 ? '\n... and ${failures.length - 5} more failures' : ''}',
        );
      }
      
      expect(passedIterations, equals(iterations),
          reason: 'All iterations should pass the file discovery completeness property');
    });
    
    /// **Feature: architecture-audit, Property: File Discovery Completeness**
    /// **Validates: Requirements 1.1, 2.1, 3.1**
    /// 
    /// Property: Discovered files should have correct metadata (path, content, layer)
    test('Property: Discovered files have correct metadata', () async {
      const iterations = 100;
      int passedIterations = 0;
      final failures = <String>[];
      
      for (int i = 0; i < iterations; i++) {
        tempDir = await _createTempDirectory('code_discovery_metadata_test_$i');
        final projectRoot = tempDir.path;
        
        // Generate random Dart files with known content
        final fileContents = <String, String>{};
        await _generateRandomDartFilesWithContent(
          projectRoot,
          random,
          fileCount: random.nextInt(15) + 5,
          fileContents: fileContents,
        );
        
        try {
          final discoveredFiles = await discovery.discoverFiles(projectRoot);
          
          bool allMetadataCorrect = true;
          final metadataErrors = <String>[];
          
          for (final file in discoveredFiles) {
            // Check path is absolute
            if (!file.path.contains(projectRoot)) {
              allMetadataCorrect = false;
              metadataErrors.add('Path not absolute: ${file.path}');
            }
            
            // Check relative path starts with lib/
            if (!file.relativePath.startsWith('lib/')) {
              allMetadataCorrect = false;
              metadataErrors.add('Relative path incorrect: ${file.relativePath}');
            }
            
            // Check content matches expected
            final expectedContent = fileContents[file.path];
            if (expectedContent != null && file.content != expectedContent) {
              allMetadataCorrect = false;
              metadataErrors.add('Content mismatch for: ${file.relativePath}');
            }
            
            // Check layer is assigned
            if (!Layer.values.contains(file.layer)) {
              allMetadataCorrect = false;
              metadataErrors.add('Invalid layer for: ${file.relativePath}');
            }
          }
          
          if (allMetadataCorrect) {
            passedIterations++;
          } else {
            failures.add(
              'Iteration ${i + 1}: Metadata errors: ${metadataErrors.join(', ')}',
            );
          }
        } catch (e) {
          failures.add('Iteration ${i + 1}: Exception - $e');
        } finally {
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      }
      
      if (failures.isNotEmpty) {
        fail(
          'Property failed in ${failures.length} out of $iterations iterations:\n'
          '${failures.take(5).join('\n')}'
          '${failures.length > 5 ? '\n... and ${failures.length - 5} more failures' : ''}',
        );
      }
      
      expect(passedIterations, equals(iterations),
          reason: 'All iterations should pass the metadata correctness property');
    });
    
    /// **Feature: architecture-audit, Property: File Discovery Completeness**
    /// **Validates: Requirements 1.1, 2.1, 3.1**
    /// 
    /// Property: Non-Dart files should be ignored during discovery
    test('Property: Non-Dart files are ignored', () async {
      const iterations = 100;
      int passedIterations = 0;
      final failures = <String>[];
      
      for (int i = 0; i < iterations; i++) {
        tempDir = await _createTempDirectory('code_discovery_filter_test_$i');
        final projectRoot = tempDir.path;
        
        // Generate mix of Dart and non-Dart files
        final dartFiles = await _generateRandomDartFiles(
          projectRoot,
          random,
          fileCount: random.nextInt(10) + 3,
        );
        
        final nonDartFiles = await _generateRandomNonDartFiles(
          projectRoot,
          random,
          fileCount: random.nextInt(10) + 3,
        );
        
        try {
          final discoveredFiles = await discovery.discoverFiles(projectRoot);
          
          // Property: Only Dart files should be discovered
          final allAreDartFiles = discoveredFiles.every(
            (f) => f.path.endsWith('.dart'),
          );
          
          // Property: No non-Dart files should be discovered
          final discoveredPaths = discoveredFiles.map((f) => f.path).toSet();
          final noNonDartFiles = nonDartFiles.every(
            (nonDartPath) => !discoveredPaths.contains(nonDartPath),
          );
          
          if (allAreDartFiles && noNonDartFiles) {
            passedIterations++;
          } else {
            failures.add(
              'Iteration ${i + 1}: '
              'All Dart: $allAreDartFiles, '
              'No non-Dart: $noNonDartFiles',
            );
          }
        } catch (e) {
          failures.add('Iteration ${i + 1}: Exception - $e');
        } finally {
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      }
      
      if (failures.isNotEmpty) {
        fail(
          'Property failed in ${failures.length} out of $iterations iterations:\n'
          '${failures.take(5).join('\n')}'
          '${failures.length > 5 ? '\n... and ${failures.length - 5} more failures' : ''}',
        );
      }
      
      expect(passedIterations, equals(iterations),
          reason: 'All iterations should pass the non-Dart file filtering property');
    });
  });
}

/// Helper function to create a temporary directory
Future<Directory> _createTempDirectory(String name) async {
  final tempDir = Directory.systemTemp.createTempSync(name);
  return tempDir;
}

/// Helper function to generate random Dart files in a directory structure
Future<List<String>> _generateRandomDartFiles(
  String projectRoot,
  Random random,
  {required int fileCount}
) async {
  final libDir = Directory('$projectRoot/lib');
  await libDir.create(recursive: true);
  
  final createdFiles = <String>[];
  
  // Define possible directory structures
  final possiblePaths = [
    'lib/feature/auth/presentation/pages',
    'lib/feature/auth/presentation/screens',
    'lib/feature/todo/domain/usecases',
    'lib/feature/todo/domain/operations',
    'lib/feature/category/domain/entities',
    'lib/feature/category/data/repositories',
    'lib/core/utils',
    'lib/core/helpers',
    'lib/core/constants',
    'lib/core/infrastructure',
    'lib/core/domain/repositories',
    'lib/feature/profile/presentation/pages',
    'lib/feature/settings/domain/usecases',
  ];
  
  for (int i = 0; i < fileCount; i++) {
    // Pick a random path
    final dirPath = possiblePaths[random.nextInt(possiblePaths.length)];
    final fullDirPath = '$projectRoot/$dirPath';
    
    // Create directory
    await Directory(fullDirPath).create(recursive: true);
    
    // Create a Dart file
    final fileName = 'file_${random.nextInt(1000)}_${i}.dart';
    final filePath = '$fullDirPath/$fileName';
    final file = File(filePath);
    
    // Write some content
    await file.writeAsString('// Generated test file\nclass TestClass$i {}\n');
    
    createdFiles.add(filePath);
  }
  
  return createdFiles;
}

/// Helper function to generate random Dart files with tracked content
Future<void> _generateRandomDartFilesWithContent(
  String projectRoot,
  Random random,
  {required int fileCount, required Map<String, String> fileContents}
) async {
  final libDir = Directory('$projectRoot/lib');
  await libDir.create(recursive: true);
  
  final possiblePaths = [
    'lib/feature/auth/presentation/pages',
    'lib/feature/todo/domain/usecases',
    'lib/core/utils',
    'lib/core/helpers',
  ];
  
  for (int i = 0; i < fileCount; i++) {
    final dirPath = possiblePaths[random.nextInt(possiblePaths.length)];
    final fullDirPath = '$projectRoot/$dirPath';
    
    await Directory(fullDirPath).create(recursive: true);
    
    final fileName = 'file_${random.nextInt(1000)}_${i}.dart';
    final filePath = '$fullDirPath/$fileName';
    final file = File(filePath);
    
    final content = '// Test file $i\nclass TestClass$i {\n  void method$i() {}\n}\n';
    await file.writeAsString(content);
    
    fileContents[filePath] = content;
  }
}

/// Helper function to generate random non-Dart files
Future<List<String>> _generateRandomNonDartFiles(
  String projectRoot,
  Random random,
  {required int fileCount}
) async {
  final libDir = Directory('$projectRoot/lib');
  await libDir.create(recursive: true);
  
  final createdFiles = <String>[];
  
  final extensions = ['.txt', '.json', '.yaml', '.md', '.xml', '.html'];
  final possiblePaths = [
    'lib/assets',
    'lib/config',
    'lib/docs',
  ];
  
  for (int i = 0; i < fileCount; i++) {
    final dirPath = possiblePaths[random.nextInt(possiblePaths.length)];
    final fullDirPath = '$projectRoot/$dirPath';
    
    await Directory(fullDirPath).create(recursive: true);
    
    final extension = extensions[random.nextInt(extensions.length)];
    final fileName = 'file_${random.nextInt(1000)}_${i}$extension';
    final filePath = '$fullDirPath/$fileName';
    final file = File(filePath);
    
    await file.writeAsString('Test content for non-Dart file');
    
    createdFiles.add(filePath);
  }
  
  return createdFiles;
}
