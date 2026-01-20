import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/entities/user_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

import 'sign_in_bloc_test.mocks.dart';

@GenerateMocks([SignInUseCase])
void main() {
  late SignInBloc bloc;
  late MockSignInUseCase mockSignInUseCase;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    bloc = SignInBloc(signInUseCase: mockSignInUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserEntity(
    id: '123',
    email: testEmail,
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignInBloc', () {
    test('initial state should be SignInInitial', () {
      expect(bloc.state, equals(SignInInitial()));
    });

    blocTest<SignInBloc, SignInState>(
      'should emit [SignInLoading, SignInSuccess] when sign in is successful',
      build: () {
        when(mockSignInUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignInLoading(),
        SignInSuccess(user: testUser),
      ],
      verify: (_) {
        verify(mockSignInUseCase.call(email: testEmail, password: testPassword));
      },
    );

    blocTest<SignInBloc, SignInState>(
      'should emit [SignInLoading, SignInError] when credentials are invalid',
      build: () {
        when(mockSignInUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignInLoading(),
        const SignInError(message: 'Invalid credentials'),
      ],
      verify: (_) {
        verify(mockSignInUseCase.call(email: testEmail, password: testPassword));
      },
    );

    blocTest<SignInBloc, SignInState>(
      'should emit [SignInLoading, SignInError] when network error occurs',
      build: () {
        when(mockSignInUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => const Left(NetworkFailure(message: 'No internet connection')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignInLoading(),
        const SignInError(message: 'No internet connection'),
      ],
    );
  });
}
