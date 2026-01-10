import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_theme.dart';
import 'widgets/simple_auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light icons (white)
      statusBarBrightness: Brightness.dark, // For iOS
    ),
  );
  
  runApp(const HCIApp());
}

class HCIApp extends StatelessWidget {
  const HCIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for dark background
        statusBarBrightness: Brightness.dark, // For iOS
        systemNavigationBarColor: Color(0xFF0A0E1A), // Match app background
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'SmartSpend Budget App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SimpleAuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}