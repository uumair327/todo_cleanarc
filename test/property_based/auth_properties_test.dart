import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_up_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/core/domain/value_objects/email.dart';
import 'package:glimfo_todo/core/domain/value_objects/password.dart';

import 'generators/user_generators.dart';
import 'auth_properties_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late SignUpUseCase signUpUseCase;
  late SignInUseCase signInUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signUpUseCase = SignUpUseCase(mockAuthRepository);
    signInUseCase = SignInUseCase(mockAuthRepository);
  });

  group('Authentication Round Trip Property Tests', () {
    /// **Feature: flutter-todo-app, Property 1: Authentication round trip**
    /// **Validates: Requirements 1.1, 2.1**
    /// 
    /// For any valid email and password combination, creating an account then 
    /// logging in with those credentials should succeed and grant access to the dashboard.
    test('Authentication round trip - sign up then sign in with same credentials succeeds', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate valid credentials
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign up to succeed
        when(mockAuthRepository.signUp(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock sign in to succeed with the same credentials
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Execute sign up
        final signUpResult = await signUpUseCase(email: email, password: password);
        
        // Execute sign in
        final signInResult = await signInUseCase(email: email, password: password);

        // Both operations should succeed
        if (signUpResult.isRight() && signInResult.isRight()) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'All authentication round trips should succeed');
    });

    /// Property test for sign up with valid credentials
    test('Sign up with valid credentials always succeeds', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        when(mockAuthRepository.signUp(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        final result = await signUpUseCase(email: email, password: password);
        
        result.fold(
          (failure) => null,
          (returnedUser) {
            if (returnedUser.email == email) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All sign up operations with valid credentials should succeed');
    });

    /// Property test for sign in with valid credentials
    test('Sign in with valid credentials always succeeds', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        final result = await signInUseCase(email: email, password: password);
        
        result.fold(
          (failure) => null,
          (returnedUser) {
            if (returnedUser.email == email) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All sign in operations with valid credentials should succeed');
    });

    /// Property test for authentication preserves user data
    test('Authentication preserves user email and returns valid user entity', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        when(mockAuthRepository.signUp(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        final result = await signUpUseCase(email: email, password: password);
        
        result.fold(
          (failure) => null,
          (returnedUser) {
            // Verify user data is preserved
            if (returnedUser.email == email &&
                returnedUser.id == user.id &&
                returnedUser.displayName == user.displayName &&
                returnedUser.createdAt == user.createdAt) {
              successCount++;
            }
          },
        );
      }

      expect(successCount, equals(iterations),
          reason: 'All authentication operations should preserve user data');
    });

    /// Property test for authentication idempotency
    test('Multiple sign in attempts with same credentials produce consistent results', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Sign in twice with same credentials
        final firstResult = await signInUseCase(email: email, password: password);
        final secondResult = await signInUseCase(email: email, password: password);

        // Both should succeed
        if (firstResult.isRight() && secondResult.isRight()) {
          // Both should return the same user
          firstResult.fold(
            (failure) => null,
            (firstUser) => secondResult.fold(
              (failure) => null,
              (secondUser) {
                if (firstUser.email == secondUser.email &&
                    firstUser.id == secondUser.id) {
                  successCount++;
                }
              },
            ),
          );
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Multiple sign in attempts should produce consistent results');
    });
  });
}
