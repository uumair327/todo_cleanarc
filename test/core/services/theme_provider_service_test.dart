import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_cleanarc/core/domain/entities/app_theme_config.dart';
import 'package:todo_cleanarc/core/domain/entities/color_token.dart';
import 'package:todo_cleanarc/core/domain/entities/theme_state.dart';
import 'package:todo_cleanarc/core/domain/enums/color_enums.dart';
import 'package:todo_cleanarc/core/domain/repositories/theme_repository.dart';
import 'package:todo_cleanarc/core/domain/value_objects/app_color.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/services/theme_provider_service_impl.dart';

import 'theme_provider_service_test.mocks.dart';

@GenerateMocks([ThemeRepository])
void main() {
  late ThemeProviderServiceImpl service;
  late MockThemeRepository mockThemeRepository;
  late AppThemeConfig testTheme;

  setUp(() {
    mockThemeRepository = MockThemeRepository();
    
    // Create test theme
    testTheme = AppThemeConfig(
      name: 'Test Theme',
      mode: ThemeMode.light,
      colorTokens: {
        'surfacePrimary': ColorToken.uniform(
          name: 'surfacePrimary',
          color: AppColor.fromHex('#FFFFFF', 'surfacePrimary'),
          role: ColorRole.surface,
        ),
        'ongoingTask': ColorToken.uniform(
          name: 'ongoingTask',
          color: AppColor.fromHex('#2196F3', 'ongoingTask'),
          role: ColorRole.primary,
        ),
      },
    );

    service = ThemeProviderServiceImpl(
      themeRepository: mockThemeRepository,
      initialTheme: testTheme,
    );
  });

  group('ThemeProviderService', () {
    group('initialize', () {
      test('should initialize successfully with existing theme state', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        // Act
        final result = await service.initialize();

        // Assert
        expect(result.isRight(), true);
        expect(service.currentTheme.currentTheme.name, 'Test Theme');
      });

      test('should use default theme when loading fails', () async {
        // Arrange
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Left(CacheFailure(message: 'Load failed')));
        when(mockThemeRepository.getDefaultTheme())
            .thenAnswer((_) async => Right(testTheme));

        // Act
        final result = await service.initialize();

        // Assert
        expect(result.isRight(), true);
        expect(service.currentTheme.currentTheme.name, 'Test Theme');
      });

      test('should not initialize twice', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        // Act
        await service.initialize();
        final result = await service.initialize();

        // Assert
        expect(result.isRight(), true);
        verify(mockThemeRepository.getThemeState()).called(1);
      });
    });

    group('setTheme', () {
      test('should set theme successfully', () async {
        // Arrange
        final newTheme = AppThemeConfig(
          name: 'New Theme',
          mode: ThemeMode.light,
          colorTokens: testTheme.colorTokens,
        );
        final themeState = ThemeState.initial(testTheme).withAvailableThemes([testTheme, newTheme]);
        
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));
        when(mockThemeRepository.validateTheme(newTheme))
            .thenAnswer((_) async => const Right(null));
        when(mockThemeRepository.saveTheme(newTheme))
            .thenAnswer((_) async => const Right(null));

        await service.initialize();

        // Act
        final result = await service.setTheme('New Theme');

        // Assert
        expect(result.isRight(), true);
        expect(service.currentTheme.currentTheme.name, 'New Theme');
      });

      test('should return failure for non-existent theme', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act
        final result = await service.setTheme('Non-existent Theme');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getColor', () {
      test('should return color from theme configuration', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act
        final color = service.getColor('surfacePrimary');

        // Assert
        expect(color.semanticName, 'surfacePrimary');
        expect(color.toHex(), '#FFFFFF');
      });

      test('should throw error for non-existent color token', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act & Assert
        expect(
          () => service.getColor('nonExistentColor'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should cache colors for performance', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act - Call getColor multiple times
        final color1 = service.getColor('surfacePrimary');
        final color2 = service.getColor('surfacePrimary');

        // Assert - Should return same instance (cached)
        expect(identical(color1, color2), true);
      });
    });

    group('getAllColors', () {
      test('should return all colors from current theme', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act
        final allColors = service.getAllColors();

        // Assert
        expect(allColors.length, 2);
        expect(allColors.containsKey('surfacePrimary'), true);
        expect(allColors.containsKey('ongoingTask'), true);
      });
    });

    group('themeStream', () {
      test('should emit theme changes', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        final streamCompleter = Completer<ThemeState>();
        service.themeStream.listen((state) {
          if (!streamCompleter.isCompleted) {
            streamCompleter.complete(state);
          }
        });

        // Act
        await service.initialize();

        // Assert
        final emittedState = await streamCompleter.future;
        expect(emittedState.currentTheme.name, 'Test Theme');
      });
    });

    group('dispose', () {
      test('should clean up resources', () async {
        // Arrange
        final themeState = ThemeState.initial(testTheme);
        when(mockThemeRepository.getThemeState())
            .thenAnswer((_) async => Right(themeState));

        await service.initialize();

        // Act
        service.dispose();

        // Assert - Should not throw any errors
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}