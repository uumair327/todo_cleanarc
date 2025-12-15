import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class SupabaseAuthDataSource {
  Future<UserModel> signUp(String email, String password);
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> deleteAccount();
  Stream<AuthState> get authStateChanges;
  Future<String?> getAccessToken();
  Future<void> refreshSession();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient _client;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  SupabaseAuthDataSourceImpl(this._client);

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          if (e is AuthException) {
            throw AuthenticationException(message: e.message);
          } else if (e is SocketException || e.toString().contains('network')) {
            throw NetworkException(message: 'Network error: $e');
          } else {
            throw ServerException(message: 'Server error: $e');
          }
        }
        await Future.delayed(_retryDelay * attempts);
      }
    }
    throw ServerException(message: 'Max retries exceeded');
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    return _executeWithRetry(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthenticationException(message: 'Failed to create user account');
      }

      // User profile is created automatically by database trigger
      // Wait a moment for the trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Fetch the user profile created by the trigger
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userProfile != null) {
        return UserModel.fromJson(userProfile);
      }

      // Fallback: create profile manually if trigger didn't work
      final newProfile = {
        'id': response.user!.id,
        'email': response.user!.email!,
        'display_name': response.user!.email!.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await _client.from('users').insert(newProfile);
      } catch (e) {
        // Profile might already exist from trigger, ignore error
      }

      return UserModel.fromJson(newProfile);
    });
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    return _executeWithRetry(() async {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthenticationException(message: 'Invalid email or password');
      }

      // Get user profile from the users table
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userProfile);
    });
  }

  @override
  Future<void> signOut() async {
    return _executeWithRetry(() async {
      await _client.auth.signOut();
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Get user profile from the users table
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return userProfile != null ? UserModel.fromJson(userProfile) : null;
    } catch (e) {
      // Don't retry for getCurrentUser as it might be called frequently
      if (e is PostgrestException) {
        throw ServerException(message: 'Database error: ${e.message}');
      } else if (e is SocketException || e.toString().contains('network')) {
        throw NetworkException(message: 'Network error: $e');
      } else {
        throw ServerException(message: 'Server error: $e');
      }
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = _client.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    return _executeWithRetry(() async {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(message: 'No authenticated user found');
      }

      // Delete user data from tasks table
      await _client
          .from('tasks')
          .delete()
          .eq('user_id', user.id);

      // Delete user profile
      await _client
          .from('users')
          .delete()
          .eq('id', user.id);

      // Delete the auth user (this requires admin privileges in production)
      // In a real app, you'd typically call an edge function or admin API
      await _client.auth.admin.deleteUser(user.id);
    });
  }

  @override
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final session = _client.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshSession() async {
    return _executeWithRetry(() async {
      await _client.auth.refreshSession();
    });
  }
}