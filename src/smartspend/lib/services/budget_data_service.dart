import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class BudgetDataService {
  static const String _keyPrefix = 'user_';

  // Save budget data for a specific user
  static Future<void> saveBudgetData({
    required int userId,
    required double totalBudget,
    required List<Transaction> transactions,
    required Map<String, CategoryData> categories,
    required Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
    List<SavingsGoal>? savingsGoals,
    bool budgetEqualsIncome = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '$_keyPrefix${userId}_';

      // Save total budget
      await prefs.setDouble('${userKey}totalBudget', totalBudget);
      
      // Save budgetEqualsIncome flag
      await prefs.setBool('${userKey}budgetEqualsIncome', budgetEqualsIncome);

      // Save transactions
      final transactionsJson = transactions.map((t) => {
        'id': t.id,
        'type': t.type.toString(),
        'amount': t.amount,
        'category': t.category,
        'categoryKey': t.categoryKey,
        'note': t.note,
        'date': t.date.toIso8601String(),
        'merchant': t.merchant,
        'description': t.description,
        'excludeFromBudget': t.excludeFromBudget,
        'recurrence': t.recurrence.toString(),
        'recurrenceEndDate': t.recurrenceEndDate?.toIso8601String(),
      }).toList();
      await prefs.setString('${userKey}transactions', jsonEncode(transactionsJson));

      // Save category budgets
      Map<String, dynamic> budgetsJson = {};
      categoryBudgets.forEach((categoryKey, subcats) {
        budgetsJson[categoryKey] = {};
        subcats.forEach((subcatKey, budget) {
          budgetsJson[categoryKey][subcatKey] = {
            'budgeted': budget.budgeted,
            'spent': budget.spent,
          };
        });
      });
      await prefs.setString('${userKey}categoryBudgets', jsonEncode(budgetsJson));

      // Save savings goals
      if (savingsGoals != null) {
        final savingsGoalsJson = savingsGoals.map((g) => {
          'id': g.id,
          'name': g.name,
          'targetAmount': g.targetAmount,
          'currentAmount': g.currentAmount,
          'description': g.description,
          'targetDate': g.targetDate?.toIso8601String(),
          'color': g.color.value,
          'emoji': g.emoji,
          'durationMonths': g.durationMonths,
        }).toList();
        await prefs.setString('${userKey}savingsGoals', jsonEncode(savingsGoalsJson));
      }

      debugPrint('✅ Budget data saved for user $userId');
    } catch (e) {
      debugPrint('❌ Error saving budget data: $e');
    }
  }

  // Load budget data for a specific user
  static Future<Map<String, dynamic>?> loadBudgetData(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '$_keyPrefix${userId}_';

      // Load total budget
      final totalBudget = prefs.getDouble('${userKey}totalBudget') ?? 0.0;

      // Load transactions
      final transactionsString = prefs.getString('${userKey}transactions');
      List<Transaction> transactions = [];
      if (transactionsString != null) {
        final List<dynamic> transactionsJson = jsonDecode(transactionsString);
        transactions = transactionsJson.map((t) => Transaction(
          id: t['id'],
          type: TransactionType.values.firstWhere(
            (e) => e.toString() == t['type'],
            orElse: () => TransactionType.expense,
          ),
          amount: t['amount'].toDouble(),
          category: t['category'],
          categoryKey: t['categoryKey'],
          note: t['note'],
          date: DateTime.parse(t['date']),
          merchant: t['merchant'],
          description: t['description'],
          excludeFromBudget: t['excludeFromBudget'] ?? false,
          recurrence: t['recurrence'] != null
              ? RecurrenceType.values.firstWhere(
                  (e) => e.toString() == t['recurrence'],
                  orElse: () => RecurrenceType.never,
                )
              : RecurrenceType.never,
          recurrenceEndDate: t['recurrenceEndDate'] != null
              ? DateTime.parse(t['recurrenceEndDate'])
              : null,
        )).toList();
      }

      // Load category budgets
      final budgetsString = prefs.getString('${userKey}categoryBudgets');
      Map<String, Map<String, SubcategoryBudget>> categoryBudgets = {};
      if (budgetsString != null) {
        final Map<String, dynamic> budgetsJson = jsonDecode(budgetsString);
        budgetsJson.forEach((categoryKey, subcats) {
          categoryBudgets[categoryKey] = {};
          (subcats as Map<String, dynamic>).forEach((subcatKey, budget) {
            categoryBudgets[categoryKey]![subcatKey] = SubcategoryBudget(
              budgeted: budget['budgeted'].toDouble(),
              spent: budget['spent'].toDouble(),
            );
          });
        });
      }

      // Load savings goals
      final savingsGoalsString = prefs.getString('${userKey}savingsGoals');
      List<SavingsGoal> savingsGoals = [];
      if (savingsGoalsString != null) {
        final List<dynamic> savingsGoalsJson = jsonDecode(savingsGoalsString);
        savingsGoals = savingsGoalsJson.map((g) => SavingsGoal(
          id: g['id'],
          name: g['name'],
          targetAmount: g['targetAmount'].toDouble(),
          currentAmount: g['currentAmount']?.toDouble() ?? 0,
          description: g['description'],
          targetDate: g['targetDate'] != null ? DateTime.parse(g['targetDate']) : null,
          color: Color(g['color']),
          emoji: g['emoji'] ?? '🎯',
          durationMonths: (g['durationMonths'] is int)
              ? g['durationMonths']
              : (g['durationMonths'] is double)
                  ? (g['durationMonths'] as double).toInt()
                  : 12,
        )).toList();
      }

      debugPrint('✅ Budget data loaded for user $userId');

      // Load budgetEqualsIncome flag
      final budgetEqualsIncome = prefs.getBool('${userKey}budgetEqualsIncome') ?? false;

      return {
        'totalBudget': totalBudget,
        'transactions': transactions,
        'categoryBudgets': categoryBudgets,
        'savingsGoals': savingsGoals,
        'budgetEqualsIncome': budgetEqualsIncome,
      };
    } catch (e) {
      debugPrint('❌ Error loading budget data: $e');
      return null;
    }
  }

  // Clear budget data for a specific user (optional - for logout)
  static Future<void> clearBudgetData(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '$_keyPrefix${userId}_';

      await prefs.remove('${userKey}totalBudget');
      await prefs.remove('${userKey}transactions');
      await prefs.remove('${userKey}categoryBudgets');
      await prefs.remove('${userKey}savingsGoals');
      await prefs.remove('${userKey}budgetEqualsIncome');

      debugPrint('✅ Budget data cleared for user $userId');
    } catch (e) {
      debugPrint('❌ Error clearing budget data: $e');
    }
  }
}
