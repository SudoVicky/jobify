import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/auth/auth_bloc.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch LogoutEvent
              BlocProvider.of<AuthBloc>(context).authRepository.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to Notifications Page!"),
      ),
    );
  }
}
