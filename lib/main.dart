import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/auth/auth_bloc.dart';
import 'package:jobify/bloc/auth/auth_event.dart';
import 'package:jobify/bloc/auth/auth_state.dart';
import 'package:jobify/bloc/category/category_bloc.dart';
import 'package:jobify/repositories/auth_repository.dart';
import 'package:jobify/screens/login_page.dart';
import 'package:jobify/screens/main_screen.dart';
import 'package:jobify/screens/notification_page.dart';
import 'package:jobify/screens/preferences_page.dart';
import 'package:jobify/screens/register_page.dart';
import 'package:jobify/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobify/widgets/custom_overlay.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository())
            ..add(CheckAuthStatusEvent()), // Trigger the check on startup
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(authRepository: AuthRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthLoading,
              child: Builder(
                builder: (context) {
                  if (state is AuthAlreadyExistSuccess) {
                    debugPrint("Inside authlogin checking!");
                    return const MainScreen(); // User is logged in
                  } else {
                    return const LoginPage();
                  }
                },
              ),
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => RegisterPage(),
          '/notifications': (context) => const NotificationPage(),
          '/preferences': (context) => const PreferencesPage(),
          '/main_screen': (context) => const MainScreen(),
        },
      ),
    );
  }
}
