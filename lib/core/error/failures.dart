import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
  
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class AuthenticationFailure extends Failure {}

class ValidationFailure extends Failure {
  final String message;
  
  const ValidationFailure(this.message);
  
  @override
  List<Object> get props => [message];
}