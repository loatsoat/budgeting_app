import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'themes/app_theme.dart';
import 'widgets/simple_auth_wrapper.dart';

void main() async {
  // Firebase initialisieren
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase erfolgreich verbunden!');
  } catch (e) {
    print('❌ Firebase Fehler: $e');
  }
  
  runApp(const HCIApp());
}

class HCIApp extends StatelessWidget {
  const HCIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpend Budget App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SimpleAuthWrapper(), // Now requires authentication first!
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Prüfe Firebase Status
    bool isFirebaseConnected = Firebase.apps.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSpend'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Firebase Status Icon
            Icon(
              isFirebaseConnected ? Icons.cloud_done : Icons.cloud_off,
              size: 80,
              color: isFirebaseConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              isFirebaseConnected 
                ? '✅ Firebase Connected!' 
                : '❌ Firebase Not Connected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isFirebaseConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            if (isFirebaseConnected) ...[
              Text(
                'Project: ${Firebase.app().options.projectId}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Storage: smartspend-f94b7.firebasestorage.app',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Ready Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '✅ Firebase Authentication\n'
                      '✅ Cloud Firestore Database\n'
                      '✅ Real-time Data Sync\n'
                      '✅ User Management\n'
                      '✅ Secure Storage',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}