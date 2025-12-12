import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class HiveAuthDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();
  Future<bool> hasStoredUser();
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
}

class HiveAuthDataSourceImpl implements HiveAuthDataSource {
  static const String _userBoxName = 'user';
  static const String _authBoxName = 'auth';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  
  Box<UserModel>? _userBox;
  Box<String>? _authBox;

  Future<Box<UserModel>> get userBox async {
    _userBox ??= await Hive.openBox<UserModel>(_userBoxName);
    return _userBox!;
  }

  Future<Box<String>> get authBox async {
    _authBox ??= await Hive.openBox<String>(_authBoxName);
    return _authBox!;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final box = await userBox;
      return box.get(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get current user: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final box = await userBox;
      await box.put(_userKey, user);
    } catch (e) {
      throw CacheException(message: 'Failed to save user: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      final box = await userBox;
      await box.delete(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user: $e');
    }
  }

  @override
  Future<bool> hasStoredUser() async {
    try {
      final box = await userBox;
      return box.containsKey(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to check stored user: $e');
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      final box = await authBox;
      await box.put(_tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      final box = await authBox;
      return box.get(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get auth token: $e');
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      final box = await authBox;
      await box.delete(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth token: $e');
    }
  }
}