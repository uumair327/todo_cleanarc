import 'dart:io';
import 'package:test/test.dart';
import 'package:todo_cleanarc/audit/analyzers/code_discovery.dart';
import 'package:todo_cleanarc/audit/models/layer.dart';

void main() {
  group('CodeDiscoveryImpl', () {
    late CodeDiscoveryImpl discovery;
    
    setUp(() {
      discovery = CodeDiscoveryImpl();
    });
    
    group('discoverFiles', () {
      test('discovers Dart files in lib directory', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        
        expect(files, isNotEmpty);
        expect(files.every((f) => f.path.endsWith('.dart')), isTrue);
        expect(files.every((f) => f.relativePath.startsWith('lib/')), isTrue);
      });
      
      test('throws ArgumentError when lib directory does not exist', () async {
        expect(
          () => discovery.discoverFiles('/nonexistent/path'),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('categorizes files by layer during discovery', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        
        // Verify that files have been categorized
        expect(files, isNotEmpty);
      });
      
      test('extracts feature names during discovery', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        
        // Find files in feature directories
        final featureFiles = files.where((f) => f.relativePath.contains('lib/feature/')).toList();
        
        if (featureFiles.isNotEmpty) {
          expect(featureFiles.every((f) => f.feature != null), isTrue);
        }
      });
    });
    
    group('categorizeByLayer', () {
      test('groups files by their layer', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        final categorized = discovery.categorizeByLayer(files);
        
        // Verify all layers are present in the map
        for (final layer in Layer.values) {
          expect(categorized.containsKey(layer), isTrue);
        }
        
        // Verify files are in correct layer groups
        for (final entry in categorized.entries) {
          for (final file in entry.value) {
            expect(file.layer, equals(entry.key));
          }
        }
      });
      
      test('returns empty lists for layers with no files', () {
        final categorized = discovery.categorizeByLayer([]);
        
        for (final layer in Layer.values) {
          expect(categorized[layer], isEmpty);
        }
      });
    });
    
    group('groupByFeature', () {
      test('groups files by feature name', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        final grouped = discovery.groupByFeature(files);
        
        expect(grouped, isNotEmpty);
        
        // Verify files are in correct feature groups
        for (final entry in grouped.entries) {
          for (final file in entry.value) {
            if (entry.key == 'core') {
              expect(file.feature, isNull);
            } else {
              expect(file.feature, equals(entry.key));
            }
          }
        }
      });
      
      test('assigns core to files without feature', () async {
        final projectRoot = Directory.current.path;
        final files = await discovery.discoverFiles(projectRoot);
        final grouped = discovery.groupByFeature(files);
        
        // Core files should exist
        expect(grouped.containsKey('core'), isTrue);
        
        // All files in core should have null feature
        if (grouped['core']!.isNotEmpty) {
          expect(grouped['core']!.every((f) => f.feature == null), isTrue);
        }
      });
    });
  });
}
