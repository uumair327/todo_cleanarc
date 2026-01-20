import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/auth/domain/usecases/sign_up_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/feature/auth/domain/entities/user_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'sign_up_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(repository: mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserEntity(
    id: '123',
    email: testEmail,
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignUpUseCase', () {
    test('should return UserEntity when sign up is successful', () async {
      // Arrange
      when(mockRepository.signUp(email: testEmail, password: testPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signUp(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when sign up fails', () async {
      // Arrange
      const failure = AuthFailure(message: 'Email already exists');
      when(mockRepository.signUp(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signUp(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(mockRepository.signUp(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signUp(email: testEmail, password: testPassword));
    });
  });
}
