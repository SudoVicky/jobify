import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/auth/auth_bloc.dart';
import 'package:jobify/bloc/auth/auth_event.dart';
import 'package:jobify/bloc/auth/auth_state.dart';
import 'package:jobify/widgets/Text_input.dart';
import 'package:jobify/widgets/bottom_sheet.dart';
import 'package:jobify/widgets/button.dart';
import 'package:jobify/widgets/custom_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      BottomSheetUtil.show(context, "Enter email.");
      return;
    } else if (!_validEmail(email)) {
      BottomSheetUtil.show(context, "Enter valid email.");
      return;
    } else if (password.isEmpty) {
      BottomSheetUtil.show(context, "Enter password");
      return;
    }

    BlocProvider.of<AuthBloc>(context)
        .add(LoginEvent(email: email, password: password));
  }

  bool _validEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            debugPrint("Came to login and then to notification");
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main_screen',
              (Route<dynamic> route) => false, // Removes all previous routes
            );
            BottomSheetUtil.show(context, state.message);
          } else if (state is AuthFailure) {
            BottomSheetUtil.show(context, state.error);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            bool isLoading = state is AuthLoading;

            return LoadingOverlay(
              isLoading: isLoading,
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
                      "Welcome back, you've been missed!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextInput(
                      hintText: 'Email',
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 10),
                    TextInput(
                      hintText: 'Password',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: isLoading ? "Logging in..." : "Login",
                      onTap: isLoading ? null : () => _login(context),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a member? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _emailController.clear();
                            _passwordController.clear();
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "Register now",
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
