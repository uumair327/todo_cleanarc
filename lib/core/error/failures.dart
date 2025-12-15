import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
  
  /// Get the error message for this failure
  String get message;
  
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  @override
  final String message;
  
  const ServerFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  @override
  final String message;
  
  const CacheFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  @override
  final String message;
  
  const NetworkFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class AuthenticationFailure extends Failure {
  @override
  final String message;
  
  const AuthenticationFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  @override
  final String message;
  
  const ValidationFailure(this.message);
  
  @override
  List<Object> get props => [message];
}