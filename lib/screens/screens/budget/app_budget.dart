import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/budget_models.dart';
import '../../../services/simple_auth_manager.dart';
import '../../../services/budget_data_service.dart';
import '../../../services/budget_ledger.dart';
import '../../../services/spending_recommendations_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/add_transaction_dialog.dart';
import '../../../widgets/spending_recommendations_widget.dart';
import 'widgets/budget_header.dart';
import 'widgets/budget_category_list.dart';
import 'widgets/edit_total_budget_dialog.dart';
import 'widgets/circular_budget_chart.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/budget_animated_background.dart';
import '../bank/widgets/floating_connect_card.dart';
import '../bank/demo_bank_transactions.dart';
import '../overview/wallet_overview_screen.dart';
import 'category_manager.dart';

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> with TickerProviderStateMixin {
  // UI State
  String activeTab = 'overview';
  bool isEditingBudgets = false;
  List<String> expandedCategories = [];

  // Budget Data
  double totalBudget = AppConstants.defaultTotalBudget;
  bool budgetEqualsIncome = false;
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  final BudgetLedger _ledger = BudgetLedger.withDefaultBudgets();
  List<Transaction> get transactions => _ledger.transactions;
  Map<String, Map<String, SubcategoryBudget>> get categoryBudgets =>
      _ledger.categoryBudgets;
  List<SavingsGoal> get savingsGoals => _ledger.savingsGoals;

  List<SpendingRecommendation> spendingRecommendations = [];

  // Bank & Card Integration
  bool _isCardConnected = false;
  final List<Transaction> bankTransactions = demoBankTransactions();

  // Animation
  late AnimationController _rotationController;

  // Notifications
  final ValueNotifier<int> _walletTabNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: AppConstants.rotationAnimationDuration,
      vsync: this,
    )..repeat();
    _loadUserBudgetData();
    _loadCardConnectionStatus();
  }

  Future<void> _loadCardConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCardConnected =
          prefs.getBool(AppConstants.bankCardConnectedKey) ?? false;
    });
  }

  Future<void> _saveCardConnectionStatus(bool connected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.bankCardConnectedKey, connected);
    setState(() {
      _isCardConnected = connected;
    });
  }

  Future<void> _loadUserBudgetData() async {
    final currentUser = SimpleAuthManager.instance.currentUser;
    if (currentUser != null) {
      final data = await BudgetDataService.loadBudgetData(currentUser.id);
      if (data != null) {
        setState(() {
          totalBudget = data['totalBudget'];
          _ledger.transactions = data['transactions'];
          _ledger.categoryBudgets = data['categoryBudgets'];
          budgetEqualsIncome = data['budgetEqualsIncome'] ?? false;
          if (data['savingsGoals'] != null) {
            _ledger.savingsGoals = data['savingsGoals'];
          }
          _ledger.syncSavingsWithGoals();
          _ledger.recalculateSpent();
          _generateRecommendations();
        });
        setState(() => _ledger.generateRecurring());
        await _saveUserBudgetData();
      }
    }
  }

  void _generateRecommendations() {
    spendingRecommendations =
        SpendingRecommendationsService.generateRecommendations(
          transactions: transactions,
          categoryBudgets: categoryBudgets,
          totalBudget: totalBudget,
          totalIncome: totalIncome,
        );
  }

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

  double get totalSpent => _ledger.totalSpent;
  double get totalBudgeted => _ledger.totalBudgeted;
  double get totalIncome => _ledger.incomeForMonth(DateTime.now());

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
                    onEditToggle: _toggleEditMode,
                    onReturnFromSettings: () {
                      // Reload card connection status when returning from settings
                      _loadCardConnectionStatus();
                    },
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppConstants.screenTransitionDuration,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: activeTab == 'budget'
                          ? _buildBudgetTab()
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
                                setState(() => _ledger.addGoal(goal));
                                _saveUserBudgetData();
                              },
                              onGoalUpdated: _updateGoal,
                              onGoalDeleted: (goal) {
                                setState(() => _ledger.removeGoal(goal));
                                _saveUserBudgetData();
                                if (mounted) {
                                  _showSnack(
                                    'Deleted goal: ${goal.name}',
                                    const Color(0xFFFF4D67),
                                  );
                                }
                              },
                              onTransactionAdded: _addTransaction,
                            ),
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
                  if (activeTab != tab) {
                    setState(() => activeTab = tab);
                  }
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
                  _showSnack(
                    'Bank card connected successfully!',
                    const Color(0xFF4CAF50),
                  );
                },
                onTransactionAction: (transaction, isAccepted) {
                  setState(() {
                    if (isAccepted) {
                      _ledger.acceptBankTransaction(transaction);

                      _saveUserBudgetData();

                      _showSnack(
                        'Transaction saved: ${transaction.merchant}',
                        const Color(0xFF4CAF50),
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
    return BudgetCategoryList(
      categories: categories,
      categoryBudgets: categoryBudgets,
      savingsGoals: savingsGoals,
      transactions: transactions,
      expandedCategories: expandedCategories,
      isEditing: isEditingBudgets,
      totalBudget: totalBudget,
      totalBudgeted: totalBudgeted,
      onEditToggle: _toggleEditMode,
      onAddCategory: _showManageCategoriesDialog,
      onToggleExpanded: (key) => setState(() {
        expandedCategories.contains(key)
            ? expandedCategories.remove(key)
            : expandedCategories.add(key);
      }),
    );
  }

  void _showEditBudgetDialog() {
    showEditTotalBudgetDialog(
      context,
      totalBudget: totalBudget,
      budgetEqualsIncome: budgetEqualsIncome,
      totalIncome: totalIncome,
      onSaved: (equalsIncome, budget) => setState(() {
        budgetEqualsIncome = equalsIncome;
        totalBudget = budget;
      }),
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (isEditingBudgets) {
        _saveAllBudgets();
      } else {
        _enterEditMode();
      }
    });
  }

  void _enterEditMode() {
    setState(() => isEditingBudgets = true);
  }

  void _saveAllBudgets() {
    setState(() {
      isEditingBudgets = false;
      _generateRecommendations();
    });

    _saveUserBudgetData();

    _showSnack('Budgets saved successfully!', const Color(0xFF0D47A1));
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
        _saveUserBudgetData();
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

  void _openTransactionDialog({
    Transaction? existing,
    Map<String, Map<String, SubcategoryBudget>>? budgets,
    ValueChanged<Transaction>? onUpdated,
    ValueChanged<Transaction>? onDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        categories: categories,
        categoryBudgets: budgets,
        existingTransaction: existing,
        onTransactionAdded: _addTransaction,
        onTransactionUpdated: onUpdated,
        onTransactionDeleted: onDeleted,
        savingsGoals: savingsGoals,
        onGoalUpdated: _updateGoal,
      ),
    );
  }

  void _showAddTransactionDialog() =>
      _openTransactionDialog(budgets: categoryBudgets);

  void _updateGoal(SavingsGoal goal) {
    setState(() => _ledger.updateGoal(goal));
    _saveUserBudgetData();
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _ledger.add(transaction);
      // Logging income switches the budget to follow income automatically.
      if (transaction.type == TransactionType.income) {
        budgetEqualsIncome = true;
      }
      _generateRecommendations();
      _ledger.generateRecurring(base: transaction);
    });
    _saveUserBudgetData();
    _showSnack(
      'Transaction added: €${transaction.amount.toStringAsFixed(2)}',
      const Color(0xFF4CAF50),
    );
  }

  void _editTransaction(Transaction transaction) => _openTransactionDialog(
    existing: transaction,
    onUpdated: _updateTransaction,
    onDeleted: _deleteTransaction,
  );

  void _updateTransaction(Transaction updatedTransaction) {
    setState(() {
      _ledger.update(updatedTransaction);
      _generateRecommendations();
      _ledger.generateRecurring(base: updatedTransaction);
    });
    _saveUserBudgetData();
    _showSnack(
      'Transaction updated: €${updatedTransaction.amount.toStringAsFixed(2)}',
      const Color(0xFF0D47A1),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    setState(() {
      _ledger.delete(transaction);
      _generateRecommendations();
    });
    _saveUserBudgetData();
    _showSnack(
      'Transaction deleted: €${transaction.amount.toStringAsFixed(2)}',
      const Color(0xFFFF4D67),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // A reviewed bank transaction is new to the budget, so "save" adds it.
  void _editBankTransaction(Transaction transaction) => _openTransactionDialog(
    existing: transaction,
    onUpdated: (updated) {
      _addTransaction(updated);
      _showSnack(
        'Bank transaction added: €${updated.amount.toStringAsFixed(2)}',
        const Color(0xFF4CAF50),
      );
    },
  );
}
