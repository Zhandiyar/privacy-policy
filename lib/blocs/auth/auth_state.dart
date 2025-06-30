import 'package:equatable/equatable.dart';

abstract class AuthState  extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class AuthLoggedOut extends AuthState {}
class PasswordResetEmailSent extends AuthState {}

class PasswordResetSuccess extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);

  @override
  List<Object> get props => [token];
}

class TokenValid extends AuthState {}

class TokenInvalid extends AuthState {
  final String message;
  TokenInvalid(this.message);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);

  @override
  List<Object> get props => [message];
}
