import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'widgets/simple_auth_wrapper.dart';

void main() {
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
      home: const SimpleAuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}