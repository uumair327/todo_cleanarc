import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:todo_cleanarc/feature/auth/domain/usecases/sign_in_usecase.dart';
import 'package:todo_cleanarc/feature/auth/domain/entities/user_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/email.dart';

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
    id: UserId.fromString('123'),
    email: Email.fromString(testEmail),
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignInBloc', () {
    test('initial state should be SignInState with initial status', () {
      expect(bloc.state, equals(const SignInState()));
    });

    blocTest<SignInBloc, SignInState>(
      'should update email when SignInEmailChanged is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignInEmailChanged(testEmail)),
      expect: () => [
        isA<SignInState>()
            .having((s) => s.email, 'email', testEmail)
            .having((s) => s.emailError, 'emailError', null),
      ],
    );

    blocTest<SignInBloc, SignInState>(
      'should update password when SignInPasswordChanged is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignInPasswordChanged(testPassword)),
      expect: () => [
        isA<SignInState>()
            .having((s) => s.password, 'password', testPassword)
            .having((s) => s.passwordError, 'passwordError', null),
      ],
    );

    blocTest<SignInBloc, SignInState>(
      'should emit [loading, success] when sign in is successful',
      build: () {
        when(mockSignInUseCase.call(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenAnswer((_) async => Right(testUser));
        return bloc;
      },
      seed: () => SignInState(
        email: testEmail,
        password: testPassword,
        isFormValid: true,
      ),
      act: (bloc) => bloc.add(const SignInSubmitted()),
      expect: () => [
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.loading),
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.success)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<SignInBloc, SignInState>(
      'should emit [loading, failure] when credentials are invalid',
      build: () {
        when(mockSignInUseCase.call(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenAnswer((_) async => const Left(
                AuthenticationFailure(message: 'Invalid credentials')));
        return bloc;
      },
      seed: () => SignInState(
        email: testEmail,
        password: testPassword,
        isFormValid: true,
      ),
      act: (bloc) => bloc.add(const SignInSubmitted()),
      expect: () => [
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.loading),
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.failure)
            .having(
                (s) => s.errorMessage, 'errorMessage', 'Invalid credentials'),
      ],
    );

    blocTest<SignInBloc, SignInState>(
      'should emit [loading, failure] when network error occurs',
      build: () {
        when(mockSignInUseCase.call(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenAnswer((_) async =>
                const Left(NetworkFailure(message: 'No internet connection')));
        return bloc;
      },
      seed: () => SignInState(
        email: testEmail,
        password: testPassword,
        isFormValid: true,
      ),
      act: (bloc) => bloc.add(const SignInSubmitted()),
      expect: () => [
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.loading),
        isA<SignInState>()
            .having((s) => s.status, 'status', SignInStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                'No internet connection'),
      ],
    );
  });
}
