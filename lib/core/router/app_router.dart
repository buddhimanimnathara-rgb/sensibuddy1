import 'package:flutter/material.dart';

import '../../features/home/home_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';

import '../../modules/authentication/frogot_password/frogot_password_screen.dart';
import '../../modules/authentication/frogot_pin/frogot_pin_screen.dart';
import '../../screens/child_registration/child_registration_screen.dart';

import '../../modules/authentication/login/login_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    /// Splash
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

    /// Welcome
      case '/welcome':
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

    /// Login
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) =>
          const ForgotPasswordScreen(),
        );

      case '/forgot-pin':
        return MaterialPageRoute(
          builder: (_) => const ForgotPinScreen(),
        );

    /// Child Registration
      case '/child-registration':
        return MaterialPageRoute(
          builder: (_) => const ChildRegistrationScreen(),
        );

    /// Assessment
      case '/assessment':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "Assessment requires childId",
              ),
            ),
          ),
        );

    /// Home
      case '/home':

        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(

          builder: (_) => HomeScreen(

            childId: args["childId"],

            guardianId: args["guardianId"],

          ),

        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("404"),
            ),
            body: const Center(
              child: Text(
                "Route Not Found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
    }
  }
}

