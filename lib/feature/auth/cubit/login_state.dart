import '../model/user_login.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserLogin userLogin;
  LoginSuccess(this.userLogin);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}