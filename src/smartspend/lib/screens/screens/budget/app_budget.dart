import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/budget_models.dart';
import '../../../services/simple_auth_manager.dart';
import '../../../services/budget_data_service.dart';
import '../../../services/spending_recommendations_service.dart';
import '../../../widgets/components/ui/input.dart';
import '../../../widgets/add_transaction_dialog.dart';
import '../../../widgets/spending_recommendations_widget.dart';
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
  bool _isCardConnected = false;
  bool budgetEqualsIncome = false;

  // Savings Goals
  List<SavingsGoal> savingsGoals = [];

  // AI Recommendations
  List<SpendingRecommendation> spendingRecommendations = [];

  // Mock bank transactions for demonstration
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
    'savings': {'Savings': SubcategoryBudget(budgeted: 0, spent: 0)},
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
    _loadCardConnectionStatus();
  }

  Future<void> _loadCardConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCardConnected = prefs.getBool('bank_card_connected') ?? false;
    });
  }

  Future<void> _saveCardConnectionStatus(bool connected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bank_card_connected', connected);
    setState(() {
      _isCardConnected = connected;
    });
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
          budgetEqualsIncome = data['budgetEqualsIncome'] ?? false;
          if (data['savingsGoals'] != null) {
            savingsGoals = data['savingsGoals'];
          }
          _syncSavingsBudgetsWithGoals();
          // Recalculate spent amounts from actual transactions
          _recalculateSpentAmounts();
          // Generate AI recommendations
          _generateRecommendations();
        });
        // Generate missing recurring transactions after loading
        _generateRecurringTransactions();
        await _saveUserBudgetData();
      }
    }
  }

  // Generate smart spending recommendations
  void _generateRecommendations() {
    spendingRecommendations =
        SpendingRecommendationsService.generateRecommendations(
          transactions: transactions,
          categoryBudgets: categoryBudgets,
          totalBudget: totalBudget,
          totalIncome: totalIncome,
        );
  }

  // Recalculate all spent amounts from transactions
  void _recalculateSpentAmounts() {
    // Reset all spent amounts to 0
    categoryBudgets.forEach((categoryKey, subcategories) {
      subcategories.forEach((subcategoryName, budget) {
        budget.spent = 0;
      });
    });

    // Recalculate from transactions
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense &&
          !transaction.excludeFromBudget) {
        final categoryKey = transaction.categoryKey;
        final subcategoryName = transaction.category;

        if (!categoryBudgets.containsKey(categoryKey)) {
          categoryBudgets[categoryKey] = {};
        }

        if (!categoryBudgets[categoryKey]!.containsKey(subcategoryName)) {
          categoryBudgets[categoryKey]![subcategoryName] = SubcategoryBudget(
            budgeted: 0,
            spent: 0,
          );
        }

        categoryBudgets[categoryKey]![subcategoryName]!.spent +=
            transaction.amount;
      }
    }
  }

  // Keep savings category budgets aligned with savings goals
  void _syncSavingsBudgetsWithGoals() {
    categoryBudgets['savings'] = {
      for (final goal in savingsGoals)
        goal.name: SubcategoryBudget(
          budgeted: goal.targetAmount,
          spent: goal.currentAmount,
        ),
    };
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
        savingsGoals: savingsGoals,
        budgetEqualsIncome: budgetEqualsIncome,
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

  double get totalIncome {
    // Sum income for the current calendar month to avoid inflated totals
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    double income = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        final d = transaction.date;
        final inThisMonth =
            !d.isBefore(thisMonthStart) && d.isBefore(nextMonthStart);
        if (inThisMonth) {
          income += transaction.amount;
        }
      }
    }
    return income;
  }

  double get availableBudget => budgetEqualsIncome
      ? totalIncome
      : (totalBudget > 0 ? totalBudget : totalIncome);
  double get budgetLeft => availableBudget - totalSpent;
  double get budgetPercentage =>
      availableBudget > 0 ? (totalSpent / availableBudget) * 100 : 0;
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
                  BudgetHeader(
                    activeTab: activeTab,
                    isEditingBudgets: isEditingBudgets,
                    budgetAmount: totalBudget,
                    totalIncome: totalIncome,
                    onEditToggle: () {
                      setState(() {
                        if (isEditingBudgets) {
                          _saveAllBudgets();
                        } else {
                          _enterEditMode();
                        }
                      });
                    },
                    onReturnFromSettings: () {
                      // Reload card connection status when returning from settings
                      _loadCardConnectionStatus();
                    },
                  ),
                  Expanded(
                    child: activeTab == 'budget'
                        ? _buildBudgetTab()
                        : activeTab == 'transactions'
                        ? _buildTransactionsTab()
                        : WalletOverviewContent(
                            key: const ValueKey('wallet_overview'),
                            transactions: transactions,
                            categories: categories,
                            totalBudget: availableBudget,
                            totalSpent: totalSpent,
                            onTransactionEdit: _editTransaction,
                            tabNotifier: _walletTabNotifier,
                            onListStateChanged: (isList) => setState(() {}),
                            budgetEqualsIncome: budgetEqualsIncome,
                            savingsGoals: savingsGoals,
                            onGoalCreated: (goal) {
                              setState(() {
                                savingsGoals.add(goal);
                                _syncSavingsBudgetsWithGoals();
                              });
                              _saveUserBudgetData(); // Save after goal creation
                            },
                            onGoalUpdated: (goal) {
                              setState(() {
                                final index = savingsGoals.indexWhere(
                                  (g) => g.id == goal.id,
                                );
                                if (index != -1) savingsGoals[index] = goal;
                                _syncSavingsBudgetsWithGoals();
                              });
                              _saveUserBudgetData(); // Save after goal update
                            },
                            onGoalDeleted: (goal) {
                              setState(() {
                                savingsGoals.removeWhere(
                                  (g) => g.id == goal.id,
                                );
                                _syncSavingsBudgetsWithGoals();
                              });
                              _saveUserBudgetData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deleted goal: ${goal.name}'),
                                    backgroundColor: const Color(0xFFFF4D67),
                                  ),
                                );
                              }
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
                onTabChanged: (tab) {
                  setState(() => activeTab = tab);
                },
                onAddTransaction: _showAddTransactionDialog,
              ),
            ),

            // Floating Connect Card Button (only show if not connected)
            if (!_isCardConnected)
              FloatingConnectCard(
                transactions: bankTransactions,
                onCardConnected: () async {
                  await _saveCardConnectionStatus(true);
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
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
                        if (categoryBudgets[categoryKey]!.containsKey(
                          subcategory,
                        )) {
                          categoryBudgets[categoryKey]![subcategory]!.spent +=
                              transaction.amount;
                        } else {
                          categoryBudgets[categoryKey]![subcategory] =
                              SubcategoryBudget(
                                budgeted: 0,
                                spent: transaction.amount,
                              );
                        }
                      }

                      _saveUserBudgetData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Transaction saved: ${transaction.merchant}',
                          ),
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

  Widget _buildBudgetTab() {
    final double bottomNavReserve =
        MediaQuery.of(context).padding.bottom + 140.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI Recommendations
          SpendingRecommendationsWidget(
            recommendations: spendingRecommendations,
          ),
          const SizedBox(height: 24),
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
                  onPressed: () {
                    setState(() {
                      if (isEditingBudgets) {
                        _saveAllBudgets();
                      } else {
                        _enterEditMode();
                      }
                    });
                  },
                  icon: Icon(
                    isEditingBudgets ? Icons.check : Icons.edit,
                    color: const Color(0xFF5B8DEF),
                    size: 24,
                  ),
                ),
                // Add Category Button (only in edit mode)
                if (isEditingBudgets)
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF0D47A1),
                    ),
                    onPressed: _showManageCategoriesDialog,
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
              (sum, goal) => sum + goal.targetAmount,
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
                            color: percentage >= 100 ? Colors.green : goal.color,
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
                  '€${goal.currentAmount.toStringAsFixed(0)} / €${goal.targetAmount.toStringAsFixed(0)}',
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
                        color: percentage > 90 ? const Color.fromARGB(255, 250, 249, 249) : categoryColor,
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

  // Keep all the remaining methods unchanged
  void _showEditBudgetDialog() {
    final controller = TextEditingController(
      text: totalBudget.toStringAsFixed(0),
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
                    'Set your monthly budget amount',
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
                      color: const Color(0xFF2A3B5C).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Budget = Income',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Budget matches your income',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
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
                            });
                          },
                          activeThumbColor: const Color(0xFF0D47A1),
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
                      setState(() {
                        budgetEqualsIncome = true;
                      });
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
                        setState(() {
                          totalBudget = newBudget;
                          budgetEqualsIncome = false;
                        });
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
    setState(() {
      isEditingBudgets = false;
      // Regenerate recommendations after budget changes
      _generateRecommendations();
    });

    _saveUserBudgetData(); // Save after budget edit

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budgets saved successfully!'),
        backgroundColor: Color(0xFF0D47A1),
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
      () {
        setState(() {});
        _saveUserBudgetData(); // Save after budget changes
      },
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
        categoryBudgets: categoryBudgets,
        onTransactionAdded: _addTransaction,
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
            _syncSavingsBudgetsWithGoals();
          });
          _saveUserBudgetData(); // Save after goal update
        },
      ),
    );
  }

  Widget _buildTransactionsTab() {
    // Group transactions by month
    final Map<String, List<Transaction>> transactionsByMonth = {};

    for (final transaction in transactions) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      if (!transactionsByMonth.containsKey(monthKey)) {
        transactionsByMonth[monthKey] = [];
      }
      transactionsByMonth[monthKey]!.add(transaction);
    }

    // Sort months in descending order
    final sortedMonthKeys = transactionsByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF8E9AAF),
                size: 28,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Complete transaction history',
                      style: TextStyle(color: Color(0xFF8E9AAF), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transaction summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  transactions
                      .where((t) => t.type == TransactionType.expense)
                      .fold<double>(0, (sum, t) => sum + t.amount),
                  const Color(0xFFE53935),
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  transactions
                      .where((t) => t.type == TransactionType.income)
                      .fold<double>(0, (sum, t) => sum + t.amount),
                  const Color(0xFF4CAF50),
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transactions by month
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...sortedMonthKeys.map((monthKey) {
              final monthTransactions = transactionsByMonth[monthKey]!
                ..sort((a, b) => b.date.compareTo(a.date));

              final parts = monthKey.split('-');
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final monthName = _getMonthName(month);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '$monthName $year',
                      style: const TextStyle(
                        color: Color(0xFF5B8DEF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...monthTransactions.map(
                    (transaction) => _buildTransactionItem(transaction),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final categoryData = transaction.type == TransactionType.income
        ? incomeCategories[transaction.categoryKey]
        : categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;

    return GestureDetector(
      onTap: () => _editTransaction(transaction),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        categoryData?.solidColor.withValues(alpha: 0.2) ??
                        const Color(0x33808080),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      categoryData?.icon ?? '💰',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.note,
                        style: const TextStyle(
                          color: Color(0xFF8E9AAF),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTransactionDate(transaction.date),
                        style: const TextStyle(
                          color: Color(0xFF6B7789),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isExpense
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFF4CAF50),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFF2A3B5C).withValues(alpha: 0.3),
            indent: 76,
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
          categoryBudgets[categoryKey]![transaction.category] =
              SubcategoryBudget(budgeted: 0, spent: 0);
        }

        // Only count towards budget if not excluded
        if (!transaction.excludeFromBudget) {
          categoryBudgets[categoryKey]![transaction.category]!.spent +=
              transaction.amount;
        }
      } else if (transaction.type == TransactionType.income) {
        // When income is added, automatically set budget to equal income
        budgetEqualsIncome = true;
      }

      // Regenerate recommendations after adding transaction
      _generateRecommendations();
    });

    // If this is a recurring template, generate future/past occurrences
    _generateRecurringTransactions(base: transaction);

    _saveUserBudgetData(); // Save after adding transaction

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction added: €${transaction.amount.toStringAsFixed(2)}',
        ),
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
        onTransactionDeleted: _deleteTransaction,
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
            _syncSavingsBudgetsWithGoals();
          });
          _saveUserBudgetData(); // Save after goal update
        },
      ),
    );
  }

  void _updateTransaction(Transaction updatedTransaction) {
    setState(() {
      final index = transactions.indexWhere(
        (t) => t.id == updatedTransaction.id,
      );
      if (index != -1) {
        final oldTransaction = transactions[index];

        // Handle removal from old category/savings
        if (!oldTransaction.excludeFromBudget &&
            oldTransaction.type == TransactionType.expense) {
          final oldCategoryKey = oldTransaction.categoryKey;
          if (categoryBudgets.containsKey(oldCategoryKey) &&
              categoryBudgets[oldCategoryKey]!.containsKey(
                oldTransaction.category,
              )) {
            categoryBudgets[oldCategoryKey]![oldTransaction.category]!.spent -=
                oldTransaction.amount;
          }

          // Remove from savings goal if it was a savings transaction
          if (oldCategoryKey == 'savings') {
            for (var goal in savingsGoals) {
              if (goal.name == oldTransaction.category) {
                goal.currentAmount -= oldTransaction.amount;
                break;
              }
            }
          }
        }

        // If this is a recurring transaction, remove all its old occurrences first
        if (oldTransaction.recurrence != RecurrenceType.never) {
          // First, collect the occurrences to remove and subtract from budgets
          final occurrencesToRemove = transactions.where(
            (t) => t.id.startsWith('${oldTransaction.id}_'),
          ).toList();

          // Subtract the old occurrences from budgets BEFORE removing them
          for (final t in occurrencesToRemove) {
            if (!t.excludeFromBudget && t.type == TransactionType.expense) {
              final categoryKey = t.categoryKey;
              if (categoryBudgets.containsKey(categoryKey) &&
                  categoryBudgets[categoryKey]!.containsKey(t.category)) {
                categoryBudgets[categoryKey]![t.category]!.spent -= t.amount;
              }

              // Remove from savings goal if it was a savings transaction
              if (categoryKey == 'savings') {
                for (var goal in savingsGoals) {
                  if (goal.name == t.category) {
                    goal.currentAmount -= t.amount;
                    break;
                  }
                }
              }
            }
          }

          // Now remove the occurrences from the transactions list
          transactions.removeWhere(
            (t) => t.id.startsWith('${oldTransaction.id}_'),
          );
        }

        transactions[index] = updatedTransaction;

        // Handle addition to new category/savings
        if (!updatedTransaction.excludeFromBudget &&
            updatedTransaction.type == TransactionType.expense) {
          final categoryKey = updatedTransaction.categoryKey;

          if (!categoryBudgets.containsKey(categoryKey)) {
            categoryBudgets[categoryKey] = {};
          }

          if (!categoryBudgets[categoryKey]!.containsKey(
            updatedTransaction.category,
          )) {
            categoryBudgets[categoryKey]![updatedTransaction.category] =
                SubcategoryBudget(budgeted: 0, spent: 0);
          }

          categoryBudgets[categoryKey]![updatedTransaction.category]!.spent +=
              updatedTransaction.amount;

          // Add to savings goal if it's a savings transaction
          if (categoryKey == 'savings') {
            for (var goal in savingsGoals) {
              if (goal.name == updatedTransaction.category) {
                goal.currentAmount += updatedTransaction.amount;
                break;
              }
            }
          }
        }

        // Sync savings budgets with goals after all updates
        _syncSavingsBudgetsWithGoals();
      }

      // Regenerate recommendations after update
      _generateRecommendations();
    });

    // Regenerate recurrences if this transaction has a recurrence
    _generateRecurringTransactions(base: updatedTransaction);

    _saveUserBudgetData(); // Save after updating transaction

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction updated: €${updatedTransaction.amount.toStringAsFixed(2)}',
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
    );
  }

  // Generate recurring transaction instances based on recurrence rules.
  // - Avoid duplicates by checking existing (amount+category+date+note+merchant).
  // - For future dates, mark excludeFromBudget=true to keep monthly budget sane.
  // - Generated copies set recurrence=RecurrenceType.never to prevent cascades.
  void _generateRecurringTransactions({Transaction? base}) {
    // Build a set of existing keys to avoid duplicates
    final existingKeys = <String>{};
    for (final t in transactions) {
      final key = _transactionKey(t);
      existingKeys.add(key);
    }

    // Determine which transactions to process
    final source = base != null
        ? [base]
        : transactions
              .where((t) => t.recurrence != RecurrenceType.never)
              .toList();

    DateTime now = DateTime.now();
    for (final tmpl in source) {
      if (tmpl.recurrence == RecurrenceType.never) continue;

      // Start from the original date
      DateTime next = _nextOccurrenceDate(tmpl.date, tmpl.recurrence);
      // End at provided end date or 12 months horizon from start
      final end =
          tmpl.recurrenceEndDate ??
          DateTime(tmpl.date.year, tmpl.date.month + 12, tmpl.date.day);

      while (!next.isAfter(end)) {
        final synthetic = Transaction(
          id: '${tmpl.id}_${next.toIso8601String()}',
          type: tmpl.type,
          amount: tmpl.amount,
          category: tmpl.category,
          categoryKey: tmpl.categoryKey,
          note: tmpl.note,
          date: next,
          merchant: tmpl.merchant,
          description: tmpl.description,
          excludeFromBudget: next.isAfter(
            now,
          ), // future occurrences won't affect current budgets
          recurrence: RecurrenceType.never,
          recurrenceEndDate: null,
        );

        final key = _transactionKey(synthetic);
        if (!existingKeys.contains(key)) {
          // Add to list and update budgets if needed
          setState(() {
            transactions.add(synthetic);
            if (!synthetic.excludeFromBudget &&
                synthetic.type == TransactionType.expense) {
              final categoryKey = synthetic.categoryKey;
              if (!categoryBudgets.containsKey(categoryKey)) {
                categoryBudgets[categoryKey] = {};
              }
              if (!categoryBudgets[categoryKey]!.containsKey(
                synthetic.category,
              )) {
                categoryBudgets[categoryKey]![synthetic.category] =
                    SubcategoryBudget(budgeted: 0, spent: 0);
              }
              categoryBudgets[categoryKey]![synthetic.category]!.spent +=
                  synthetic.amount;
            }
          });

          existingKeys.add(key);
        }

        next = _nextOccurrenceDate(next, tmpl.recurrence);
      }
    }
  }

  String _transactionKey(Transaction t) {
    return '${t.categoryKey}|${t.category}|${t.amount.toStringAsFixed(2)}|${t.note}|${t.merchant}|${DateTime(t.date.year, t.date.month, t.date.day).toIso8601String()}';
  }

  DateTime _nextOccurrenceDate(DateTime from, RecurrenceType type) {
    switch (type) {
      case RecurrenceType.weekly:
        return from.add(const Duration(days: 7));
      case RecurrenceType.biweekly:
        return from.add(const Duration(days: 14));
      case RecurrenceType.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case RecurrenceType.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case RecurrenceType.yearly:
        return DateTime(from.year + 1, from.month, from.day);
      case RecurrenceType.never:
        return from;
    }
  }

  void _deleteTransaction(Transaction transaction) {
    setState(() {
      // Remove from budget calculations if it's an expense
      if (!transaction.excludeFromBudget &&
          transaction.type == TransactionType.expense) {
        final categoryKey = transaction.categoryKey;
        if (categoryBudgets.containsKey(categoryKey) &&
            categoryBudgets[categoryKey]!.containsKey(transaction.category)) {
          categoryBudgets[categoryKey]![transaction.category]!.spent -=
              transaction.amount;
        }
      }

      // Remove from savings goal if applicable
      if (transaction.categoryKey == 'savings') {
        for (var goal in savingsGoals) {
          if (goal.name == transaction.category) {
            goal.currentAmount -= transaction.amount;
            break;
          }
        }
        _syncSavingsBudgetsWithGoals();
      }

      // Remove the transaction
      transactions.removeWhere((t) => t.id == transaction.id);

      // Regenerate recommendations after deletion
      _generateRecommendations();
    });

    _saveUserBudgetData(); // Save after deleting transaction

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction deleted: €${transaction.amount.toStringAsFixed(2)}',
        ),
        backgroundColor: const Color(0xFFFF4D67),
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
              content: Text(
                'Bank transaction added: €${updatedTransaction.amount.toStringAsFixed(2)}',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        },
        savingsGoals: savingsGoals,
        onGoalUpdated: (goal) {
          setState(() {
            final index = savingsGoals.indexWhere((g) => g.id == goal.id);
            if (index != -1) savingsGoals[index] = goal;
            _syncSavingsBudgetsWithGoals();
          });
          _saveUserBudgetData();
        },
      ),
    );
  }
}
