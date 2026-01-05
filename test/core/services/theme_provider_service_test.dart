import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/services/color_service_locator.dart';
import 'package:todo_cleanarc/core/services/theme_provider_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ThemeProviderService', () {
    late ThemeProviderService themeProviderService;

    setUpAll(() async {
      final serviceLocator = ColorServiceLocator.instance;
      await serviceLocator.initialize();
      themeProviderService = serviceLocator.themeProviderService;
    });

    tearDownAll(() {
      ColorServiceLocator.instance.dispose();
    });

    test('should have initial theme state', () async {
      final currentTheme = await themeProviderService.getCurrentTheme();
      
      currentTheme.fold(
        (failure) => fail('Should not fail: $failure'),
        (themeState) {
          expect(themeState, isNotNull);
          expect(themeState.currentTheme, isNotNull);
          expect(themeState.availableThemes, isNotEmpty);
        },
      );
    });

    test('should provide theme stream', () {
      expect(themeProviderService.themeStream, isNotNull);
    });

    test('should get color by token name', () async {
      final result = await themeProviderService.getColor('surfacePrimary');
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
          expect(color.semanticName, equals('surfacePrimary'));
        },
      );
    });

    test('should get on-color for surface', () async {
      final result = await themeProviderService.getOnColor('surfacePrimary');
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (color) {
          expect(color, isNotNull);
        },
      );
    });

    test('should get all colors', () async {
      final result = await themeProviderService.getAllColors();
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (colors) {
          expect(colors, isNotEmpty);
          expect(colors.containsKey('surfacePrimary'), true);
        },
      );
    });

    test('should set theme by name', () async {
      final result = await themeProviderService.setTheme('light');
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (_) {
          // Success case - no additional assertions needed
        },
      );
    });

    test('should toggle system theme', () async {
      final result = await themeProviderService.toggleSystemTheme(true);
      
      result.fold(
        (failure) => fail('Should not fail: $failure'),
        (_) {
          // Success case - no additional assertions needed
        },
      );
    });
  });
}