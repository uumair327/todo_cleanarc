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
  bool _obscurePassword = true;

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
            if (state.status == SignInStatus.success && state.user != null) {
              // Notify AuthBloc about the authenticated user
              context.read<AuthBloc>().add(AuthUserChanged(state.user!));
              // Navigate to dashboard
              context.go('/dashboard');
            } else if (state.status == SignInStatus.failure) {
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
          AppStrings.signInTitle,
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.signInSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) =>
          previous.emailError != current.emailError ||
          previous.passwordError != current.passwordError,
      builder: (context, state) {
        // Update error text after bloc state changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });

        return Column(
          children: [
            _buildEmailField(state),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(state),
          ],
        );
      },
    );
  }

  Widget _buildEmailField(SignInState state) {
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
            context.read<SignInBloc>().add(SignInEmailChanged(value));
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

  Widget _buildPasswordField(SignInState state) {
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
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            context.read<SignInBloc>().add(SignInPasswordChanged(value));
          },
          onFieldSubmitted: (_) {
            final state = context.read<SignInBloc>().state;
            if (state.isFormValid) {
              context.read<SignInBloc>().add(const SignInSubmitted());
            }
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

  Widget _buildSignInButton() {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return PrimaryButton(
          text: AppStrings.signInButton,
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
            AppStrings.noAccountText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextCustomButton(
            text: AppStrings.signUpLink,
            onPressed: () {
              context.go('/sign-up');
            },
          ),
        ],
      ),
    );
  }
}
