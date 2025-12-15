import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      // Get the current session
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // User is authenticated, trigger auth check
        context.read<AuthBloc>().add(const AuthCheckRequested());
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        
        // Navigate to dashboard
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        // No session, redirect to sign in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verification failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.go('/sign-in');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/sign-in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Verifying your email...',
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}