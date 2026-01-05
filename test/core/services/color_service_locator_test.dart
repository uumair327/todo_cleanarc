import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/services/color_service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ColorServiceLocator', () {
    late ColorServiceLocator serviceLocator;

    setUp(() {
      serviceLocator = ColorServiceLocator.instance;
    });

    tearDown(() async {
      serviceLocator.dispose();
    });

    test('should initialize successfully', () async {
      expect(serviceLocator.isInitialized, false);
      
      await serviceLocator.initialize();
      
      expect(serviceLocator.isInitialized, true);
    });

    test('should provide all required services after initialization', () async {
      await serviceLocator.initialize();
      
      expect(serviceLocator.colorRepository, isNotNull);
      expect(serviceLocator.themeRepository, isNotNull);
      expect(serviceLocator.colorResolverService, isNotNull);
      expect(serviceLocator.themeProviderService, isNotNull);
    });

    test('should throw StateError when accessing services before initialization', () {
      expect(() => serviceLocator.colorRepository, throwsStateError);
      expect(() => serviceLocator.themeRepository, throwsStateError);
      expect(() => serviceLocator.colorResolverService, throwsStateError);
      expect(() => serviceLocator.themeProviderService, throwsStateError);
    });

    test('should reset and reinitialize successfully', () async {
      await serviceLocator.initialize();
      expect(serviceLocator.isInitialized, true);
      
      await serviceLocator.reset();
      
      expect(serviceLocator.isInitialized, true);
      expect(serviceLocator.colorRepository, isNotNull);
    });
  });
}