import 'dart:io';
import '../models/layer.dart';
import '../models/source_file.dart';

/// Interface for discovering and categorizing source files in a project
abstract class CodeDiscovery {
  /// Discovers all Dart files in the project
  Future<List<SourceFile>> discoverFiles(String projectRoot);
  
  /// Categorizes files by layer (pages, operations, misc)
  Map<Layer, List<SourceFile>> categorizeByLayer(List<SourceFile> files);
  
  /// Groups files by feature module
  Map<String, List<SourceFile>> groupByFeature(List<SourceFile> files);
}

/// Default implementation of CodeDiscovery
class CodeDiscoveryImpl implements CodeDiscovery {
  @override
  Future<List<SourceFile>> discoverFiles(String projectRoot) async {
    final libDir = Directory('$projectRoot/lib');
    
    if (!await libDir.exists()) {
      throw ArgumentError('lib directory not found at: ${libDir.path}');
    }
    
    final sourceFiles = <SourceFile>[];
    
    await for (final entity in libDir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final relativePath = entity.path.substring(projectRoot.length + 1).replaceAll('\\', '/');
        
        final layer = _categorizeLayer(relativePath);
        final feature = _extractFeature(relativePath);
        
        sourceFiles.add(SourceFile(
          path: entity.path,
          relativePath: relativePath,
          layer: layer,
          feature: feature,
          content: content,
        ));
      }
    }
    
    return sourceFiles;
  }
  
  @override
  Map<Layer, List<SourceFile>> categorizeByLayer(List<SourceFile> files) {
    final result = <Layer, List<SourceFile>>{};
    
    for (final layer in Layer.values) {
      result[layer] = [];
    }
    
    for (final file in files) {
      result[file.layer]!.add(file);
    }
    
    return result;
  }
  
  @override
  Map<String, List<SourceFile>> groupByFeature(List<SourceFile> files) {
    final result = <String, List<SourceFile>>{};
    
    for (final file in files) {
      final featureName = file.feature ?? 'core';
      result.putIfAbsent(featureName, () => []).add(file);
    }
    
    return result;
  }
  
  /// Categorizes a file into its architectural layer based on path patterns
  Layer _categorizeLayer(String relativePath) {
    final normalizedPath = relativePath.toLowerCase();
    
    // Pages layer patterns
    if (normalizedPath.contains('/presentation/pages/') ||
        normalizedPath.contains('/presentation/screens/')) {
      return Layer.pages;
    }
    
    // Operations layer patterns
    if (normalizedPath.contains('/domain/usecases/') ||
        normalizedPath.contains('/domain/operations/')) {
      return Layer.operations;
    }
    
    // Domain layer patterns
    if (normalizedPath.contains('/domain/entities/') ||
        normalizedPath.contains('/domain/repositories/') ||
        normalizedPath.contains('/domain/value_objects/')) {
      return Layer.domain;
    }
    
    // Infrastructure layer patterns
    if (normalizedPath.contains('/data/datasources/') ||
        normalizedPath.contains('/data/repositories/') ||
        normalizedPath.contains('/infrastructure/')) {
      return Layer.infrastructure;
    }
    
    // Miscellaneous patterns
    if (normalizedPath.contains('/utils/') ||
        normalizedPath.contains('/helpers/') ||
        normalizedPath.contains('/constants/')) {
      return Layer.miscellaneous;
    }
    
    // Default to miscellaneous for unrecognized patterns
    return Layer.miscellaneous;
  }
  
  /// Extracts feature name from directory structure (lib/feature/{name}/)
  String? _extractFeature(String relativePath) {
    final pattern = RegExp(r'lib/feature/([^/]+)/');
    final match = pattern.firstMatch(relativePath);
    return match?.group(1);
  }
}
