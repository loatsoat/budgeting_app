import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_models.dart';
import 'budget_data_service.dart';
import 'spending_recommendations_service.dart';
import 'simple_auth_manager.dart';
import '../utils/constants.dart';

/// Manages the budget app state and business logic
/// Separates state management from UI concerns
class BudgetStateManager {
  // UI State
  String activeTab = AppConstants.overviewTab;
  bool isEditingBudgets = false;
  List<String> expandedCategories = [];

  // Budget Data
  double totalBudget = AppConstants.defaultTotalBudget;
  bool budgetEqualsIncome = false;
  List<Transaction> transactions = [];
  Map<String, CategoryData> categories = Map.from(defaultCategories);
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets = _getDefaultBudgets();

  // Savings & Recommendations
  List<SavingsGoal> savingsGoals = [];
  List<SpendingRecommendation> spendingRecommendations = [];

  // Bank & Card Integration
  bool isCardConnected = false;
  List<Transaction> bankTransactions = [];

  /// Initialize the state manager
  Future<void> initialize() async {
    await _loadUserBudgetData();
    await _loadCardConnectionStatus();
    _initializeBankTransactions();
  }

  /// Load user's budget data from persistent storage
  Future<void> _loadUserBudgetData() async {
    final currentUser = SimpleAuthManager.instance.currentUser;
    if (currentUser != null) {
      final data = await BudgetDataService.loadBudgetData(currentUser.id);
      if (data != null) {
        totalBudget = data['totalBudget'] ?? AppConstants.defaultTotalBudget;
        budgetEqualsIncome = data['budgetEqualsIncome'] ?? false;
        transactions = data['transactions'] ?? [];
        categoryBudgets = data['categoryBudgets'] ?? _getDefaultBudgets();
        savingsGoals = data['savingsGoals'] ?? [];
      }
    }
    _generateRecommendations();
  }

  /// Save all budget data
  Future<void> saveAllBudgetData() async {
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

  /// Load card connection status
  Future<void> _loadCardConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isCardConnected = prefs.getBool(AppConstants.bankCardConnectedKey) ?? false;
  }

  /// Save card connection status
  Future<void> saveCardConnectionStatus(bool connected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.bankCardConnectedKey, connected);
    isCardConnected = connected;
  }

  /// Initialize mock bank transactions for display
  void _initializeBankTransactions() {
    bankTransactions = AppConstants.mockBankTransactions
        .map((txn) => Transaction(
              id: txn['id'],
              type: txn['type'] == 'expense'
                  ? TransactionType.expense
                  : TransactionType.income,
              amount: txn['amount'],
              category: txn['category'],
              categoryKey: txn['categoryKey'],
              note: txn['note'],
              date: DateTime.now().subtract(Duration(days: txn['daysAgo'])),
              merchant: txn['merchant'],
            ))
        .toList();
  }

  /// Generate spending recommendations based on current data
  void _generateRecommendations() {
    spendingRecommendations = SpendingRecommendationsService.generateRecommendations(
      transactions: transactions,
      categoryBudgets: categoryBudgets,
      totalBudget: totalBudget,
      totalIncome: totalBudget,
    );
  }

  /// Get default budget structure
  static Map<String, Map<String, SubcategoryBudget>> _getDefaultBudgets() {
    return {
      AppConstants.housingCategory: {
        'Rent': SubcategoryBudget(
          budgeted: AppConstants.defaultRentBudget,
          spent: AppConstants.defaultRentBudget,
        ),
        'Gym': SubcategoryBudget(
          budgeted: AppConstants.defaultGymBudget,
          spent: AppConstants.defaultGymBudget,
        ),
      },
      AppConstants.foodCategory: {
        'Groceries': SubcategoryBudget(
          budgeted: AppConstants.defaultGroceriesBudget,
          spent: AppConstants.defaultGroceriesBudget,
        ),
      },
      AppConstants.savingsCategory: {
        'Savings': SubcategoryBudget(
          budgeted: AppConstants.defaultSavingsBudget,
          spent: AppConstants.defaultSavingsBudget,
        ),
      },
    };
  }

  /// Switch to a different tab
  void switchTab(String tabName) {
    activeTab = tabName;
  }

  /// Enter edit mode
  void enterEditMode() {
    isEditingBudgets = true;
  }

  /// Exit edit mode and save
  void exitEditMode() {
    isEditingBudgets = false;
  }

  /// Toggle category expansion
  void toggleCategoryExpanded(String categoryKey) {
    if (expandedCategories.contains(categoryKey)) {
      expandedCategories.remove(categoryKey);
    } else {
      expandedCategories.add(categoryKey);
    }
  }

  /// Check if category is expanded
  bool isCategoryExpanded(String categoryKey) {
    return expandedCategories.contains(categoryKey);
  }
}
