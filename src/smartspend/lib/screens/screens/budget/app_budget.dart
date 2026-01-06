import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import '../../../services/simple_auth_manager.dart';
import '../../../services/budget_data_service.dart';
import '../../../widgets/components/ui/input.dart';
import '../../../widgets/add_transaction_dialog.dart';
import 'widgets/budget_header.dart';
import 'widgets/circular_budget_chart.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/budget_animated_background.dart';
import '../bank/widgets/floating_connect_card.dart';
import '../overview/wallet_overview_screen.dart';
import 'category_manager.dart';

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> with TickerProviderStateMixin {
  // State variables
  String activeTab = 'overview';
  double totalBudget = 1000;
  List<Transaction> transactions = [];
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  List<String> expandedCategories = [];
  bool isEditingBudgets = false;
  Map<String, String> tempBudgetValues = {};
  final ValueNotifier<int> _walletTabNotifier = ValueNotifier<int>(0);
  bool _walletShowingList = false;
  
  // Savings Goals
  List<SavingsGoal> savingsGoals = [];
  
  // Sample bank transactions
  List<Transaction> bankTransactions = [
    Transaction(
      id: '1',
      type: TransactionType.expense,
      amount: 45.99,
      category: 'Groceries',
      categoryKey: 'food',
      note: 'Weekly groceries',
      date: DateTime.now(),
      merchant: 'Whole Foods Market',
    ),
    Transaction(
      id: '2',
      type: TransactionType.expense,
      amount: 32.50,
      category: 'Transport',
      categoryKey: 'transport',
      note: 'Gas',
      date: DateTime.now().subtract(const Duration(days: 1)),
      merchant: 'Shell Station',
    ),
    Transaction(
      id: '3',
      type: TransactionType.expense,
      amount: 120.00,
      category: 'Entertainment',
      categoryKey: 'entertainment',
      note: 'Movie tickets',
      date: DateTime.now().subtract(const Duration(days: 2)),
      merchant: 'Cinema ABC',
    ),
  ];

  // Budget data
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets = {
    'housing': {
      'Rent': SubcategoryBudget(budgeted: 200, spent: 200),
      'Gym': SubcategoryBudget(budgeted: 10, spent: 10),
    },
    'food': {'Groceries': SubcategoryBudget(budgeted: 30, spent: 30)},
    'savings': {
      'Savings': SubcategoryBudget(budgeted: 0, spent: 0),
    },
  };

  // Animation controller
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _loadUserBudgetData();
  }

  // Load user-specific budget data
  Future<void> _loadUserBudgetData() async {
    final currentUser = SimpleAuthManager.instance.currentUser;
    if (currentUser != null) {
      final data = await BudgetDataService.loadBudgetData(currentUser.id);
      if (data != null) {
        setState(() {
          totalBudget = data['totalBudget'];
          transactions = data['transactions'];
          categoryBudgets = data['categoryBudgets'];
        });
      }
    }
  }

  // Save user-specific budget data
  Future<void> _saveUserBudgetData() async {
    final currentUser = SimpleAuthManager.instance.currentUser;
    if (currentUser != null) {
      await BudgetDataService.saveBudgetData(
        userId: currentUser.id,
        totalBudget: totalBudget,
        transactions: transactions,
        categories: categories,
        categoryBudgets: categoryBudgets,
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // Calculations
  double get totalSpent {
    double spent = 0;
    categoryBudgets.forEach((_, subcats) {
      subcats.forEach((_, budget) {
        spent += budget.spent;
      });
    });
    return spent;
  }

  double get budgetLeft => totalBudget - totalSpent;
  double get budgetPercentage => (totalSpent / totalBudget) * 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF1A1F33), Color(0xFF0A0E1A)],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background
            BudgetAnimatedBackground(controller: _rotationController),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Custom Status Bar with App Name
                  _buildCustomStatusBar(),
                  
                  BudgetHeader(
                    activeTab: activeTab,
                    isEditingBudgets: isEditingBudgets,
                    onEditToggle: () {
                      setState(() {
                        if (isEditingBudgets) {
                          _saveAllBudgets();
                        } else {
                          _enterEditMode();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: activeTab == 'budget'
                        ? _buildBudgetTab()
                        : WalletOverviewContent(
                            key: const ValueKey('wallet_overview'),
                            transactions: transactions,
                            categories: categories,
                            totalBudget: totalBudget,
                            totalSpent: totalSpent,
                            onTransactionEdit: _editTransaction,
                            tabNotifier: _walletTabNotifier,
                            onListStateChanged: (isList) => setState(() => _walletShowingList = isList),
                            savingsGoals: savingsGoals,
                            onGoalCreated: (goal) => setState(() => savingsGoals.add(goal)),
                            onGoalUpdated: (goal) {
                              setState(() {
                                final index = savingsGoals.indexWhere((g) => g.id == goal.id);
                                if (index != -1) savingsGoals[index] = goal;
                              });
                            },
                            onTransactionAdded: _addTransaction,
                          ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BudgetBottomNavigation(
                activeTab: activeTab,
                onTabChanged: (tab) => setState(() => activeTab = tab),
                onAddTransaction: _showAddTransactionDialog,
              ),
            ),

            // Floating Connect Card Button
            FloatingConnectCard(
              transactions: bankTransactions,
              onCardConnected: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank card connected successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              onTransactionAction: (transaction, isAccepted) {
                setState(() {
                  if (isAccepted) {
                    transactions.add(transaction);
                    
                    final categoryKey = transaction.categoryKey;
                    if (categoryBudgets.containsKey(categoryKey)) {
                      final subcategory = transaction.category;
                      if (categoryBudgets[categoryKey]!.containsKey(subcategory)) {
                        categoryBudgets[categoryKey]![subcategory]!.spent += transaction.amount;
                      } else {
                        categoryBudgets[categoryKey]![subcategory] = SubcategoryBudget(
                          budgeted: 0,
                          spent: transaction.amount,
                        );
                      }
                    }
                    
                    _saveUserBudgetData(); // Save after transaction
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Transaction saved: ${transaction.merchant}'),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  }
                });
              },
              onTransactionEdit: _editBankTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStatusBar() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = _formatDate(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Back button (conditionally) and Time/Date
          Row(
            children: [
              if (_walletShowingList)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      _walletTabNotifier.value = 0;
                      setState(() => _walletShowingList = false);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Center - App Name
          const Text(
            'SmartSpend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          // Right side - Battery
          Row(
            children: [
              const Text(
                '100%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.battery_full,
                color: Colors.green[400],
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final dayName = days[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    return '$dayName $day $month';
  }

  Widget _buildBudgetTab() {
    final double bottomNavReserve = MediaQuery.of(context).padding.bottom + 140.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircularBudgetChart(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            budgetLeft: budgetLeft,
            budgetPercentage: budgetPercentage,
            onBudgetTap: _showEditBudgetDialog,
          ),
          const SizedBox(height: 24),
          _buildCategoriesList(),
          SizedBox(height: bottomNavReserve),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
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
                  '€${totalSpent.toStringAsFixed(0)} / €${totalBudget.toStringAsFixed(0)} spent',
                  style: const TextStyle(
                    color: Color(0xFF00F5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (isEditingBudgets)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF00F5FF),
                ),
                onPressed: _showManageCategoriesDialog,
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
          final categorySpent =
              subcategories.values.fold<double>(0, (s, b) => s + b.spent);
          final categoryBudgeted =
              subcategories.values.fold<double>(0, (s, b) => s + b.budgeted);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1F3A).withValues(alpha: 0.85),
                  const Color(0xFF2A2F4A).withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: categoryData.solidColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded
                          ? expandedCategories.remove(categoryKey)
                          : expandedCategories.add(categoryKey);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: categoryData.solidColor.withValues(alpha: 0.18),
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
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '€${categorySpent.toStringAsFixed(0)} / €${categoryBudgeted.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: categorySpent > categoryBudgeted
                                      ? Colors.red
                                      : categoryData.solidColor,
                                  fontSize: 13,
                                ),
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
                    children: subcategories.entries
                        .map((e) => _buildSubcategoryItem(
                              e.key,
                              e.value,
                              categoryData.solidColor,
                            ))
                        .toList(),
                  ),
              ],
            ),
          );
        }),
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
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
                        color: percentage > 90 ? Colors.red : categoryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '€${budget.spent.toStringAsFixed(0)} / €${budget.budgeted.toStringAsFixed(0)}',
            style: TextStyle(
              color: categoryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Keep all the remaining methods unchanged
  void _showEditBudgetDialog() {
    final controller = TextEditingController(text: totalBudget.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
            ),
          ),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFF00F5FF), size: 24),
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
                'Set your monthly budget amount',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: controller,
                label: 'Budget Amount',
                labelColor: Colors.white,
                placeholder: 'Enter amount',
                keyboardType: TextInputType.number,
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
                final newBudget = double.tryParse(controller.text);
                if (newBudget != null && newBudget > 0) {
                  setState(() {
                    totalBudget = newBudget;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Budget updated to €${newBudget.toStringAsFixed(0)}'),
                      backgroundColor: const Color(0xFF00F5FF),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F5FF),
                foregroundColor: const Color(0xFF1A1F3A),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _enterEditMode() {
    tempBudgetValues.clear();
    setState(() => isEditingBudgets = true);
  }

  void _saveAllBudgets() {
    tempBudgetValues.forEach((key, value) {
      final amount = double.tryParse(value);
      if (amount != null) {
        debugPrint('Saving budget for $key: €$amount');
      }
    });

    tempBudgetValues.clear();
    setState(() => isEditingBudgets = false);

    _saveUserBudgetData(); // Save after budget edit

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budgets saved successfully!'),
        backgroundColor: Color(0xFF00F5FF),
      ),
    );
  }

  void _showEditCategoryDialog(String categoryKey, CategoryData categoryData) {
    showEditCategoryDialog(
      context,
      categories,
      categoryKey,
      categoryData,
      categoryBudgets,
      () => setState(() {}),
    );
  }

  void _showManageCategoriesDialog() {
    showManageCategoriesDialog(
      context,
      categories,
      categoryBudgets,
      (key, data) => _showEditCategoryDialog(key, data),
      () => setState(() {}),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        categories: categories,
        onTransactionAdded: _addTransaction,
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
          });
        },
      ),
    );
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      
      if (transaction.type == TransactionType.expense) {
        final categoryKey = transaction.categoryKey;
        
        if (!categoryBudgets.containsKey(categoryKey)) {
          categoryBudgets[categoryKey] = {};
        }
        
        if (!categoryBudgets[categoryKey]!.containsKey(transaction.category)) {
          categoryBudgets[categoryKey]![transaction.category] = SubcategoryBudget(
            budgeted: 0,
            spent: 0,
          );
        }
        
        // Only count towards budget if not excluded
        if (!transaction.excludeFromBudget) {
          categoryBudgets[categoryKey]![transaction.category]!.spent += transaction.amount;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction added: €${transaction.amount.toStringAsFixed(2)}'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        categories: categories,
        existingTransaction: transaction,
        onTransactionAdded: _addTransaction,
        onTransactionUpdated: _updateTransaction,
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
          });
        },
      ),
    );
  }

  void _updateTransaction(Transaction updatedTransaction) {
    setState(() {
      final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index != -1) {
        final oldTransaction = transactions[index];
        
        if (!oldTransaction.excludeFromBudget && oldTransaction.type == TransactionType.expense) {
          final oldCategoryKey = oldTransaction.categoryKey;
          if (categoryBudgets.containsKey(oldCategoryKey) &&
              categoryBudgets[oldCategoryKey]!.containsKey(oldTransaction.category)) {
            categoryBudgets[oldCategoryKey]![oldTransaction.category]!.spent -= oldTransaction.amount;
          }
        }
        
        transactions[index] = updatedTransaction;
        
        if (!updatedTransaction.excludeFromBudget && updatedTransaction.type == TransactionType.expense) {
          final categoryKey = updatedTransaction.categoryKey;
          
          if (!categoryBudgets.containsKey(categoryKey)) {
            categoryBudgets[categoryKey] = {};
          }
          
          if (!categoryBudgets[categoryKey]!.containsKey(updatedTransaction.category)) {
            categoryBudgets[categoryKey]![updatedTransaction.category] = SubcategoryBudget(
              budgeted: 0,
              spent: 0,
            );
          }
          
          categoryBudgets[categoryKey]![updatedTransaction.category]!.spent += updatedTransaction.amount;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction updated: €${updatedTransaction.amount.toStringAsFixed(2)}'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  void _editBankTransaction(Transaction transaction) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddTransactionDialog(
        categories: categories,
        existingTransaction: transaction,
        onTransactionAdded: _addTransaction,
        onTransactionUpdated: (updatedTransaction) {
          _addTransaction(updatedTransaction);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bank transaction added: €${updatedTransaction.amount.toStringAsFixed(2)}'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        },
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
          });
        },
      ),
    );
  }
}