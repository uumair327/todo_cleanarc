import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_event.dart';
import '../bloc/sign_up/sign_up_state.dart';

/// SignUp screen using reusable widgets for consistent UI.
///
/// Follows SOLID principles by delegating UI concerns to specialized widgets.
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
              // Navigate to email verification screen
              context.go(
                  '/email-verification?email=${Uri.encodeComponent(state.email)}');
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

                  // Header using reusable AuthHeader widget
                  const AuthHeader(
                    title: AppStrings.signUpTitle,
                    subtitle: AppStrings.signUpSubtitle,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Form fields using BlocBuilder for state
                  BlocBuilder<SignUpBloc, SignUpState>(
                    buildWhen: (previous, current) =>
                        previous.emailError != current.emailError ||
                        previous.passwordError != current.passwordError ||
                        previous.confirmPasswordError !=
                            current.confirmPasswordError,
                    builder: (context, state) {
                      return Column(
                        children: [
                          // Email field
                          LabeledFormField(
                            label: AppStrings.emailLabel,
                            hint: AppStrings.emailHint,
                            errorText: state.emailError,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            onChanged: (value) {
                              context
                                  .read<SignUpBloc>()
                                  .add(SignUpEmailChanged(value));
                            },
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Password field
                          LabeledFormField(
                            label: AppStrings.passwordLabel,
                            hint: AppStrings.passwordHint,
                            errorText: state.passwordError,
                            controller: _passwordController,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            prefixIcon: Icons.lock_outlined,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              context
                                  .read<SignUpBloc>()
                                  .add(SignUpPasswordChanged(value));
                            },
                          ),

                          // Password strength indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            PasswordStrengthIndicator(
                              password: _passwordController.text,
                            ),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          // Confirm password field
                          LabeledFormField(
                            label: AppStrings.confirmPasswordLabel,
                            hint: AppStrings.confirmPasswordHint,
                            errorText: state.confirmPasswordError,
                            controller: _confirmPasswordController,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            prefixIcon: Icons.lock_outlined,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              context
                                  .read<SignUpBloc>()
                                  .add(SignUpConfirmPasswordChanged(value));
                            },
                            onSubmitted: (_) {
                              final bloc = context.read<SignUpBloc>();
                              if (bloc.state.isFormValid) {
                                bloc.add(const SignUpSubmitted());
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Sign Up button
                  BlocBuilder<SignUpBloc, SignUpState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: AppStrings.signUpButton,
                        isLoading: state.status == SignUpStatus.loading,
                        onPressed: state.isFormValid
                            ? () {
                                context
                                    .read<SignUpBloc>()
                                    .add(const SignUpSubmitted());
                              }
                            : null,
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Sign in link using reusable AuthLinkRow widget
                  AuthLinkRow(
                    message: AppStrings.alreadyHaveAccountText,
                    linkText: AppStrings.signInLink,
                    onTap: () => context.go('/sign-in'),
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
