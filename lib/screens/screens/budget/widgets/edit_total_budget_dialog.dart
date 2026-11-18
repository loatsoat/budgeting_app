import 'package:flutter/material.dart';
import '../../../../widgets/components/ui/input.dart';

/// Lets the user set a fixed monthly budget or lock it to income.
/// [onSaved] receives whether the budget follows income and the fixed amount.
void showEditTotalBudgetDialog(
  BuildContext context, {
  required double totalBudget,
  required bool budgetEqualsIncome,
  required double totalIncome,
  required void Function(bool equalsIncome, double budget) onSaved,
}) {
  final controller = TextEditingController(
    text: budgetEqualsIncome ? '' : totalBudget.toStringAsFixed(0),
  );
  bool localBudgetEqualsIncome = budgetEqualsIncome;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
              ),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF0D47A1),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Edit Total Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localBudgetEqualsIncome
                      ? 'Budget is currently set to match your income'
                      : 'Set your monthly budget amount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Toggle switch
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: localBudgetEqualsIncome
                        ? const Color(0xFF0D47A1).withValues(alpha: 0.2)
                        : const Color(0xFF2A3B5C).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: localBudgetEqualsIncome
                          ? const Color(0xFF0D47A1).withValues(alpha: 0.5)
                          : const Color(0xFF0D47A1).withValues(alpha: 0.2),
                      width: localBudgetEqualsIncome ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  localBudgetEqualsIncome
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: localBudgetEqualsIncome
                                      ? const Color(0xFF0D47A1)
                                      : Colors.white.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Budget = Income',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 26),
                              child: Text(
                                localBudgetEqualsIncome
                                    ? 'Budget automatically matches income'
                                    : 'Set a fixed budget amount',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: localBudgetEqualsIncome,
                        onChanged: (value) {
                          setDialogState(() {
                            localBudgetEqualsIncome = value;
                            if (!value && controller.text.isEmpty) {
                              controller.text = totalBudget.toStringAsFixed(0);
                            }
                          });
                        },
                        activeColor: const Color(0xFF0D47A1),
                        activeTrackColor: const Color(
                          0xFF0D47A1,
                        ).withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!localBudgetEqualsIncome)
                  CustomInput(
                    controller: controller,
                    label: 'Budget Amount',
                    labelColor: Colors.white,
                    placeholder: 'Enter amount',
                    keyboardType: TextInputType.number,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF0D47A1),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your budget will automatically match your total income (€${totalIncome.toStringAsFixed(0)})',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (localBudgetEqualsIncome) {
                    onSaved(true, totalBudget);
                    Navigator.of(context).pop();
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        dismissDirection: DismissDirection.horizontal,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        content: const Text(
                          'Budget set to income and locked to your current income.',
                        ),
                        backgroundColor: const Color(0xFF0D47A1),
                        showCloseIcon: true,
                        closeIconColor: Colors.white70,
                      ),
                    );
                  } else {
                    final newBudget = double.tryParse(controller.text);
                    if (newBudget != null && newBudget > 0) {
                      onSaved(false, newBudget);
                      Navigator.of(context).pop();
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          dismissDirection: DismissDirection.horizontal,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          content: Text(
                            'Budget updated to €${newBudget.toStringAsFixed(0)}',
                          ),
                          backgroundColor: const Color(0xFF0D47A1),
                          showCloseIcon: true,
                          closeIconColor: Colors.white70,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: const Color(0xFF1A1F3A),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
