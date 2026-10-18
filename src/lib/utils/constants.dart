import 'package:flutter/material.dart';

/// App-wide constants for consistency
class AppConstants {
  // ==========================================
  // ANIMATION DURATIONS
  // ==========================================
  static const Duration screenTransitionDuration = Duration(milliseconds: 300);
  static const Duration rotationAnimationDuration = Duration(seconds: 20);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // ==========================================
  // BUDGET DEFAULTS
  // ==========================================
  static const double defaultTotalBudget = 1000.0;
  static const double defaultRentBudget = 200.0;
  static const double defaultGymBudget = 10.0;
  static const double defaultGroceriesBudget = 30.0;
  static const double defaultSavingsBudget = 0.0;

  // ==========================================
  // TAB NAMES
  // ==========================================
  static const String overviewTab = 'overview';
  static const String budgetTab = 'budget';
  static const String goalsTab = 'goals';
  static const String settingsTab = 'settings';

  // ==========================================
  // CATEGORY KEYS
  // ==========================================
  static const String housingCategory = 'housing';
  static const String foodCategory = 'food';
  static const String savingsCategory = 'savings';
  static const String transportCategory = 'transport';
  static const String entertainmentCategory = 'entertainment';

  // ==========================================
  // SHARED PREFERENCES KEYS
  // ==========================================
  static const String bankCardConnectedKey = 'bank_card_connected';
  static const String userBudgetDataKey = 'user_budget_data';

  // ==========================================
  // UI DIMENSIONS
  // ==========================================
  static const double cardBorderRadius = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // ==========================================
  // COLORS (complementing app_theme.dart)
  // ==========================================
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1A1F3A);

  // ==========================================
  // MOCK DATA / TEST TRANSACTIONS
  // ==========================================
  static const List<Map<String, dynamic>> mockBankTransactions = [
    {
      'id': '1',
      'type': 'expense',
      'amount': 45.99,
      'category': 'Groceries',
      'categoryKey': 'food',
      'note': 'Weekly groceries',
      'daysAgo': 0,
      'merchant': 'Whole Foods Market',
    },
    {
      'id': '2',
      'type': 'expense',
      'amount': 32.50,
      'category': 'Transport',
      'categoryKey': 'transport',
      'note': 'Gas',
      'daysAgo': 1,
      'merchant': 'Shell Station',
    },
    {
      'id': '3',
      'type': 'expense',
      'amount': 120.00,
      'category': 'Entertainment',
      'categoryKey': 'entertainment',
      'note': 'Movie tickets',
      'daysAgo': 2,
      'merchant': 'Cinema ABC',
    },
  ];
}
