import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_up/sign_up_event.dart';
import 'package:todo_cleanarc/feature/auth/presentation/bloc/sign_up/sign_up_state.dart';
import 'package:todo_cleanarc/feature/auth/domain/usecases/sign_up_usecase.dart';
import 'package:todo_cleanarc/feature/auth/domain/entities/user_entity.dart';
import 'package:todo_cleanarc/core/error/failures.dart';
import 'package:todo_cleanarc/core/domain/value_objects/user_id.dart';
import 'package:todo_cleanarc/core/domain/value_objects/email.dart';

import 'sign_up_bloc_test.mocks.dart';

@GenerateMocks([SignUpUseCase])
void main() {
  late SignUpBloc bloc;
  late MockSignUpUseCase mockSignUpUseCase;

  setUp(() {
    mockSignUpUseCase = MockSignUpUseCase();
    bloc = SignUpBloc(signUpUseCase: mockSignUpUseCase);
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

  group('SignUpBloc', () {
    test('initial state should be SignUpState with initial status', () {
      expect(bloc.state, equals(const SignUpState()));
    });

    blocTest<SignUpBloc, SignUpState>(
      'should update email when SignUpEmailChanged is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignUpEmailChanged(testEmail)),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.email, 'email', testEmail)
            .having((s) => s.emailError, 'emailError', null),
      ],
    );

    blocTest<SignUpBloc, SignUpState>(
      'should update password when SignUpPasswordChanged is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignUpPasswordChanged(testPassword)),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.password, 'password', testPassword)
            .having((s) => s.passwordError, 'passwordError', null),
      ],
    );

    blocTest<SignUpBloc, SignUpState>(
      'should emit [loading, success] when sign up is successful',
      build: () {
        when(mockSignUpUseCase.call(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenAnswer((_) async => Right(testUser));
        return bloc;
      },
      seed: () => SignUpState(
        email: testEmail,
        password: testPassword,
        confirmPassword: testPassword,
        isFormValid: true,
      ),
      act: (bloc) => bloc.add(const SignUpSubmitted()),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.status, 'status', SignUpStatus.loading),
        isA<SignUpState>()
            .having((s) => s.status, 'status', SignUpStatus.success)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<SignUpBloc, SignUpState>(
      'should emit [loading, failure] when sign up fails',
      build: () {
        when(mockSignUpUseCase.call(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenAnswer((_) async => const Left(
                AuthenticationFailure(message: 'Email already exists')));
        return bloc;
      },
      seed: () => SignUpState(
        email: testEmail,
        password: testPassword,
        confirmPassword: testPassword,
        isFormValid: true,
      ),
      act: (bloc) => bloc.add(const SignUpSubmitted()),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.status, 'status', SignUpStatus.loading),
        isA<SignUpState>()
            .having((s) => s.status, 'status', SignUpStatus.failure)
            .having(
                (s) => s.errorMessage, 'errorMessage', 'Email already exists'),
      ],
    );

    blocTest<SignUpBloc, SignUpState>(
      'should validate email format',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignUpEmailChanged('invalid-email')),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.email, 'email', 'invalid-email')
            .having((s) => s.emailError, 'emailError', isNotNull),
      ],
    );

    blocTest<SignUpBloc, SignUpState>(
      'should validate password length',
      build: () => bloc,
      act: (bloc) => bloc.add(const SignUpPasswordChanged('short')),
      expect: () => [
        isA<SignUpState>()
            .having((s) => s.password, 'password', 'short')
            .having((s) => s.passwordError, 'passwordError', isNotNull),
      ],
    );
  });
}
