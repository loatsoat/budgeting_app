import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

enum SimpleAuthState { authenticated, unauthenticated }

class SimpleAuthManager extends ChangeNotifier {
  static SimpleAuthManager? _instance;
  static SimpleAuthManager get instance => _instance ??= SimpleAuthManager._();
  SimpleAuthManager._();

  SimpleAuthState _authState = SimpleAuthState.unauthenticated;
  String? _currentUser;

  SimpleAuthState get authState => _authState;
  String? get currentUser => _currentUser;
  bool get isAuthenticated => _authState == SimpleAuthState.authenticated;

  Future<bool> login(String email, String password) async {
    final authService = AuthService();
    final success = await authService.login(email, password);
    
    if (success) {
      _currentUser = email;
      _authState = SimpleAuthState.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    final authService = AuthService();
    final success = await authService.signup(name, email, password);
    
    if (success) {
      _currentUser = email;
      _authState = SimpleAuthState.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    final authService = AuthService();
    authService.logout();
    
    _currentUser = null;
    _authState = SimpleAuthState.unauthenticated;
    notifyListeners();
  }
}