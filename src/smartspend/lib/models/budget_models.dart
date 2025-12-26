import 'package:flutter/material.dart';

// Transaction Model
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String categoryKey;
  final String note;
  final DateTime date;
  final bool excludeFromBudget;
  final String? merchant;
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryKey,
    required this.note,
    required this.date,
    this.excludeFromBudget = false,
    this.merchant,
    this.description,
  });
}

enum TransactionType { expense, income, transfer }

// Category Model
class CategoryData {
  final String name;
  final List<Color> gradientColors;
  final Color solidColor;
  final Color glowColor;
  final String icon;
  final List<String> subcategories;

  CategoryData({
    required this.name,
    required this.gradientColors,
    required this.solidColor,
    required this.glowColor,
    required this.icon,
    required this.subcategories,
  });
}

// Subcategory Budget Model
class SubcategoryBudget {
  final double budgeted;
  double spent;

  SubcategoryBudget({required this.budgeted, required this.spent});
}

// Default Categories Configuration
final Map<String, CategoryData> defaultCategories = {
  'income': CategoryData(
    name: 'Income',
    gradientColors: [
      const Color(0xFF00F5FF),
      const Color(0xFF00D4FF),
      const Color(0xFF00B8FF),
    ],
    solidColor: const Color(0xFF00F5FF),
    glowColor: const Color(0xFF00F5FF).withValues(alpha: 0.6),
    icon: '💰',
    subcategories: ['Income'],
  ),
  'housing': CategoryData(
    name: 'Housing',
    gradientColors: [
      const Color(0xFFFF6B9D),
      const Color(0xFFFE5196),
      const Color(0xFFFF3D8F),
    ],
    solidColor: const Color(0xFFFF6B9D),
    glowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
    icon: '🏠',
    subcategories: [
      'Rent',
      'Telephone',
      'Insurance',
      'Electricity',
      'Gym',
      'Internet',
      'Subscription',
    ],
  ),
  'food': CategoryData(
    name: 'Food',
    gradientColors: [
      const Color(0xFFA855F7),
      const Color(0xFF9333EA),
      const Color(0xFF7E22CE),
    ],
    solidColor: const Color(0xFFA855F7),
    glowColor: const Color(0xFFA855F7).withValues(alpha: 0.6),
    icon: '🍽️',
    subcategories: ['Groceries', 'Restaurant'],
  ),
  'transport': CategoryData(
    name: 'Transport',
    gradientColors: [
      const Color(0xFF3B82F6),
      const Color(0xFF2563EB),
      const Color(0xFF1D4ED8),
    ],
    solidColor: const Color(0xFF3B82F6),
    glowColor: const Color(0xFF3B82F6).withValues(alpha: 0.6),
    icon: '🚗',
    subcategories: ['Gas', 'Public Transport', 'Parking'],
  ),
  'entertainment': CategoryData(
    name: 'Entertainment',
    gradientColors: [
      const Color(0xFFEF4444),
      const Color(0xFFDC2626),
      const Color(0xFFB91C1C),
    ],
    solidColor: const Color(0xFFEF4444),
    glowColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
    icon: '🎬',
    subcategories: ['Movies', 'Games', 'Events'],
  ),
  'savings': CategoryData(
    name: 'Savings',
    gradientColors: [
      const Color(0xFF10F4B1),
      const Color(0xFF00E396),
      const Color(0xFF00D084),
    ],
    solidColor: const Color(0xFF10F4B1),
    glowColor: const Color(0xFF10F4B1).withValues(alpha: 0.6),
    icon: '🐷',
    subcategories: ['Emergency funds', 'Vacation fund'],
  ),
};
