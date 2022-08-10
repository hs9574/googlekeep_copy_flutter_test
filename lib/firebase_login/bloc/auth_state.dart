part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class Loading extends AuthState {
  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class UnAuthenticated extends AuthState {
  final String error;

  UnAuthenticated({this.error = ''});

  @override
  List<Object?> get props => [];
}