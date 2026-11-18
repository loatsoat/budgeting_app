import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import 'transaction_pickers.dart';
import 'recurrence_dialog.dart';
import 'selector_tile.dart';
import 'transaction_form_fields.dart';
import 'confirm_delete_dialog.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;
  final Function(Transaction)? onTransactionUpdated;
  final Function(Transaction)? onTransactionDeleted;
  final Map<String, CategoryData> categories;
  final Map<String, Map<String, SubcategoryBudget>>? categoryBudgets;
  final Transaction? existingTransaction;
  final List<SavingsGoal>? savingsGoals;
  final Function(SavingsGoal)? onGoalUpdated;

  const AddTransactionDialog({
    super.key,
    required this.onTransactionAdded,
    required this.categories,
    this.categoryBudgets,
    this.existingTransaction,
    this.onTransactionUpdated,
    this.onTransactionDeleted,
    this.savingsGoals,
    this.onGoalUpdated,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategoryKey = 'food';
  String? _selectedSubcategoryName;
  DateTime _selectedDate = DateTime.now();
  bool _excludeFromBudget = false;
  RecurrenceType _selectedRecurrence = RecurrenceType.never;
  DateTime? _recurrenceEndDate;
  String? _selectedGoalId;
  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final transaction = widget.existingTransaction!;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note == 'No note'
          ? ''
          : transaction.note;
      _selectedType = transaction.type;
      _selectedCategoryKey = transaction.categoryKey;
      _selectedDate = transaction.date;
      _excludeFromBudget = transaction.excludeFromBudget;
      _selectedRecurrence = transaction.recurrence;
      _recurrenceEndDate = transaction.recurrenceEndDate;

      // Set subcategory name from transaction
      _selectedSubcategoryName = transaction.category;

      // For savings transactions, find and set the corresponding goal
      if (transaction.categoryKey == 'savings' &&
          widget.savingsGoals != null &&
          widget.savingsGoals!.isNotEmpty) {
        final matchingGoal = widget.savingsGoals!.firstWhere(
          (goal) => goal.name == transaction.category,
          orElse: () => widget.savingsGoals!.first,
        );
        _selectedGoalId = matchingGoal.id;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Keep income values positive even if the user typed a leading minus.
    final normalizedAmount = amount.abs();

    // For income transactions, use a generic 'Income' category
    final String categoryName;
    final String categoryKeyValue;

    if (_selectedType == TransactionType.income) {
      categoryName = 'Income';
      categoryKeyValue = 'income';
    } else {
      final categoryData = widget.categories[_selectedCategoryKey];
      if (categoryData == null) return;

      // For savings category, use the goal name as category
      if (_selectedCategoryKey == 'savings' &&
          _selectedGoalId != null &&
          widget.savingsGoals != null) {
        final goal = widget.savingsGoals!.firstWhere(
          (g) => g.id == _selectedGoalId,
          orElse: () => widget.savingsGoals!.first,
        );
        categoryName = goal.name;
      } else {
        // Use subcategory name if selected, otherwise use category name
        categoryName = _selectedSubcategoryName ?? categoryData.name;
      }
      categoryKeyValue = _selectedCategoryKey;
    }

    final transaction = Transaction(
      id: _isEditing
          ? widget.existingTransaction!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      amount: normalizedAmount,
      category: categoryName,
      categoryKey: categoryKeyValue,
      note: _noteController.text.trim().isEmpty
          ? 'No note'
          : _noteController.text.trim(),
      date: _selectedDate,
      excludeFromBudget: _excludeFromBudget,
      recurrence: _selectedRecurrence,
      recurrenceEndDate: _recurrenceEndDate,
    );

    // NOTE: Goal updates are handled in app_budget.dart's _addTransaction and _updateTransaction
    // to avoid double counting

    if (_isEditing) {
      widget.onTransactionUpdated?.call(transaction);
    } else {
      widget.onTransactionAdded(transaction);
    }
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    final transaction = widget.existingTransaction;
    if (transaction == null) return;
    if (!await confirmDeleteTransaction(context) || !mounted) return;
    widget.onTransactionDeleted?.call(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.9;
    final dialogMaxHeight = screenSize.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: SingleChildScrollView(
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2940),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A3B5C)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A2940),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'New transaction',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24), // Balance the close button
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Amount Input
                      AmountField(controller: _amountController),

                      const SizedBox(height: 20),

                      TransactionTypeToggle(
                        selected: _selectedType,
                        // Reset the category so an income never keeps an expense category.
                        onChanged: (type) => setState(() {
                          _selectedType = type;
                          _selectedCategoryKey = type == TransactionType.income
                              ? 'salary'
                              : 'food';
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Category Selector (hidden for income)
                      if (_selectedType != TransactionType.income)
                        _buildCategorySelector(),

                      if (_selectedType != TransactionType.income)
                        const SizedBox(height: 20),

                      // Goal Selector (only for savings category)
                      if (_selectedCategoryKey == 'savings' &&
                          widget.savingsGoals != null &&
                          widget.savingsGoals!.isNotEmpty)
                        _buildGoalSelector(),

                      if (_selectedCategoryKey == 'savings' &&
                          widget.savingsGoals != null &&
                          widget.savingsGoals!.isNotEmpty)
                        const SizedBox(height: 20),

                      // Note Input
                      NoteField(controller: _noteController),

                      const SizedBox(height: 20),

                      // Date Selector
                      DateField(date: _selectedDate, onTap: _showDatePicker),

                      const SizedBox(height: 20),

                      // Exclude from Budget Toggle
                      ExcludeFromBudgetToggle(
                        value: _excludeFromBudget,
                        onChanged: (value) =>
                            setState(() => _excludeFromBudget = value),
                      ),

                      const SizedBox(height: 20),

                      // Recurrence Selector
                      RecurrenceField(
                        recurrence: _selectedRecurrence,
                        onTap: _showRecurrenceDialog,
                      ),

                      const SizedBox(height: 32),

                      // Buttons Row
                      if (widget.existingTransaction != null)
                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                'DELETE',
                                const Color(0xFFFF4D67),
                                _handleDelete,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _actionButton(
                                'SAVE',
                                const Color(0xFF5B8DEF),
                                _handleSave,
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: _actionButton(
                            'SAVE',
                            const Color(0xFF5B8DEF),
                            _handleSave,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoryData = widget.categories[_selectedCategoryKey];
    final hasSubcategories =
        (widget.categoryBudgets?[_selectedCategoryKey]?.isNotEmpty ?? false);
    final badgeColor = categoryData?.solidColor.withValues(alpha: 0.2);
    final emoji = categoryData?.icon ?? '🍽️';
    final hasSubcategory = _selectedSubcategoryName != null;

    return Column(
      children: [
        SelectorTile(
          label: 'Category:',
          value: categoryData?.name ?? 'Food',
          emoji: emoji,
          badgeColor: badgeColor,
          onTap: _showCategoryPicker,
        ),
        if (hasSubcategories)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SelectorTile(
              label: 'Subcategory:',
              value: _selectedSubcategoryName ?? 'Select a subcategory',
              emoji: emoji,
              badgeColor: badgeColor,
              valueColor: hasSubcategory
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderColor: hasSubcategory
                  ? Colors.cyan.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              onTap: _showSubcategoryPicker,
            ),
          ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    final selectedGoal = _selectedGoalId != null
        ? widget.savingsGoals?.firstWhere(
            (g) => g.id == _selectedGoalId,
            orElse: () => widget.savingsGoals!.first,
          )
        : null;

    return SelectorTile(
      label: 'Savings Goal:',
      value: selectedGoal?.name ?? 'Select a goal',
      emoji: selectedGoal?.emoji ?? '🎯',
      badgeColor:
          selectedGoal?.color.withValues(alpha: 0.2) ??
          Colors.white.withValues(alpha: 0.1),
      borderColor:
          selectedGoal?.color.withValues(alpha: 0.3) ??
          Colors.white.withValues(alpha: 0.1),
      onTap: _showGoalPicker,
    );
  }

  void _showGoalPicker() {
    showGoalPicker(
      context,
      savingsGoals: widget.savingsGoals,
      selectedGoalId: _selectedGoalId,
      onSelected: (id) => setState(() => _selectedGoalId = id),
    );
  }

  void _showCategoryPicker() {
    showCategoryPicker(
      context,
      categories: widget.categories,
      categoryBudgets: widget.categoryBudgets,
      savingsGoals: widget.savingsGoals,
      onSelected: (key, subcategory, goalId) => setState(() {
        _selectedCategoryKey = key;
        _selectedSubcategoryName = subcategory;
        _selectedGoalId = goalId;
      }),
    );
  }

  void _showSubcategoryPicker() {
    showSubcategoryPicker(
      context,
      widget.categoryBudgets?[_selectedCategoryKey],
      (name) => setState(() => _selectedSubcategoryName = name),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _showRecurrenceDialog() {
    showRecurrenceDialog(context, _selectedRecurrence, (recurrence) {
      setState(() {
        _selectedRecurrence = recurrence;
        if (recurrence == RecurrenceType.never) {
          _recurrenceEndDate = null;
        }
      });
    });
  }
}
