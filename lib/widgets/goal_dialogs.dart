import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import 'create_goal_dialog.dart';
import 'add_money_dialog.dart';
import 'edit_goal_dialog.dart';

void showCreateGoalDialog(
  BuildContext context,
  Function(SavingsGoal) onGoalCreated,
) {
  showDialog(
    context: context,
    builder: (context) => CreateGoalDialog(onGoalCreated: onGoalCreated),
  );
}

void showAddMoneyDialog(
  BuildContext context,
  SavingsGoal goal,
  Function(double) onMoneyAdded,
) {
  showDialog(
    context: context,
    builder: (context) =>
        AddMoneyDialog(goal: goal, onMoneyAdded: onMoneyAdded),
  );
}

void showEditGoalDialog(
  BuildContext context,
  SavingsGoal goal, {
  required Function(SavingsGoal) onGoalUpdated,
  required VoidCallback onGoalDeleted,
}) {
  showDialog(
    context: context,
    builder: (context) => EditGoalDialog(
      goal: goal,
      onGoalUpdated: onGoalUpdated,
      onGoalDeleted: onGoalDeleted,
    ),
  );
}
