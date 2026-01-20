import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_up/sign_up_event.dart';
import 'package:glimfo_todo/feature/auth/presentation/bloc/sign_up/sign_up_state.dart';
import 'package:glimfo_todo/feature/auth/domain/usecases/sign_up_usecase.dart';
import 'package:glimfo_todo/feature/auth/domain/entities/user_entity.dart';
import 'package:glimfo_todo/core/error/failures.dart';

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
    id: '123',
    email: testEmail,
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  group('SignUpBloc', () {
    test('initial state should be SignUpInitial', () {
      expect(bloc.state, equals(SignUpInitial()));
    });

    blocTest<SignUpBloc, SignUpState>(
      'should emit [SignUpLoading, SignUpSuccess] when sign up is successful',
      build: () {
        when(mockSignUpUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignUpSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignUpLoading(),
        SignUpSuccess(user: testUser),
      ],
      verify: (_) {
        verify(mockSignUpUseCase.call(email: testEmail, password: testPassword));
      },
    );

    blocTest<SignUpBloc, SignUpState>(
      'should emit [SignUpLoading, SignUpError] when sign up fails',
      build: () {
        when(mockSignUpUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => const Left(AuthFailure(message: 'Email already exists')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignUpSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignUpLoading(),
        const SignUpError(message: 'Email already exists'),
      ],
      verify: (_) {
        verify(mockSignUpUseCase.call(email: testEmail, password: testPassword));
      },
    );

    blocTest<SignUpBloc, SignUpState>(
      'should emit [SignUpLoading, SignUpError] when network error occurs',
      build: () {
        when(mockSignUpUseCase.call(email: testEmail, password: testPassword))
            .thenAnswer((_) async => const Left(NetworkFailure(message: 'No internet connection')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignUpSubmitted(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        SignUpLoading(),
        const SignUpError(message: 'No internet connection'),
      ],
    );
  });
}
