import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_event.dart';
import '../bloc/sign_in/sign_in_state.dart';

/// SignIn screen using reusable widgets for consistent UI.
///
/// Follows SOLID principles by delegating UI concerns to specialized widgets.
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

                  // Header using reusable AuthHeader widget
                  const AuthHeader(
                    title: AppStrings.signInTitle,
                    subtitle: AppStrings.signInSubtitle,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Form fields using BlocBuilder for state
                  BlocBuilder<SignInBloc, SignInState>(
                    buildWhen: (previous, current) =>
                        previous.emailError != current.emailError ||
                        previous.passwordError != current.passwordError,
                    builder: (context, state) {
                      return Column(
                        children: [
                          // Email field using LabeledFormField
                          LabeledFormField(
                            label: AppStrings.emailLabel,
                            hint: AppStrings.emailHint,
                            errorText: state.emailError,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            onChanged: (value) {
                              context
                                  .read<SignInBloc>()
                                  .add(SignInEmailChanged(value));
                            },
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Password field using LabeledFormField
                          LabeledFormField(
                            label: AppStrings.passwordLabel,
                            hint: AppStrings.passwordHint,
                            errorText: state.passwordError,
                            controller: _passwordController,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            prefixIcon: Icons.lock_outlined,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              context
                                  .read<SignInBloc>()
                                  .add(SignInPasswordChanged(value));
                            },
                            onSubmitted: (_) {
                              final bloc = context.read<SignInBloc>();
                              if (bloc.state.isFormValid) {
                                bloc.add(const SignInSubmitted());
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Sign In button
                  BlocBuilder<SignInBloc, SignInState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: AppStrings.signInButton,
                        isLoading: state.status == SignInStatus.loading,
                        onPressed: state.isFormValid
                            ? () {
                                context
                                    .read<SignInBloc>()
                                    .add(const SignInSubmitted());
                              }
                            : null,
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Sign up link using reusable AuthLinkRow widget
                  AuthLinkRow(
                    message: AppStrings.noAccountText,
                    linkText: AppStrings.signUpLink,
                    onTap: () => context.go('/sign-up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
