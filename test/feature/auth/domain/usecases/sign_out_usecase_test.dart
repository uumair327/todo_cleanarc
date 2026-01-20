import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/auth/domain/usecases/sign_out_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'sign_out_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(repository: mockRepository);
  });

  group('SignOutUseCase', () {
    test('should return Right(unit) when sign out is successful', () async {
      // Arrange
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Right(unit));
      verify(mockRepository.signOut());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when sign out fails', () async {
      // Arrange
      const failure = AuthFailure(message: 'Sign out failed');
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signOut());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
