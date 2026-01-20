import 'package:flutter/material.dart';
import '../models/budget_models.dart';

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
      if (_selectedCategoryKey == 'savings' && _selectedGoalId != null && widget.savingsGoals != null) {
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

  void _handleDelete() {
    if (widget.existingTransaction == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF4D67).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF4D67),
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Transaction?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onTransactionDeleted?.call(
                          widget.existingTransaction!,
                        );
                        Navigator.pop(context); // Close confirmation dialog
                        Navigator.pop(context); // Close transaction dialog
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D67),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                hintText: '0 €',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF131D2E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Transaction Type Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTypeButton(
                              'EXPENSE',
                              TransactionType.expense,
                            ),
                            _buildTypeButton('INCOME', TransactionType.income),
                          ],
                        ),
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
                      _buildNoteInput(),

                      const SizedBox(height: 20),

                      // Date Selector
                      _buildDateSelector(),

                      const SizedBox(height: 20),

                      // Exclude from Budget Toggle
                      _buildExcludeToggle(),

                      const SizedBox(height: 20),

                      // Recurrence Selector
                      _buildRecurrenceSelector(),

                      const SizedBox(height: 32),

                      // Buttons Row
                      if (widget.existingTransaction != null)
                        Row(
                          children: [
                            // Delete Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _handleDelete,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4D67),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'DELETE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Save Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _handleSave,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B8DEF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'SAVE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Save Button (new transaction)
                        GestureDetector(
                          onTap: _handleSave,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B8DEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'SAVE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
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

  Widget _buildTypeButton(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            // Reset category when switching transaction type
            if (type == TransactionType.income) {
              _selectedCategoryKey = 'salary';
            } else if (type == TransactionType.expense) {
              _selectedCategoryKey = 'food';
            } else {
              _selectedCategoryKey = 'food';
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF395587) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoryData = widget.categories[_selectedCategoryKey];
    final hasSubcategories =
        (widget.categoryBudgets?[_selectedCategoryKey]?.isNotEmpty ?? false);

    return Column(
      children: [
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryData?.solidColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      categoryData?.icon ?? '🍽️',
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
                        'Category:',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        categoryData?.name ?? 'Food',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        // Show subcategory selector if available
        if (hasSubcategories)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: _showSubcategoryPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedSubcategoryName != null
                        ? Colors.cyan.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryData?.solidColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          categoryData?.icon ?? '🍽️',
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
                            'Subcategory:',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedSubcategoryName ?? 'Select a subcategory',
                            style: TextStyle(
                              color: _selectedSubcategoryName != null
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
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

    return GestureDetector(
      onTap: _showGoalPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selectedGoal?.color.withValues(alpha: 0.3) ??
                Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    selectedGoal?.color.withValues(alpha: 0.2) ??
                    Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  selectedGoal?.emoji ?? '🎯',
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
                    'Savings Goal:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    selectedGoal?.name ?? 'Select a goal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2B3F), Color(0xFF0F1A2E)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Savings Goal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...?widget.savingsGoals?.map(
                    (goal) => ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: goal.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            goal.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      title: Text(
                        goal.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '€${goal.currentAmount.toStringAsFixed(0)} / €${goal.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: _selectedGoalId == goal.id
                          ? Icon(Icons.check_circle, color: goal.color)
                          : null,
                      onTap: () {
                        setState(() => _selectedGoalId = goal.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.note_alt_outlined,
            color: Colors.white.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Note',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: const Color(0xFF1A2B3F).withValues(alpha: 0.85),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDate.day == DateTime.now().day
                  ? 'Today'
                  : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcludeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.block,
            color: Colors.white.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Exclude from budget',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: _excludeFromBudget,
            onChanged: (value) => setState(() => _excludeFromBudget = value),
            activeTrackColor: const Color(0xFF0D47A1),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    String? expandedCategoryKey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A2B3F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: widget.categories.length,
                      itemBuilder: (context, index) {
                        final entry = widget.categories.entries.elementAt(
                          index,
                        );
                        final key = entry.key;
                        final category = entry.value;

                        // For savings category, use savings goals as subcategories
                        final isSavingsCategory = key == 'savings';
                        final subcategories = isSavingsCategory
                            ? null
                            : widget.categoryBudgets?[key];

                        final hasSubcategories = isSavingsCategory
                            ? (widget.savingsGoals?.isNotEmpty ?? false)
                            : (subcategories?.isNotEmpty ?? false);

                        final isExpanded = expandedCategoryKey == key;

                        return Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: category.solidColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    category.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: hasSubcategories
                                  ? Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.white70,
                                    )
                                  : null,
                              onTap: () {
                                if (hasSubcategories) {
                                  // Toggle expansion
                                  setModalState(() {
                                    expandedCategoryKey = isExpanded
                                        ? null
                                        : key;
                                  });
                                } else {
                                  // Select category directly
                                  setState(() {
                                    _selectedCategoryKey = key;
                                    _selectedSubcategoryName = null;
                                    _selectedGoalId = null;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            // Show savings goals as subcategories for savings category
                            if (isExpanded &&
                                isSavingsCategory &&
                                widget.savingsGoals != null)
                              ...widget.savingsGoals!.map(
                                (goal) => ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 72,
                                    right: 16,
                                  ),
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: goal.color.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        goal.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    goal.name,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    '€${goal.currentAmount.toStringAsFixed(0)} / €${goal.targetAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: goal.color.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryKey = key;
                                      _selectedSubcategoryName = goal.name;
                                      _selectedGoalId = goal.id;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            // Show regular subcategories for other categories
                            if (isExpanded &&
                                !isSavingsCategory &&
                                hasSubcategories)
                              ...subcategories!.keys.map(
                                (subName) => ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 72,
                                    right: 16,
                                  ),
                                  title: Text(
                                    subName,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryKey = key;
                                      _selectedSubcategoryName = subName;
                                      _selectedGoalId = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSubcategoryPicker() {
    final subcategories = widget.categoryBudgets?[_selectedCategoryKey];
    if (subcategories == null || subcategories.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2B3F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select Subcategory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subName = subcategories.keys.elementAt(index);
                      return ListTile(
                        title: Text(
                          subName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() => _selectedSubcategoryName = subName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        RecurrenceType tempRecurrence = _selectedRecurrence;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A3F5F), Color(0xFF1A2F4F)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Recurrence',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: RecurrenceType.values.map((type) {
                            final isSelected = tempRecurrence == type;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  tempRecurrence = type;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00A8E8)
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(
                                            0xFF00A8E8,
                                          ).withValues(alpha: 0.5)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRecurrence = tempRecurrence;
                                  if (tempRecurrence == RecurrenceType.never) {
                                    _recurrenceEndDate = null;
                                  }
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A8E8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecurrenceSelector() {
    return GestureDetector(
      onTap: _showRecurrenceDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3B5C).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.repeat,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Recurrence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 120),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedRecurrence != RecurrenceType.never
                      ? const Color(0xFF00A8E8)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedRecurrence.displayName,
                  style: TextStyle(
                    color: _selectedRecurrence != RecurrenceType.never
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: _selectedRecurrence != RecurrenceType.never
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
