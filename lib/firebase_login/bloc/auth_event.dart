part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested(this.email, this.password);
}

class tokenSignInRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class KakaoSignInRequested extends AuthEvent {}

class NaverSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}