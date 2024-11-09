import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    // on<AuthResetEvent>(_onAuthReset);
  }
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthLoginSuccess(message: 'Login successful!'));
    } catch (e) {
      emit(AuthFailure(error: 'Login error: ${e.toString()}'));
    }
  }

  // Handler for RegisterEvent
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        // Call createUserPreferences to set up the user's preferences document
        await authRepository.createUserPreferences(user.uid);
      }
      authRepository.signOut();
      emit(AuthRegisterSuccess(message: 'Registration successful!'));
    } catch (e) {
      // Ensure this captures specific error
      emit(AuthFailure(error: 'Registration error: ${e.toString()}'));
      debugPrint("Registration error: $e");
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository
          .signOut(); // Make sure you have this method in your AuthRepository
      emit(AuthInitial()); // Emitting AuthInitial state to signify logout
    } catch (e) {
      emit(AuthFailure(error: 'Logout error: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAlreadyExistSuccess(
            message: 'Already logged in as ${user.email}'));
      } else {
        emit(AuthInitial());
      }

      // Assume this method checks for a logged-in user
    } catch (e) {
      debugPrint("OnCheckAuthSTatus error: ${e.toString()}");
      emit(AuthFailure(
          error: 'Error checking authentication status: ${e.toString()}'));
    }
  }
}
