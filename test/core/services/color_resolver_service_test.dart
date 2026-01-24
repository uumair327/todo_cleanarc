import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_cleanarc/core/domain/entities/color_token.dart';
import 'package:todo_cleanarc/core/domain/enums/color_enums.dart';
import 'package:todo_cleanarc/core/domain/repositories/color_repository.dart';
import 'package:todo_cleanarc/core/domain/value_objects/app_color.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/services/color_resolver_service_impl.dart';

import 'color_resolver_service_test.mocks.dart';

@GenerateMocks([ColorRepository])
void main() {
  late ColorResolverServiceImpl service;
  late MockColorRepository mockColorRepository;

  setUp(() {
    mockColorRepository = MockColorRepository();
    service = ColorResolverServiceImpl(colorRepository: mockColorRepository);
  });

  group('ColorResolverService', () {
    group('resolveSemanticColor', () {
      test('should return cached color when available', () async {
        // Arrange
        const semanticName = 'surfacePrimary';
        const mode = ThemeMode.light;
        final expectedColor = AppColor.fromHex('#FFFFFF', semanticName);
        final colorToken = ColorToken.uniform(
          name: semanticName,
          color: expectedColor,
          role: ColorRole.surface,
        );

        when(mockColorRepository.getColorToken(semanticName, mode))
            .thenAnswer((_) async => Right(colorToken));

        // Act - First call to populate cache
        final result1 = await service.resolveSemanticColor(semanticName, mode);
        final result2 = await service.resolveSemanticColor(semanticName, mode);

        // Assert
        expect(result1.isRight(), true);
        expect(result2.isRight(), true);
        verify(mockColorRepository.getColorToken(semanticName, mode)).called(1);
      });

      test('should return failure when color token not found', () async {
        // Arrange
        const semanticName = 'nonExistentColor';
        const mode = ThemeMode.light;

        when(mockColorRepository.getColorToken(semanticName, mode))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.resolveSemanticColor(semanticName, mode);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('resolveCategoryColor', () {
      test('should resolve ongoing category color correctly', () async {
        // Arrange
        const category = 'ongoing';
        const mode = ThemeMode.light;
        final expectedColor = AppColor.fromHex('#2196F3', 'ongoingTask');
        final colorToken = ColorToken.uniform(
          name: 'ongoingTask',
          color: expectedColor,
          role: ColorRole.primary,
        );

        when(mockColorRepository.getColorToken('ongoingTask', mode))
            .thenAnswer((_) async => Right(colorToken));

        // Act
        final result = await service.resolveCategoryColor(category, mode);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (color) => expect(color.semanticName, 'ongoingTask'),
        );
      });

      test('should return failure for unknown category', () async {
        // Arrange
        const category = 'unknownCategory';
        const mode = ThemeMode.light;

        // Act
        final result = await service.resolveCategoryColor(category, mode);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('validateColorCombination', () {
      test('should validate accessible color combination', () async {
        // Arrange
        final foreground = AppColor.fromHex('#000000', 'black');
        final background = AppColor.fromHex('#FFFFFF', 'white');

        when(mockColorRepository.checkAccessibilityCompliance(any, any))
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await service.validateColorCombination(foreground, background);

        // Assert
        expect(result.isRight(), true);
      });

      test('should return failure for inaccessible color combination', () async {
        // Arrange
        final foreground = AppColor.fromHex('#CCCCCC', 'lightGray');
        final background = AppColor.fromHex('#FFFFFF', 'white');

        when(mockColorRepository.checkAccessibilityCompliance(any, any))
            .thenAnswer((_) async => const Right(false));

        // Act
        final result = await service.validateColorCombination(foreground, background);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('resolveColorPalette', () {
      test('should return complete color palette', () async {
        // Arrange
        const mode = ThemeMode.light;
        final colorTokens = {
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
        };

        when(mockColorRepository.getColorTokens(mode))
            .thenAnswer((_) async => Right(colorTokens));

        // Act
        final result = await service.resolveColorPalette(mode);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (palette) {
            expect(palette.length, 2);
            expect(palette.containsKey('surfacePrimary'), true);
            expect(palette.containsKey('ongoingTask'), true);
          },
        );
      });
    });

    group('clearCache', () {
      test('should clear all cached colors', () async {
        // Arrange
        const semanticName = 'surfacePrimary';
        const mode = ThemeMode.light;
        final expectedColor = AppColor.fromHex('#FFFFFF', semanticName);
        final colorToken = ColorToken.uniform(
          name: semanticName,
          color: expectedColor,
          role: ColorRole.surface,
        );

        when(mockColorRepository.getColorToken(semanticName, mode))
            .thenAnswer((_) async => Right(colorToken));

        // Act - Populate cache
        await service.resolveSemanticColor(semanticName, mode);
        
        // Clear cache
        service.clearCache();
        
        // Try to resolve again
        await service.resolveSemanticColor(semanticName, mode);

        // Assert - Should call repository twice (once before clear, once after)
        verify(mockColorRepository.getColorToken(semanticName, mode)).called(2);
      });
    });
  });
}
