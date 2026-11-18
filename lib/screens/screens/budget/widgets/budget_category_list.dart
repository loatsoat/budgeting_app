import 'package:flutter/material.dart';
import '../../../../models/budget_models.dart';

/// Budget tab's category list: header with edit/add actions, then one
/// expandable card per category showing its subcategories or savings goals.
class BudgetCategoryList extends StatelessWidget {
  final Map<String, CategoryData> categories;
  final Map<String, Map<String, SubcategoryBudget>> categoryBudgets;
  final List<SavingsGoal> savingsGoals;
  final List<Transaction> transactions;
  final List<String> expandedCategories;
  final bool isEditing;
  final double totalBudget;
  final double totalBudgeted;
  final VoidCallback onEditToggle;
  final VoidCallback onAddCategory;
  final ValueChanged<String> onToggleExpanded;

  const BudgetCategoryList({
    super.key,
    required this.categories,
    required this.categoryBudgets,
    required this.savingsGoals,
    required this.transactions,
    required this.expandedCategories,
    required this.isEditing,
    required this.totalBudget,
    required this.totalBudgeted,
    required this.onEditToggle,
    required this.onAddCategory,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final entries = categoryBudgets.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${totalBudgeted.toStringAsFixed(0)} / €${totalBudget.toStringAsFixed(0)} budgeted',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 250, 250, 251),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Button
                IconButton(
                  onPressed: onEditToggle,
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: const Color(0xFF5B8DEF),
                    size: 24,
                  ),
                ),
                // Add Category Button (only in edit mode)
                if (isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF0D47A1),
                    ),
                    onPressed: onAddCategory,
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) {
          final categoryKey = entry.key;
          final subcategories = entry.value;
          final categoryData = categories[categoryKey];

          if (categoryData == null) return const SizedBox.shrink();

          final isExpanded = expandedCategories.contains(categoryKey);
          final categorySpent = subcategories.values.fold<double>(
            0,
            (s, b) => s + b.spent,
          );
          final categoryBudgeted = subcategories.values.fold<double>(
            0,
            (s, b) => s + b.budgeted,
          );

          // Calculate display values - use savings goals for savings category
          double displaySpent = categorySpent;
          double displayBudgeted = categoryBudgeted;

          if (categoryKey == 'savings') {
            displaySpent = savingsGoals.fold(
              0,
              (sum, goal) => sum + goal.currentAmount,
            );
            displayBudgeted = savingsGoals.fold(
              0,
              (sum, goal) => sum + (goal.targetAmount / goal.durationMonths),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2A3B5C).withValues(alpha: 0.8),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => onToggleExpanded(categoryKey),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: categoryData.solidColor.withValues(
                              alpha: 0.18,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              categoryData.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryData.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '€${displaySpent.toStringAsFixed(0)} / €${displayBudgeted.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: displaySpent > displayBudgeted
                                      ? const Color.fromARGB(255, 253, 252, 252)
                                      : categoryData.solidColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Column(
                    children: categoryKey == 'savings'
                        ? savingsGoals
                              .map(
                                (goal) => _buildSavingsGoalItem(
                                  goal,
                                  categoryData.solidColor,
                                ),
                              )
                              .toList()
                        : subcategories.entries
                              .map(
                                (e) => _buildSubcategoryItem(
                                  e.key,
                                  e.value,
                                  categoryData.solidColor,
                                ),
                              )
                              .toList(),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSavingsGoalItem(SavingsGoal goal, Color categoryColor) {
    final percentage = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount) * 100
        : 0.0;

    // Track how much landed in this goal this month for extra context
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final monthlyContribution = transactions
        .where((t) {
          final inMonth =
              !t.date.isBefore(monthStart) && t.date.isBefore(nextMonthStart);
          final isSavings = t.categoryKey == 'savings';
          final matchesGoal = t.category == goal.name;
          return inMonth &&
              isSavings &&
              matchesGoal &&
              t.type == TransactionType.expense;
        })
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(goal.emoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: percentage >= 100
                                ? Colors.green
                                : goal.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '€${goal.currentAmount.toStringAsFixed(0)} / €${(goal.targetAmount / goal.durationMonths).toStringAsFixed(0)}',
                  style: TextStyle(
                    color: goal.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        if (monthlyContribution > 0)
          Padding(
            padding: const EdgeInsets.only(left: 64, bottom: 8),
            child: Text(
              'This month: +€${monthlyContribution.toStringAsFixed(0)} of €${goal.monthlyAmount.toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubcategoryItem(
    String subcategoryName,
    SubcategoryBudget budget,
    Color categoryColor,
  ) {
    final percentage = budget.budgeted > 0
        ? (budget.spent / budget.budgeted) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 64),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategoryName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: percentage > 90
                            ? const Color.fromARGB(255, 250, 249, 249)
                            : categoryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '€${budget.spent.toStringAsFixed(0)} / €${budget.budgeted.toStringAsFixed(0)}',
              style: TextStyle(
                color: categoryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
