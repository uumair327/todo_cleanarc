import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_colors.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_event.dart';
import '../bloc/sign_up/sign_up_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.status == SignUpStatus.success) {
              // Navigate to dashboard or sign in screen
              context.go('/dashboard');
            } else if (state.status == SignUpStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Sign up failed'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSignUpForm(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSignUpButton(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSignInLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign up to get started with your task management',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomTextField(
              label: 'Email Address',
              hint: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) => state.emailError,
              onChanged: (value) {
                context.read<SignUpBloc>().add(SignUpEmailChanged(value));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.lock_outlined),
              validator: (value) => state.passwordError,
              onChanged: (value) {
                context.read<SignUpBloc>().add(SignUpPasswordChanged(value));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outlined),
              validator: (value) => state.confirmPasswordError,
              onChanged: (value) {
                context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(value));
              },
              onSubmitted: (_) {
                if (state.isFormValid) {
                  context.read<SignUpBloc>().add(const SignUpSubmitted());
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return PrimaryButton(
          text: 'Create Account',
          isLoading: state.status == SignUpStatus.loading,
          onPressed: state.isFormValid
              ? () {
                  context.read<SignUpBloc>().add(const SignUpSubmitted());
                }
              : null,
        );
      },
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextCustomButton(
            text: 'Sign In',
            onPressed: () {
              context.go('/sign-in');
            },
          ),
        ],
      ),
    );
  }
}