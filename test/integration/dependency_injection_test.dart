import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import '../../lib/core/services/color_resolver_service.dart';
import '../../lib/core/services/color_resolver_service_impl.dart';
import '../../lib/core/services/theme_provider_service.dart';
import '../../lib/core/domain/repositories/color_repository.dart';
import '../../lib/core/domain/repositories/theme_repository.dart';
import '../../lib/core/infrastructure/color/color_storage_impl.dart';
import '../../lib/core/infrastructure/theme/theme_storage_impl.dart';

/// Integration test to verify dependency injection setup is working correctly
void main() {
  group('Dependency Injection Integration Tests', () {
    late GetIt testSl;

    setUp(() {
      // Create a test service locator
      testSl = GetIt.instance;
      testSl.reset();
      
      // Register services manually for testing
      testSl.registerLazySingleton<ColorRepository>(() => ColorStorageImpl());
      testSl.registerLazySingleton<ThemeRepository>(() => ThemeStorageImpl());
      testSl.registerLazySingleton<ColorResolverService>(
        () => ColorResolverServiceImpl(
          colorRepository: testSl(),
        ),
      );
    });

    tearDown(() {
      testSl.reset();
    });

    test('should resolve ColorRepository from service locator', () {
      // Act
      final colorRepository = testSl<ColorRepository>();
      
      // Assert
      expect(colorRepository, isNotNull);
      expect(colorRepository, isA<ColorRepository>());
      expect(colorRepository, isA<ColorStorageImpl>());
    });

    test('should resolve ThemeRepository from service locator', () {
      // Act
      final themeRepository = testSl<ThemeRepository>();
      
      // Assert
      expect(themeRepository, isNotNull);
      expect(themeRepository, isA<ThemeRepository>());
      expect(themeRepository, isA<ThemeStorageImpl>());
    });

    test('should resolve ColorResolverService from service locator', () {
      // Act
      final colorResolverService = testSl<ColorResolverService>();
      
      // Assert
      expect(colorResolverService, isNotNull);
      expect(colorResolverService, isA<ColorResolverService>());
      expect(colorResolverService, isA<ColorResolverServiceImpl>());
    });

    test('should maintain singleton instances for services', () {
      // Act
      final colorResolverService1 = testSl<ColorResolverService>();
      final colorResolverService2 = testSl<ColorResolverService>();
      
      final colorRepository1 = testSl<ColorRepository>();
      final colorRepository2 = testSl<ColorRepository>();
      
      // Assert - should be the same instance (singleton)
      expect(identical(colorResolverService1, colorResolverService2), isTrue);
      expect(identical(colorRepository1, colorRepository2), isTrue);
    });

    test('should inject dependencies correctly into services', () {
      // Act
      final colorResolverService = testSl<ColorResolverService>();
      
      // Assert - services should be properly initialized with their dependencies
      expect(colorResolverService, isNotNull);
      
      // The service should be able to function (basic smoke test)
      expect(() => colorResolverService.clearCache(), returnsNormally);
    });

    test('should follow dependency inversion principle', () {
      // Act
      final colorRepository = testSl<ColorRepository>();
      final colorResolverService = testSl<ColorResolverService>();
      
      // Assert - services depend on abstractions, not concrete implementations
      expect(colorRepository, isA<ColorRepository>());
      expect(colorResolverService, isA<ColorResolverService>());
      
      // The concrete implementations should implement the abstractions
      expect(colorRepository, isA<ColorStorageImpl>());
      expect(colorResolverService, isA<ColorResolverServiceImpl>());
    });
  });
}