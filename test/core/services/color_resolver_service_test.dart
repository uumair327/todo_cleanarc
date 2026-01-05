import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/services/color_service_locator.dart';
import 'package:todo_cleanarc/core/services/color_resolver_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ColorResolverService', () {
    late ColorResolverService colorResolverService;

    setUpAll(() async {
      final serviceLocator = ColorServiceLocator.instance;
      await serviceLocator.initialize();
      colorResolverService = serviceLocator.colorResolverService;
    });

    tearDownAll(() {
      ColorServiceLocator.instance.dispose();
    });

    test('should resolve semantic colors for light theme', () async {
      final result = await colorResolverService.resolveSemanticColor('surfacePrimary', ThemeMode.light);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
          expect(color.semanticName, equals('surfacePrimary'));
        },
      );
    });

    test('should resolve semantic colors for dark theme', () async {
      final result = await colorResolverService.resolveSemanticColor('surfacePrimary', ThemeMode.dark);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
          expect(color.semanticName, equals('surfacePrimary'));
        },
      );
    });

    test('should resolve category colors', () async {
      final result = await colorResolverService.resolveCategoryColor('ongoingTask', ThemeMode.light);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
          expect(color.semanticName, equals('ongoingTask'));
        },
      );
    });

    test('should resolve state colors', () async {
      final result = await colorResolverService.resolveStateColor('successBackground', ThemeMode.light);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
          expect(color.semanticName, equals('successBackground'));
        },
      );
    });

    test('should resolve color palette', () async {
      final result = await colorResolverService.resolveColorPalette(ThemeMode.light);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (palette) {
          expect(palette, isNotEmpty);
          expect(palette.containsKey('surfacePrimary'), true);
          expect(palette.containsKey('ongoingTask'), true);
        },
      );
    });

    test('should handle unknown color tokens gracefully', () async {
      final result = await colorResolverService.resolveSemanticColor('unknownColor', ThemeMode.light);
      
      result.fold(
        (failure) => expect(failure, isNotNull),
        (color) => fail('Should fail for unknown color'),
      );
    });
  });
}