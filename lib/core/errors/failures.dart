import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [];
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure(this.message);

  @override
  String toString() => 'DatabaseFailure: $message';
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  String toString() => 'ValidationFailure: $message';
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

class ServerFailure extends Failure {
  final String message;
  final int? statusCode;

  const ServerFailure(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class AuthenticationFailure extends Failure {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  String toString() => 'AuthenticationFailure: $message';
}

class AuthorizationFailure extends Failure {
  final String message;

  const AuthorizationFailure(this.message);

  @override
  String toString() => 'AuthorizationFailure: $message';
}

class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure(this.message);

  @override
  String toString() => 'NotFoundFailure: $message';
}

class TimeoutFailure extends Failure {
  final String message;

  const TimeoutFailure(this.message);

  @override
  String toString() => 'TimeoutFailure: $message';
}

class UnexpectedFailure extends Failure {
  final String message;
  final dynamic error;

  const UnexpectedFailure(this.message, [this.error]);

  @override
  String toString() => 'UnexpectedFailure: $message${error != null ? ' (Error: $error)' : ''}';
}