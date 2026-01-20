import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
<<<<<<< HEAD
            if (state.status == SignUpStatus.success && state.user != null) {
              // Notify AuthBloc about the authenticated user
              context.read<AuthBloc>().add(AuthUserChanged(state.user!));
              // Navigate to dashboard
              context.go('/dashboard');
=======
            if (state.status == SignUpStatus.success) {
              // Navigate to email verification screen
              context.go('/email-verification?email=${Uri.encodeComponent(state.email)}');
>>>>>>> 35c26355e54afe6023cde3a873a421d55c0cd6c3
            } else if (state.status == SignUpStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.errorMessage ?? AppStrings.unexpectedError),
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
          AppStrings.signUpTitle,
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.signUpSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) =>
          previous.emailError != current.emailError ||
          previous.passwordError != current.passwordError ||
          previous.confirmPasswordError != current.confirmPasswordError,
      builder: (context, state) {
        return Column(
          children: [
            _buildEmailField(state),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(state),
            const SizedBox(height: AppSpacing.lg),
            _buildConfirmPasswordField(state),
          ],
        );
      },
    );
  }

  Widget _buildEmailField(SignUpState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.emailLabel,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpEmailChanged(value));
          },
          decoration: InputDecoration(
            hintText: AppStrings.emailHint,
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: state.emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(SignUpState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.passwordLabel,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpPasswordChanged(value));
          },
          decoration: InputDecoration(
            hintText: AppStrings.passwordHint,
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(SignUpState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.confirmPasswordLabel,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(value));
          },
          onFieldSubmitted: (_) {
            final state = context.read<SignUpBloc>().state;
            if (state.isFormValid) {
              context.read<SignUpBloc>().add(const SignUpSubmitted());
            }
          },
          decoration: InputDecoration(
            hintText: AppStrings.confirmPasswordHint,
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.confirmPasswordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return PrimaryButton(
          text: AppStrings.signUpButton,
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
            AppStrings.alreadyHaveAccountText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextCustomButton(
            text: AppStrings.signInLink,
            onPressed: () {
              context.go('/sign-in');
            },
          ),
        ],
      ),
    );
  }
}
