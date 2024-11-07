import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String message;

  AuthLoginSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthRegisterSuccess extends AuthState {
  final String message;

  AuthRegisterSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class AuthAlreadyExistSuccess extends AuthState {
  final String message;

  AuthAlreadyExistSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
