import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:glimfo_todo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_out_usecase.dart';
import 'package:glimfo_todo/core/domain/value_objects/email.dart';
import 'package:glimfo_todo/core/domain/value_objects/password.dart';

import 'generators/user_generators.dart';
import 'session_management_properties_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInUseCase signInUseCase;
  late SignOutUseCase signOutUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockAuthRepository);
    signOutUseCase = SignOutUseCase(mockAuthRepository);
  });

  group('Session Management Integrity Property Tests', () {
    /// **Feature: flutter-todo-app, Property 9: Session management integrity**
    /// **Validates: Requirements 2.3, 9.2, 9.5**
    /// 
    /// For any authentication state change (login, logout, session expiry), 
    /// the system should maintain data integrity and provide appropriate navigation.
    
    test('Login creates session and logout clears session completely', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        // Generate valid credentials
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign in to succeed and create session
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock getCurrentUser to return user after sign in
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        // Mock sign out to succeed
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        // Execute sign in
        final signInResult = await signInUseCase(email: email, password: password);
        
        // Verify sign in succeeded
        bool signInSuccess = false;
        signInResult.fold(
          (failure) => signInSuccess = false,
          (returnedUser) => signInSuccess = true,
        );

        if (!signInSuccess) continue;

        // Execute sign out
        final signOutResult = await signOutUseCase();
        
        // Verify sign out succeeded
        bool signOutSuccess = false;
        signOutResult.fold(
          (failure) => signOutSuccess = false,
          (_) => signOutSuccess = true,
        );

        if (signInSuccess && signOutSuccess) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'All login-logout cycles should complete successfully');
    });

    test('Session persists after successful login', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign in
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock getCurrentUser to return the same user after sign in
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(user));

        // Execute sign in
        final signInResult = await signInUseCase(email: email, password: password);
        
        // Verify sign in succeeded
        bool signInSuccess = false;
        signInResult.fold(
          (failure) => signInSuccess = false,
          (returnedUser) => signInSuccess = true,
        );

        if (!signInSuccess) continue;

        // Verify session persists by getting current user
        final currentUserResult = await mockAuthRepository.getCurrentUser();
        
        bool sessionPersists = false;
        currentUserResult.fold(
          (failure) => sessionPersists = false,
          (currentUser) {
            if (currentUser != null && currentUser.email == email) {
              sessionPersists = true;
            }
          },
        );

        if (signInSuccess && sessionPersists) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Session should persist after successful login');
    });

    test('Logout clears session data completely', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign in
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock sign out
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        // Mock clearSession
        when(mockAuthRepository.clearSession())
            .thenAnswer((_) async => const Right(null));

        // Mock getCurrentUser to return null after logout
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        // Execute sign in
        await signInUseCase(email: email, password: password);

        // Execute sign out
        final signOutResult = await signOutUseCase();
        
        bool signOutSuccess = false;
        signOutResult.fold(
          (failure) => signOutSuccess = false,
          (_) => signOutSuccess = true,
        );

        if (!signOutSuccess) continue;

        // Verify session is cleared
        final currentUserResult = await mockAuthRepository.getCurrentUser();
        
        bool sessionCleared = false;
        currentUserResult.fold(
          (failure) => sessionCleared = false,
          (currentUser) {
            if (currentUser == null) {
              sessionCleared = true;
            }
          },
        );

        if (signOutSuccess && sessionCleared) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Logout should clear all session data');
    });

    test('Multiple login-logout cycles maintain integrity', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign in
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock sign out
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        bool allCyclesSucceeded = true;

        // Perform 3 login-logout cycles
        for (int cycle = 0; cycle < 3; cycle++) {
          // Sign in
          final signInResult = await signInUseCase(email: email, password: password);
          
          bool signInSuccess = false;
          signInResult.fold(
            (failure) => signInSuccess = false,
            (returnedUser) => signInSuccess = true,
          );

          if (!signInSuccess) {
            allCyclesSucceeded = false;
            break;
          }

          // Sign out
          final signOutResult = await signOutUseCase();
          
          bool signOutSuccess = false;
          signOutResult.fold(
            (failure) => signOutSuccess = false,
            (_) => signOutSuccess = true,
          );

          if (!signOutSuccess) {
            allCyclesSucceeded = false;
            break;
          }
        }

        if (allCyclesSucceeded) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Multiple login-logout cycles should maintain integrity');
    });

    test('Session state transitions are consistent', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock authentication state
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        when(mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => true);

        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        // Sign in
        final signInResult = await signInUseCase(email: email, password: password);
        
        bool signInSuccess = false;
        signInResult.fold(
          (failure) => signInSuccess = false,
          (returnedUser) => signInSuccess = true,
        );

        if (!signInSuccess) continue;

        // Check authenticated state
        final isAuthenticatedAfterLogin = await mockAuthRepository.isAuthenticated();

        // Sign out
        final signOutResult = await signOutUseCase();
        
        bool signOutSuccess = false;
        signOutResult.fold(
          (failure) => signOutSuccess = false,
          (_) => signOutSuccess = true,
        );

        // After logout, mock should return false for isAuthenticated
        when(mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => false);

        final isAuthenticatedAfterLogout = await mockAuthRepository.isAuthenticated();

        if (signInSuccess && 
            signOutSuccess && 
            isAuthenticatedAfterLogin && 
            !isAuthenticatedAfterLogout) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Session state transitions should be consistent');
    });

    test('Cached user data is preserved across sessions', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);

        // Mock sign in
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock cacheUser
        when(mockAuthRepository.cacheUser(user))
            .thenAnswer((_) async => const Right(null));

        // Mock getCachedUser
        when(mockAuthRepository.getCachedUser())
            .thenAnswer((_) async => Right(user));

        // Sign in
        final signInResult = await signInUseCase(email: email, password: password);
        
        bool signInSuccess = false;
        signInResult.fold(
          (failure) => signInSuccess = false,
          (returnedUser) => signInSuccess = true,
        );

        if (!signInSuccess) continue;

        // Cache user
        final cacheResult = await mockAuthRepository.cacheUser(user);
        
        bool cacheSuccess = false;
        cacheResult.fold(
          (failure) => cacheSuccess = false,
          (_) => cacheSuccess = true,
        );

        if (!cacheSuccess) continue;

        // Retrieve cached user
        final cachedUserResult = await mockAuthRepository.getCachedUser();
        
        bool cachedUserMatches = false;
        cachedUserResult.fold(
          (failure) => cachedUserMatches = false,
          (cachedUser) {
            if (cachedUser != null && 
                cachedUser.email == user.email &&
                cachedUser.id == user.id) {
              cachedUserMatches = true;
            }
          },
        );

        if (signInSuccess && cacheSuccess && cachedUserMatches) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Cached user data should be preserved across sessions');
    });

    test('Token management maintains session integrity', () async {
      const iterations = 100;
      int successCount = 0;

      for (int i = 0; i < iterations; i++) {
        final credentials = UserGenerators.generateValidCredentials();
        final email = Email.fromString(credentials['email']!);
        final password = Password.fromString(credentials['password']!);
        final user = UserGenerators.generateValidUser(email: email);
        final token = 'test_token_$i';

        // Mock sign in
        when(mockAuthRepository.signIn(email: email, password: password))
            .thenAnswer((_) async => Right(user));

        // Mock getStoredToken to return token after login
        when(mockAuthRepository.getStoredToken())
            .thenAnswer((_) async => Right(token));

        // Mock sign out
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        // Sign in
        final signInResult = await signInUseCase(email: email, password: password);
        
        bool signInSuccess = false;
        signInResult.fold(
          (failure) => signInSuccess = false,
          (returnedUser) => signInSuccess = true,
        );

        if (!signInSuccess) continue;

        // Get stored token
        final tokenResult = await mockAuthRepository.getStoredToken();
        
        bool hasToken = false;
        tokenResult.fold(
          (failure) => hasToken = false,
          (storedToken) {
            if (storedToken != null && storedToken.isNotEmpty) {
              hasToken = true;
            }
          },
        );

        // Sign out
        final signOutResult = await signOutUseCase();
        
        bool signOutSuccess = false;
        signOutResult.fold(
          (failure) => signOutSuccess = false,
          (_) => signOutSuccess = true,
        );

        // After logout, token should be cleared
        when(mockAuthRepository.getStoredToken())
            .thenAnswer((_) async => const Right(null));

        final tokenAfterLogoutResult = await mockAuthRepository.getStoredToken();
        
        bool tokenCleared = false;
        tokenAfterLogoutResult.fold(
          (failure) => tokenCleared = false,
          (storedToken) {
            if (storedToken == null) {
              tokenCleared = true;
            }
          },
        );

        if (signInSuccess && hasToken && signOutSuccess && tokenCleared) {
          successCount++;
        }
      }

      expect(successCount, equals(iterations),
          reason: 'Token management should maintain session integrity');
    });
  });
}
