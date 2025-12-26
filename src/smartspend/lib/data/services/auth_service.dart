import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock authentication state
  bool _isAuthenticated = false;
  String? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;

  // Restore session from persistent storage
  void restoreSession(String user) {
    _isAuthenticated = true;
    _currentUser = user;
  }

  // Mock login method
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _currentUser = email;
      return true;
    }
    return false;
  }

  // Mock signup method
  Future<bool> signup(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _currentUser = email;
      return true;
    }
    return false;
  }

  // Mock password reset method
  Future<bool> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isNotEmpty) {
      debugPrint('Password reset email sent to: $email');
      return true;
    }
    return false;
  }

  // Logout method
  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
  }
}
