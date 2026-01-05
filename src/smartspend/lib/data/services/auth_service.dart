import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email & password
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('✅ Login erfolgreich: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login Fehler: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Login Fehler: $e');
      return false;
    }
  }

  // Sign up with email & password
  Future<bool> signup(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      debugPrint('✅ Registrierung erfolgreich: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Registrierung Fehler: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Registrierung Fehler: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ Password Reset Email gesendet an: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password Reset Fehler: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Password Reset Fehler: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Logout erfolgreich');
    } catch (e) {
      debugPrint('❌ Logout Fehler: $e');
    }
  }

  // Restore session (nicht nötig bei Firebase, wird automatisch gemacht)
  void restoreSession(String user) {
    // Firebase handhabt Session automatisch
    debugPrint('Firebase Session wird automatisch verwaltet');
  }
}