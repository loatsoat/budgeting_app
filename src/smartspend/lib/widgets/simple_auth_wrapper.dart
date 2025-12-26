import 'package:flutter/material.dart';
import '../services/simple_auth_manager.dart';
import '../screens/screens/auth/auth_screen.dart';
import '../screens/screens/budget/app_budget.dart';

class SimpleAuthWrapper extends StatefulWidget {
  const SimpleAuthWrapper({super.key});

  @override
  State<SimpleAuthWrapper> createState() => _SimpleAuthWrapperState();
}

class _SimpleAuthWrapperState extends State<SimpleAuthWrapper> {
  late SimpleAuthManager _authManager;

  @override
  void initState() {
    super.initState();
    _authManager = SimpleAuthManager.instance;
    _authManager.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAuthSuccess() {
    // Auth state will be updated by the manager
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_authManager.isAuthenticated) {
      return const BudgetApp(key: ValueKey('budget_app'));
    } else {
      return AuthScreen(
        key: const ValueKey('auth_screen'),
        onAuthSuccess: _onAuthSuccess,
      );
    }
  }
}