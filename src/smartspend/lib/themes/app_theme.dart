import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // SMARTSPEND DESIGN SYSTEM
  // ==========================================
  
  // PRIMARY ACCENT COLOR (single color for consistency)
  // Use for: main actions, key highlights, important UI elements
  static const Color primaryAccent = Color(0xFF00A8E8); // Calm, trustworthy blue
  
  // BACKGROUND COLORS (dark theme for finance apps)
  static const Color backgroundDark = Color(0xFF0A0E1A); // Deep navy
  static const Color surfaceDark = Color(0xFF1A1F3A); // Card background
  static const Color surfaceMedium = Color(0xFF2A3B5C); // Elevated cards
  
  // TEXT COLORS
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textTertiary = Color(0x99FFFFFF); // 60% white
  static const Color textMuted = Color(0x66FFFFFF); // 40% white
  
  // STATUS COLORS (semantic colors for financial status)
  static const Color statusSuccess = Color(0xFF4CAF50); // Green - positive, under budget
  static const Color statusWarning = Color(0xFFFF9800); // Orange - warning, close to limit
  static const Color statusDanger = Color(0xFFE57373); // Red - negative, over budget
  
  // NEUTRAL COLORS
  static const Color borderColor = Color(0x1AFFFFFF); // 10% white
  static const Color dividerColor = Color(0x0DFFFFFF); // 5% white
  
  // LEGACY COLORS (for backwards compatibility - gradually replace)
  static const Color primaryColor = Color(0xFF030213);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color secondaryColor = Color(0xFFF2F2F7);
  static const Color mutedColor = Color(0xFFECECF0);
  static const Color mutedForegroundColor = Color(0xFF717182);
  static const Color accentColor = Color(0xFFE9EBEF);
  static const Color destructiveColor = Color(0xFFD4183D);
  static const Color inputBackgroundColor = Color(0xFFF3F3F5);
  static const Color switchBackgroundColor = Color(0xFFCBCED4);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF252525);
  static const Color darkCardColor = Color(0xFF252525);
  static const Color darkPrimaryColor = Color(0xFFFBFBFB);
  static const Color darkSecondaryColor = Color(0xFF454545);
  static const Color darkMutedColor = Color(0xFF454545);
  static const Color darkMutedForegroundColor = Color(0xFFB5B5B5);
  static const Color darkAccentColor = Color(0xFF454545);
  static const Color darkBorderColor = Color(0xFF454545);
  
  // ==========================================
  // HELPER METHODS
  // ==========================================
  
  /// Returns the appropriate status color based on budget percentage
  /// percentage: 0-100+ (where 100 = at budget limit)
  static Color getStatusColor(double percentage) {
    if (percentage > 100) return statusDanger; // Over budget
    if (percentage > 80) return statusWarning; // Close to limit
    return statusSuccess; // Under budget
  }
  
  /// Returns color for text based on financial value (positive/negative)
  static Color getAmountColor(double amount) {
    if (amount < 0) return statusDanger;
    if (amount > 0) return statusSuccess;
    return textSecondary;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: borderColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: primaryColor,
        surface: backgroundColor,
        onSurface: primaryColor,
        error: destructiveColor,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mutedForegroundColor,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      dividerColor: darkBorderColor,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        onPrimary: Color(0xFF353535),
        secondary: darkSecondaryColor,
        onSecondary: darkPrimaryColor,
        surface: darkBackgroundColor,
        onSurface: darkPrimaryColor,
        error: destructiveColor,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkPrimaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: const Color(0xFF353535),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSecondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkMutedForegroundColor,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkPrimaryColor,
        ),
      ),
    );
  }
}