import '../models/budget_models.dart';

class SpendingRecommendation {
  final String title;
  final String message;
  final RecommendationType type;
  final String? action;
  final double? relatedAmount;

  SpendingRecommendation({
    required this.title,
    required this.message,
    required this.type,
    this.action,
    this.relatedAmount,
  });
}

enum RecommendationType { warning, positive, insight, alert }

class SpendingRecommendationsService {
  /// Generate smart spending recommendations based on transaction history
  static List<SpendingRecommendation> generateRecommendations({
    required List<Transaction> transactions,
    required Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
    required double totalBudget,
    required double totalIncome,
  }) {
    final recommendations = <SpendingRecommendation>[];

    // Get current month data
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final thisMonthTransactions = transactions.where((t) {
      final inMonth =
          !t.date.isBefore(thisMonthStart) && t.date.isBefore(nextMonthStart);
      return inMonth;
    }).toList();

    // Get last month data for comparison
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthTransactions = transactions.where((t) {
      final inMonth =
          !t.date.isBefore(lastMonthStart) && t.date.isBefore(thisMonthStart);
      return inMonth;
    }).toList();

    // 1. Budget Overspending Alerts
    recommendations.addAll(_checkBudgetOverspending(categoryBudgets));

    // 2. Category Spending Increase Warnings
    recommendations.addAll(
      _checkCategoryIncreases(
        thisMonthTransactions,
        lastMonthTransactions,
        categoryBudgets,
      ),
    );

    // 3. Positive Saving Insights
    recommendations.addAll(
      _checkSavingsTrends(
        thisMonthTransactions,
        lastMonthTransactions,
        totalBudget,
      ),
    );

    // 4. Budget Remaining Analysis
    recommendations.addAll(
      _checkBudgetRemaining(categoryBudgets, totalBudget, totalIncome),
    );

    // 5. High Spending Categories
    recommendations.addAll(_checkHighSpendingCategories(thisMonthTransactions));

    // Sort by importance (warnings first, then insights)
    recommendations.sort((a, b) {
      const priority = {
        RecommendationType.alert: 0,
        RecommendationType.warning: 1,
        RecommendationType.insight: 2,
        RecommendationType.positive: 3,
      };
      return (priority[a.type] ?? 99).compareTo(priority[b.type] ?? 99);
    });

    // Return top 3-5 recommendations
    return recommendations.take(5).toList();
  }

  /// Check which categories have exceeded their budgets
  static List<SpendingRecommendation> _checkBudgetOverspending(
    Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
  ) {
    final recommendations = <SpendingRecommendation>[];

    categoryBudgets.forEach((categoryKey, subcategories) {
      // Calculate category totals
      double categoryTotalBudgeted = 0;
      double categoryTotalSpent = 0;

      subcategories.forEach((subcategoryName, budget) {
        categoryTotalBudgeted += budget.budgeted;
        categoryTotalSpent += budget.spent;

        // Check individual subcategory overages
        if (budget.budgeted > 0 && budget.spent > budget.budgeted) {
          final overage = budget.spent - budget.budgeted;
          final percentage = ((budget.spent / budget.budgeted) - 1) * 100;

          recommendations.add(
            SpendingRecommendation(
              title: 'Subcategory Alert: $subcategoryName',
              message:
                  'You\'ve exceeded your $subcategoryName budget by €${overage.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}% over).',
              type: RecommendationType.alert,
              relatedAmount: overage,
            ),
          );
        }
      });

      // Check category-level overages
      if (categoryTotalBudgeted > 0 &&
          categoryTotalSpent > categoryTotalBudgeted) {
        final overage = categoryTotalSpent - categoryTotalBudgeted;
        final percentage =
            ((categoryTotalSpent / categoryTotalBudgeted) - 1) * 100;

        recommendations.add(
          SpendingRecommendation(
            title: 'Category Budget Exceeded: $categoryKey',
            message:
                'Your total $categoryKey spending exceeded budget by €${overage.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}% over).',
            type: RecommendationType.alert,
            relatedAmount: overage,
          ),
        );
      }
    });

    return recommendations;
  }

  /// Check for spending increases compared to last month
  static List<SpendingRecommendation> _checkCategoryIncreases(
    List<Transaction> thisMonth,
    List<Transaction> lastMonth,
    Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
  ) {
    final recommendations = <SpendingRecommendation>[];

    categoryBudgets.forEach((categoryKey, _) {
      final thisMonthSpending = thisMonth
          .where(
            (t) =>
                t.categoryKey == categoryKey &&
                t.type == TransactionType.expense,
          )
          .fold<double>(0, (sum, t) => sum + t.amount);

      final lastMonthSpending = lastMonth
          .where(
            (t) =>
                t.categoryKey == categoryKey &&
                t.type == TransactionType.expense,
          )
          .fold<double>(0, (sum, t) => sum + t.amount);

      if (lastMonthSpending > 0) {
        final increase =
            ((thisMonthSpending - lastMonthSpending) / lastMonthSpending) * 100;

        if (increase > 25) {
          // 25% increase threshold
          recommendations.add(
            SpendingRecommendation(
              title: 'Spending Increase: $categoryKey',
              message:
                  'Your $categoryKey spending increased by ${increase.toStringAsFixed(0)}% compared to last month (€${thisMonthSpending.toStringAsFixed(2)} vs €${lastMonthSpending.toStringAsFixed(2)}).',
              type: RecommendationType.warning,
              relatedAmount: thisMonthSpending - lastMonthSpending,
            ),
          );
        }
      }
    });

    return recommendations;
  }

  /// Check if user is on track to save money
  static List<SpendingRecommendation> _checkSavingsTrends(
    List<Transaction> thisMonth,
    List<Transaction> lastMonth,
    double totalBudget,
  ) {
    final recommendations = <SpendingRecommendation>[];

    final thisMonthExpenses = thisMonth
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final lastMonthExpenses = lastMonth
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Check if spending decreased
    if (lastMonthExpenses > 0 && thisMonthExpenses < lastMonthExpenses) {
      final savings = lastMonthExpenses - thisMonthExpenses;
      final percentage = (savings / lastMonthExpenses) * 100;

      recommendations.add(
        SpendingRecommendation(
          title: 'Great Job! 🎉',
          message:
              'You\'ve reduced your spending by €${savings.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%) compared to last month!',
          type: RecommendationType.positive,
          relatedAmount: savings,
        ),
      );
    }

    return recommendations;
  }

  /// Analyze remaining budget
  static List<SpendingRecommendation> _checkBudgetRemaining(
    Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
    double totalBudget,
    double totalIncome,
  ) {
    final recommendations = <SpendingRecommendation>[];

    final totalSpent = categoryBudgets.values.fold<double>(0, (sum, subcats) {
      return sum + subcats.values.fold<double>(0, (s, b) => s + b.spent);
    });

    final budgetLeft = totalBudget - totalSpent;
    final percentageUsed = (totalSpent / totalBudget) * 100;

    // Alert if budget is almost exhausted
    if (percentageUsed > 85 && percentageUsed < 100) {
      recommendations.add(
        SpendingRecommendation(
          title: 'Budget Running Low',
          message:
              'You\'ve used ${percentageUsed.toStringAsFixed(0)}% of your monthly budget. Only €${budgetLeft.toStringAsFixed(2)} remaining.',
          type: RecommendationType.warning,
          relatedAmount: budgetLeft,
        ),
      );
    } else if (percentageUsed >= 100) {
      final overspent = totalSpent - totalBudget;
      recommendations.add(
        SpendingRecommendation(
          title: 'Budget Exceeded',
          message:
              'You\'ve exceeded your budget by €${overspent.toStringAsFixed(2)}. Consider cutting back on expenses.',
          type: RecommendationType.alert,
          relatedAmount: overspent,
        ),
      );
    }

    return recommendations;
  }

  /// Identify categories with the highest spending
  static List<SpendingRecommendation> _checkHighSpendingCategories(
    List<Transaction> thisMonth,
  ) {
    final recommendations = <SpendingRecommendation>[];

    final categoryTotals = <String, double>{};
    for (var transaction in thisMonth) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.categoryKey] =
            (categoryTotals[transaction.categoryKey] ?? 0) + transaction.amount;
      }
    }

    if (categoryTotals.isEmpty) return recommendations;

    // Find the top spending category
    final topCategory = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final totalSpent = categoryTotals.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );
    final percentageOfTotal = (topCategory.value / totalSpent) * 100;

    if (percentageOfTotal > 40) {
      recommendations.add(
        SpendingRecommendation(
          title: 'High Spending: ${topCategory.key}',
          message:
              '${topCategory.key.toUpperCase()} accounts for ${percentageOfTotal.toStringAsFixed(0)}% of your spending this month. Consider if this aligns with your goals.',
          type: RecommendationType.insight,
          relatedAmount: topCategory.value,
        ),
      );
    }

    return recommendations;
  }
}
