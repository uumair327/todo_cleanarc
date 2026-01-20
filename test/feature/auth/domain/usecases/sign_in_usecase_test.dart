import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/feature/auth/domain/entities/user_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'sign_in_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(repository: mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserEntity(
    id: '123',
    email: testEmail,
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignInUseCase', () {
    test('should return UserEntity when sign in is successful', () async {
      // Arrange
      when(mockRepository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signIn(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      const failure = AuthFailure(message: 'Invalid credentials');
      when(mockRepository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signIn(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(mockRepository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signIn(email: testEmail, password: testPassword));
    });
  });
}
