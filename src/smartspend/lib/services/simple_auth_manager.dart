import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimpleAuthManager extends ChangeNotifier {
  static final SimpleAuthManager _instance = SimpleAuthManager._internal();
  static SimpleAuthManager get instance => _instance;
  
  SimpleAuthManager._internal() {
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Get current user name
  String? get currentUserName => _auth.currentUser?.displayName;

  // Login with email & password
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('✅ Login erfolgreich: $email');
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login Fehler: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign up with email & password
  // Sign up with email & password
Future<bool> signup(String name, String email, String password) async {
  try {
    debugPrint('🔄 Starte Registrierung für: $email');
    
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    debugPrint('✅ Account erstellt');
    
    // Update display name
    await userCredential.user?.updateDisplayName(name);
    debugPrint('✅ Display Name gesetzt: $name');
    
    // SENDE VERIFIZIERUNGS-EMAIL
    debugPrint('📧 Versuche Verifizierungs-Email zu senden...');
    await userCredential.user?.sendEmailVerification();
    debugPrint('✅ sendEmailVerification() erfolgreich aufgerufen');
    
    // Prüfe User Status
    debugPrint('📊 User Email: ${userCredential.user?.email}');
    debugPrint('📊 Email Verified: ${userCredential.user?.emailVerified}');
    
    notifyListeners();
    return true;
  } on FirebaseAuthException catch (e) {
    debugPrint('❌ Registrierung Fehler: ${e.code} - ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('❌ Unerwarteter Fehler: $e');
    rethrow;
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
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Logout erfolgreich');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Logout Fehler: $e');
    }
  }

  // Restore session (automatisch durch Firebase)
  void restoreSession(String user) {
    // Firebase manages session automatically
    debugPrint('Firebase Session wird automatisch verwaltet');
  }
}