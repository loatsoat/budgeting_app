import 'package:flutter/material.dart';
import '../../../widgets/widgets/animated_background.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

enum AuthScreenType { login, signup, forgot }

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthScreenType _currentScreen = AuthScreenType.login;

  void _switchScreen(AuthScreenType type) {
    setState(() {
      _currentScreen = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AuthScreenType.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onAuthSuccess: widget.onAuthSuccess,
          onSwitchToSignup: () => _switchScreen(AuthScreenType.signup),
          onSwitchToForgot: () => _switchScreen(AuthScreenType.forgot),
        );
      case AuthScreenType.signup:
        return SignupScreen(
          key: const ValueKey('signup'),
          onAuthSuccess: widget.onAuthSuccess,
          onBackToLogin: () => _switchScreen(AuthScreenType.login),
        );
      case AuthScreenType.forgot:
        return ForgotPasswordScreen(
          key: const ValueKey('forgot'),
          onBackToLogin: () => _switchScreen(AuthScreenType.login),
        );
    }
  }
}
