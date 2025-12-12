import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_colors.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_event.dart';
import '../bloc/sign_in/sign_in_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state.status == SignInStatus.success) {
              // Navigate to dashboard
              context.go('/dashboard');
            } else if (state.status == SignInStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Sign in failed'),
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
                  _buildSignInForm(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSignInButton(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSignUpLink(),
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
          'Welcome Back',
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in to continue managing your tasks',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return BlocBuilder<SignInBloc, SignInState>(
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
                context.read<SignInBloc>().add(SignInEmailChanged(value));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outlined),
              validator: (value) => state.passwordError,
              onChanged: (value) {
                context.read<SignInBloc>().add(SignInPasswordChanged(value));
              },
              onSubmitted: (_) {
                if (state.isFormValid) {
                  context.read<SignInBloc>().add(const SignInSubmitted());
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignInButton() {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return PrimaryButton(
          text: 'Sign In',
          isLoading: state.status == SignInStatus.loading,
          onPressed: state.isFormValid
              ? () {
                  context.read<SignInBloc>().add(const SignInSubmitted());
                }
              : null,
        );
      },
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextCustomButton(
            text: 'Sign Up',
            onPressed: () {
              context.go('/sign-up');
            },
          ),
        ],
      ),
    );
  }
}