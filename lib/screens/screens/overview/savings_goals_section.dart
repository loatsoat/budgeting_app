import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import '../../../widgets/goal_dialogs.dart';
import '../../../widgets/savings_goal_card.dart';
import 'overview_colors.dart';

/// Savings goals carousel on the overview: create, add money, edit and delete goals.
class SavingsGoalsSection extends StatelessWidget {
  final List<SavingsGoal> goals;
  final Function(SavingsGoal)? onGoalCreated;
  final Function(SavingsGoal)? onGoalUpdated;
  final Function(SavingsGoal)? onGoalDeleted;
  final Function(Transaction)? onTransactionAdded;

  const SavingsGoalsSection({
    super.key,
    required this.goals,
    this.onGoalCreated,
    this.onGoalUpdated,
    this.onGoalDeleted,
    this.onTransactionAdded,
  });

  // Money put into a goal is booked as an expense that is excluded from the
  // budget, so it shows in the history without eating the spendable amount.
  void _recordSaving(SavingsGoal goal, double amount) {
    goal.currentAmount += amount;
    onGoalUpdated?.call(goal);
    onTransactionAdded?.call(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.expense,
        amount: amount,
        category: 'Savings',
        categoryKey: 'savings',
        note: 'Saved for ${goal.name}',
        date: DateTime.now(),
        excludeFromBudget: true,
        description: 'Added to savings goal: ${goal.name}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A3B5C),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.savings, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SAVINGS GOALS',
                    style: TextStyle(
                      color: OverviewColors.white90,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (onGoalCreated != null) {
                    showCreateGoalDialog(context, onGoalCreated!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3B5C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF5B8DEF),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Color(0xFF5B8DEF), size: 18),
                      SizedBox(width: 4),
                      Text(
                        'New Goal',
                        style: TextStyle(
                          color: Color(0xFF5B8DEF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (goals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: OverviewColors.white05,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: OverviewColors.white10),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.track_changes,
                    size: 48,
                    color: OverviewColors.white30,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Goals Yet',
                    style: TextStyle(
                      color: OverviewColors.white80,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a savings goal to start tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OverviewColors.white50,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: goals.length,
                padEnds: false,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SavingsGoalCard(
                      goal: goal,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1F33),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                border: Border.fromBorderSide(
                                  BorderSide(color: OverviewColors.white10),
                                ),
                              ),
                              child: SafeArea(
                                top: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                      ),
                                      title: const Text(
                                        'Add Money',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        showAddMoneyDialog(context, goal, (
                                          amount,
                                        ) {
                                          _recordSaving(goal, amount);
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      title: const Text(
                                        'Edit Goal',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        showEditGoalDialog(
                                          context,
                                          goal,
                                          onGoalUpdated: (g) =>
                                              onGoalUpdated?.call(g),
                                          onGoalDeleted: () =>
                                              onGoalDeleted?.call(goal),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFFF4D67),
                                      ),
                                      title: const Text(
                                        'Delete Goal',
                                        style: TextStyle(
                                          color: Color(0xFFFF4D67),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        showEditGoalDialog(
                                          context,
                                          goal,
                                          onGoalUpdated: (g) =>
                                              onGoalUpdated?.call(g),
                                          onGoalDeleted: () =>
                                              onGoalDeleted?.call(goal),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      onAddMoney: () {
                        showAddMoneyDialog(context, goal, (amount) {
                          // Update the goal
                          _recordSaving(goal, amount);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added €${amount.toStringAsFixed(0)} to ${goal.name}',
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
