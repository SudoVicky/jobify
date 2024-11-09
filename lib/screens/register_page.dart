import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/auth/auth_bloc.dart';
import 'package:jobify/bloc/auth/auth_event.dart';
import 'package:jobify/bloc/auth/auth_state.dart';
import 'package:jobify/widgets/Text_input.dart';
import 'package:jobify/widgets/bottom_sheet.dart';
import 'package:jobify/widgets/button.dart';
import 'package:jobify/widgets/loading_overlay.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      BottomSheetUtil.show(context, "Enter email.");
      return;
    } else if (!_validEmail(email)) {
      BottomSheetUtil.show(context, "Enter valid email.");
      return;
    } else if (password.isEmpty) {
      BottomSheetUtil.show(context, "Enter password");
      return;
    } else if (password.length < 8) {
      BottomSheetUtil.show(
          context, "Password must be at least 8 characters long.");
      return;
    } else if (confirmPassword.isEmpty) {
      BottomSheetUtil.show(context, "Enter confirm password");
      return;
    }
    if (password != confirmPassword) {
      BottomSheetUtil.show(context, "Password not matched");
      return;
    }

    // Dispatch RegisterEvent if passwords match
    BlocProvider.of<AuthBloc>(context)
        .add(RegisterEvent(email: email, password: password));
  }

  bool _validEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            debugPrint("Loading...");
          } else if (state is AuthRegisterSuccess) {
            debugPrint("Success: ${state.message}");
            BottomSheetUtil.show(context, state.message);
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            });
          } else if (state is AuthFailure) {
            debugPrint("Failure: ${state.error}");
            BottomSheetUtil.show(context, state.error); // Show error message
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            bool isLoading = state is AuthLoading;

            return LoadingOverlay(
              isLoading: isLoading, // Wrap content with LoadingOverlay
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Let's create an account for you",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextInput(
                      hintText: "Email",
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 10),
                    TextInput(
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    TextInput(
                      hintText: "Confirm password",
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Register",
                      onTap: () => _register(context),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Login now",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
