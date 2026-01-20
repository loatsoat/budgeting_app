import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../data/database.dart';

class SimpleUser {
  final int id;
  final String username;
  final DateTime createdAt;

  SimpleUser({
    required this.id,
    required this.username,
    required this.createdAt,
  });
}

class SimpleAuthManager extends ChangeNotifier {
  static final SimpleAuthManager _instance = SimpleAuthManager._internal();
  static SimpleAuthManager get instance => _instance;

  SimpleUser? _currentUser;
  late final AppDatabase _db;

  SimpleAuthManager._internal() {
    _db = AppDatabase();
    _loadSession();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Get current user
  SimpleUser? get currentUser => _currentUser;

  // Get current user email (using username for compatibility)
  String? get currentUserEmail => _currentUser?.username;

  // Get current user name
  String? get currentUserName => _currentUser?.username;

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Load session from SharedPreferences
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final username = prefs.getString('username');
      final createdAtStr = prefs.getString('created_at');

      if (userId != null && username != null && createdAtStr != null) {
        _currentUser = SimpleUser(
          id: userId,
          username: username,
          createdAt: DateTime.parse(createdAtStr),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Fehler beim Laden der Session: $e');
    }
  }

  // Login with username & password
  Future<bool> login(String username, String password) async {
    try {
      final trimmedUsername = username.trim();

      if (trimmedUsername.isEmpty) {
        throw Exception('Bitte Benutzername eingeben');
      }

      if (password.isEmpty) {
        throw Exception('Bitte Passwort eingeben');
      }

      final passwordHash = _hashPassword(password);
      final user = await _db.validateLogin(trimmedUsername, passwordHash);

      if (user == null) {
        throw Exception('Benutzername oder Passwort falsch');
      }

      _currentUser = SimpleUser(
        id: user.id,
        username: user.username,
        createdAt: user.createdAt,
      );

      await _saveAuthState();
      debugPrint('✅ Login erfolgreich: ${user.username}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Login Fehler: $e');
      rethrow;
    }
  }

  // Sign up with username, password, and security question
  Future<bool> signup(
    String username,
    String password,
    String securityQuestion,
    String securityAnswer,
  ) async {
    try {
      debugPrint('🔄 Starte Registrierung für: $username');

      final trimmedUsername = username.trim();
      final trimmedAnswer = securityAnswer.trim();

      if (trimmedUsername.isEmpty) {
        throw Exception('Bitte Benutzername eingeben');
      }

      if (trimmedUsername.length < 3) {
        throw Exception('Benutzername muss mindestens 3 Zeichen haben');
      }

      if (password.length < 6) {
        throw Exception('Passwort muss mindestens 6 Zeichen haben');
      }

      if (securityQuestion.isEmpty) {
        throw Exception('Bitte Sicherheitsfrage auswählen');
      }

      if (trimmedAnswer.isEmpty) {
        throw Exception('Bitte Antwort auf Sicherheitsfrage eingeben');
      }

      // Check if username already exists
      final exists = await _db.usernameExists(trimmedUsername);
      if (exists) {
        throw Exception('Benutzername bereits vergeben');
      }

      // Hash password, security answer, and create user
      final passwordHash = _hashPassword(password);
      final answerHash = _hashPassword(trimmedAnswer.toLowerCase());
      await _db.createUser(
        trimmedUsername,
        passwordHash,
        securityQuestion,
        answerHash,
      );

      // Get the created user
      final user = await _db.getUserByUsername(trimmedUsername);
      if (user == null) {
        throw Exception('Fehler beim Erstellen des Benutzers');
      }

      // Don't auto-login after signup
      debugPrint('✅ Account erfolgreich erstellt');
      return true;
    } catch (e) {
      debugPrint('❌ Registrierung Fehler: $e');
      rethrow;
    }
  }

  // Get security question for username
  Future<String> getSecurityQuestion(String username) async {
    try {
      final trimmedUsername = username.trim();

      final user = await _db.getUserByUsername(trimmedUsername);
      if (user == null) {
        throw Exception('Kein Benutzer mit diesem Namen gefunden');
      }

      return user.securityQuestion;
    } catch (e) {
      debugPrint('❌ Fehler beim Abrufen der Sicherheitsfrage: $e');
      rethrow;
    }
  }

  // Verify security answer and reset password
  Future<bool> resetPasswordWithSecurityAnswer(
    String username,
    String securityAnswer,
    String newPassword,
  ) async {
    try {
      final trimmedUsername = username.trim();
      final trimmedAnswer = securityAnswer.trim();

      if (newPassword.length < 6) {
        throw Exception('Neues Passwort muss mindestens 6 Zeichen haben');
      }

      // Hash the answer and validate
      final answerHash = _hashPassword(trimmedAnswer.toLowerCase());
      final isValid = await _db.validateSecurityAnswer(
        trimmedUsername,
        answerHash,
      );

      if (!isValid) {
        throw Exception('Falsche Antwort auf Sicherheitsfrage');
      }

      // Update password
      final newPasswordHash = _hashPassword(newPassword);
      await _db.updatePassword(trimmedUsername, newPasswordHash);

      debugPrint('✅ Passwort erfolgreich zurückgesetzt');
      return true;
    } catch (e) {
      debugPrint('❌ Password Reset Fehler: $e');
      rethrow;
    }
  }

  // Verify password for current user (used in settings)
  Future<bool> verifyPassword(String username, String password) async {
    try {
      final passwordHash = _hashPassword(password);
      final user = await _db.validateLogin(username, passwordHash);
      return user != null;
    } catch (e) {
      debugPrint('❌ Password Verification Fehler: $e');
      return false;
    }
  }

  // Change password (requires current password verification first)
  Future<bool> changePassword(String username, String newPassword) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Neues Passwort muss mindestens 6 Zeichen haben');
      }

      final newPasswordHash = _hashPassword(newPassword);
      await _db.updatePassword(username, newPasswordHash);

      debugPrint('✅ Passwort erfolgreich geändert');
      return true;
    } catch (e) {
      debugPrint('❌ Password Change Fehler: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _currentUser = null;
      await _clearAuthState();
      debugPrint('✅ Logout erfolgreich');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Logout Fehler: $e');
    }
  }

  // Helper methods for persistence
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setInt('user_id', _currentUser!.id);
      await prefs.setString('username', _currentUser!.username);
      await prefs.setString(
        'created_at',
        _currentUser!.createdAt.toIso8601String(),
      );
    }
  }

  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('created_at');
  }
}
