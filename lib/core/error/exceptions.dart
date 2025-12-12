class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthenticationException implements Exception {}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
}