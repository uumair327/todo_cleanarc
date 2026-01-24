import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/auth/domain/usecases/sign_up_usecase.dart';
import 'package:todo_cleanarc/feature/auth/domain/repositories/auth_repository.dart';
import 'package:todo_cleanarc/feature/auth/domain/entities/user_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/domain/value_objects/email.dart';
import 'package:todo_cleanarc/core/domain/value_objects/password.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';

import 'sign_up_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
  });

  final testEmail = Email.fromString('test@example.com');
  final testPassword = Password.fromString('password123');
  final testUser = UserEntity(
    id: UserId.fromString('123'),
    email: Email.fromString('test@example.com'),
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignUpUseCase', () {
    test('should return UserEntity when sign up is successful', () async {
      // Arrange
      when(mockRepository.signUp(email: testEmail, password: testPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result =
          await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signUp(email: testEmail, password: testPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthenticationFailure when sign up fails', () async {
      // Arrange
      const failure = AuthenticationFailure(message: 'Email already exists');
      when(mockRepository.signUp(email: testEmail, password: testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result =
          await useCase.call(email: testEmail, password: testPassword);

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
      final result =
          await useCase.call(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signUp(email: testEmail, password: testPassword));
    });
  });
}
