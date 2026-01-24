import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:todo_cleanarc/feature/auth/domain/repositories/auth_repository.dart';
import 'package:todo_cleanarc/feature/auth/domain/entities/user_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/domain/value_objects/email.dart';
import 'package:todo_cleanarc/core/domain/value_objects/password.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';

import 'sign_in_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  final testEmail = Email.fromString('test@example.com');
  final testPassword = Password.fromString('password123');
  final testUser = UserEntity(
    id: UserId.fromString('123'),
    email: Email.fromString('test@example.com'),
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignInUseCase', () {
    test('should return UserEntity when sign in is successful', () async {
      // Arrange
      when(mockRepository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result =
          await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signIn(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthenticationFailure when credentials are invalid',
        () async {
      // Arrange
      const failure = AuthenticationFailure(message: 'Invalid credentials');
      when(mockRepository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result =
          await useCase.call(email: testEmail, password: testPassword);

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
      final result =
          await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signIn(email: testEmail, password: testPassword));
    });
  });
}
