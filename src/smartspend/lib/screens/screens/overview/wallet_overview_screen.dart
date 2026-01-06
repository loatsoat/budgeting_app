import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import '../../weekly_wrap_screen.dart';
import '../../../widgets/savings_goal_card.dart';
import '../../../widgets/goal_dialogs.dart';

class WalletOverviewContent extends StatefulWidget {
  final List<Transaction>? transactions;
  final Map<String, CategoryData>? categories;
  final double? totalBudget;
  final double? totalSpent;
  final Function(Transaction)? onTransactionEdit;
  final ValueChanged<bool>? onListStateChanged;
  final ValueNotifier<int>? tabNotifier;
  final List<SavingsGoal>? savingsGoals;
  final Function(SavingsGoal)? onGoalCreated;
  final Function(SavingsGoal)? onGoalUpdated;
  final Function(Transaction)? onTransactionAdded;

  const WalletOverviewContent({
    super.key,
    this.transactions,
    this.categories,
    this.totalBudget,
    this.onTransactionEdit,
    this.totalSpent,
    this.onListStateChanged,
    this.tabNotifier,
    this.savingsGoals,
    this.onGoalCreated,
    this.onGoalUpdated,
    this.onTransactionAdded,
  });

  @override
  State<WalletOverviewContent> createState() => _WalletOverviewContentState();
}

class _WalletOverviewContentState extends State<WalletOverviewContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int selectedTab = 0; // default to OVERVIEW; LIST button will toggle

  @override
  void initState() {
    super.initState();
    // Listen to external tab notifier (if provided)
    widget.tabNotifier?.addListener(_onExternalTabChange);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  void _onExternalTabChange() {
    final val = widget.tabNotifier?.value ?? selectedTab;
    if (val != selectedTab && mounted) {
      setState(() {
        selectedTab = val;
      });
      widget.onListStateChanged?.call(selectedTab == 1);
    }
  }

  @override
  void dispose() {
    widget.tabNotifier?.removeListener(_onExternalTabChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: _buildOverviewContent(),
            ),
          ],
        );
      },
    );
  }

  void _showAllTransactionsSheet() {
    final allTransactions = widget.transactions ?? [];
    final categories = widget.categories ?? {};
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionsByMonthSheet(
        transactions: allTransactions,
        categories: categories,
      ),
    );
  }

  Widget _buildTabSelector() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => _showAllTransactionsSheet(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF00B8FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, color: Color(0xFF1A1F3A), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'VIEW ALL TRANSACTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1A1F3A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalWalletCard() {
    final transactions = widget.transactions ?? [];

    // Prefer totalSpent provided by parent (BudgetApp) to keep values in sync.
    double totalExpenses;
    double totalIncome = 0;

    if (widget.totalSpent != null) {
      totalExpenses = widget.totalSpent!;
      // derive income from transactions only if needed
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) totalIncome += transaction.amount;
      }
    } else {
      // Fallback: compute from transactions
      totalExpenses = 0;
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpenses += transaction.amount;
        }
      }
    }

    final totalBudget = widget.totalBudget ?? 1000.0;
    final leftToSpend = totalBudget - totalExpenses;
    final spentPercentage = totalBudget > 0 ? (totalExpenses / totalBudget) : 0.0;
    
    return Transform.translate(
      offset: Offset(0, _slideAnimation.value),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3B5C).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONAL WALLET',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${leftToSpend.toStringAsFixed(0)} € left to spend',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildProgressBar(spentPercentage),
              const SizedBox(height: 24),
              _buildFinancialSummary(totalIncome, totalExpenses, leftToSpend),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double spentPercentage) {
    final percentage = (spentPercentage * 100).clamp(0.0, 100.0);
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          FractionallySizedBox(
            widthFactor: spentPercentage.clamp(0.0, 1.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: percentage > 80 
                    ? [const Color(0xFFFF4444), const Color(0xFFFF6666)]
                    : [const Color(0xFFFF6B9D), const Color(0xFFFF4081)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(double totalIncome, double totalExpenses, double leftToSpend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryItem('INCOME', '${totalIncome.toStringAsFixed(0)}€', const Color(0xFF4CAF50)),
        _buildSummaryItem('EXPENSES', '${totalExpenses.toStringAsFixed(0)}€', const Color(0xFFFF6B9D)),
        _buildSummaryItem('LEFT', '${leftToSpend.toStringAsFixed(0)}€', const Color(0xFF00F5FF)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyInsightsCard() {
    return Transform.translate(
      offset: Offset(0, _slideAnimation.value * 1.5),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8E44AD),
                Color(0xFF9B59B6),
                Color(0xFFAB47BC)
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E44AD).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'WEEKLY INSIGHTS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'See what your\nmoney was up to\nlast week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Here\'s your breakdown',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildWeeklyChart(),
              const SizedBox(height: 20),
              // View Weekly Wrap Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showWeeklyWrap(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View My Weekly Wrap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeeklyWrap() {
    final transactions = widget.transactions ?? [];
    
    // Check if there are any transactions
    if (transactions.isEmpty) {
      _showNoTransactionsDialog();
      return;
    }
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WeeklyWrapScreen(
          transactions: transactions,
          categories: widget.categories ?? {},
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showNoTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE1A3E8),
                Color(0xFFD896E0),
                Color(0xFFCF89D8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Empty wallet icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'No Transactions Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Start spending to see your\nweekly insights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Removed the weekly bars/labels to avoid the pixel overflow seen on small screens.
    return const SizedBox.shrink();
  }

  Widget _buildSavingsGoalsSection() {
    final goals = widget.savingsGoals ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onGoalCreated != null) {
                  showCreateGoalDialog(context, widget.onGoalCreated!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F5FF), Color(0xFF00D4E6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'New Goal',
                      style: TextStyle(
                        color: Colors.white,
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
        const SizedBox(height: 16),
        if (goals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.track_changes,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Goals Yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a savings goal to start tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...goals.map((goal) => SavingsGoalCard(
                goal: goal,
                onTap: () {
                  // Could add edit dialog here
                },
                onAddMoney: () {
                  showAddMoneyDialog(context, goal, (amount) {
                    // Update the goal
                    final updatedGoal = goal;
                    updatedGoal.currentAmount += amount;
                    widget.onGoalUpdated?.call(updatedGoal);
                    
                    // Create a transaction for the savings
                    if (widget.onTransactionAdded != null) {
                      final transaction = Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: TransactionType.expense,
                        amount: amount,
                        category: 'Savings',
                        categoryKey: 'savings',
                        note: 'Saved for ${goal.name}',
                        date: DateTime.now(),
                        excludeFromBudget: true, // Don't count towards budget
                        description: 'Added to savings goal: ${goal.name}',
                      );
                      widget.onTransactionAdded?.call(transaction);
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added €${amount.toStringAsFixed(0)} to ${goal.name}'),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  });
                },
              )),
      ],
    );
  }

  Widget _buildOverviewContent() {
    final double bottomNavReserve = MediaQuery.of(context).padding.bottom + 140.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPersonalWalletCard(),
          const SizedBox(height: 20),
          _buildWeeklyInsightsCard(),
          const SizedBox(height: 20),
          _buildSavingsGoalsSection(),
          SizedBox(height: bottomNavReserve),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    final double bottomNavReserve = MediaQuery.of(context).padding.bottom + 140.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Back button moved to AppBar; keep list content here
          // Reuse only the month selector + list parts from OverviewListScreen
          _buildMonthSelectorLite(),
          const SizedBox(height: 24),
          _buildTransactionsListLite(),
          SizedBox(height: bottomNavReserve),
        ],
      ),
    );
  }

  // Exposed helper to programmatically show overview
  void showOverview() {
    if (selectedTab != 0) {
      setState(() {
        selectedTab = 0;
      });
      widget.tabNotifier?.value = 0;
      widget.onListStateChanged?.call(false);
    }
  }

  Widget _buildMonthSelectorLite() {
    final transactions = widget.transactions ?? [];
    final currentMonth = DateTime.now();
    final monthName = _getMonthName(currentMonth.month);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3F5F).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F5FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundIconButton(Icons.chevron_left, const Color(0xFF00F5FF)),
          Column(
            children: [
              Text(
                '$monthName ${currentMonth.year}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${transactions.length} TRANSACTIONS',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFF6B9D), shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
          _roundIconButton(Icons.chevron_right, const Color(0xFF00F5FF)),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildTransactionsListLite() {
    final transactions = widget.transactions ?? [];
    final categories = widget.categories ?? {};
    
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F33).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No transactions this month', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text('Tap the + button to add one', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F33).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${transactions.length} transactions',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...transactions.take(10).map((transaction) => _buildTransactionItem(transaction, categories)),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction, Map<String, CategoryData> categories) {
    final categoryData = categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A3F5F),
              Color(0xFF1A2F4F),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Transaction Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: categoryData?.solidColor.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: categoryData?.solidColor.withValues(alpha: 0.4) ?? Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  categoryData?.icon ?? '💰',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction Amount
            Text(
              '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isExpense ? const Color(0xFFFF6B9D) : const Color(0xFF4CAF50),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Category Name
            Text(
              transaction.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Transaction Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Type', isExpense ? 'Expense' : 'Income', isExpense ? const Color(0xFFFF6B9D) : const Color(0xFF4CAF50)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', _formatDate(transaction.date), Colors.white70),
                  const SizedBox(height: 12),
                  _buildDetailRow('Note', transaction.note.isNotEmpty ? transaction.note : 'No note', Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Edit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onTransactionEdit?.call(transaction);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction, Map<String, CategoryData> categories) {
    final categoryData = categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;
    
    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction, categories),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryData?.solidColor.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                categoryData?.icon ?? '💰',
                style: const TextStyle(fontSize: 18),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.note,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount and Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isExpense ? const Color(0xFFFF6B9D) : const Color(0xFF4CAF50),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(transaction.date),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Widget _roundIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// Stateful Widget for Month-based Transaction Filtering
class _TransactionsByMonthSheet extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, CategoryData> categories;

  const _TransactionsByMonthSheet({
    required this.transactions,
    required this.categories,
  });

  @override
  State<_TransactionsByMonthSheet> createState() => _TransactionsByMonthSheetState();
}

class _TransactionsByMonthSheetState extends State<_TransactionsByMonthSheet> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    // Start with current month
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  List<Transaction> _getFilteredTransactions() {
    return widget.transactions.where((transaction) {
      return transaction.date.year == selectedMonth.year &&
             transaction.date.month == selectedMonth.month;
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  String _getMonthYearText() {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  bool _canGoNext() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return selectedMonth.isBefore(currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A3F5F),
              Color(0xFF1A2F4F),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF00F5FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredTransactions.length} in ${_getMonthYearText()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Month Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00F5FF).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      _getMonthYearText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _canGoNext() ? _nextMonth : null,
                      icon: Icon(
                        Icons.chevron_right,
                        color: _canGoNext() ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
            
            // Transactions List
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions in ${_getMonthYearText()}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return _buildTransactionItem(
                          context,
                          transaction,
                          widget.categories,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    Map<String, CategoryData> categories,
  ) {
    final categoryData = categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;

    return GestureDetector(
      onTap: () {
        // Show transaction details
        _showTransactionDetails(context, transaction, categories);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryData?.solidColor.withValues(alpha: 0.2) ??
                    Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  categoryData?.icon ?? '💰',
                  style: const TextStyle(fontSize: 18),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.note,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Amount and Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isExpense
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    Map<String, CategoryData> categories,
  ) {
    final categoryData = categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A3F5F),
              Color(0xFF1A2F4F),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category Icon and Name
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryData?.solidColor.withValues(alpha: 0.2) ??
                        Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      categoryData?.icon ?? '💰',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        transaction.note,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),

            // Amount
            _buildDetailRow(
              'Amount',
              '${isExpense ? '-' : '+'}€${transaction.amount.toStringAsFixed(2)}',
              isExpense ? const Color(0xFFFF6B9D) : const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),

            // Date
            _buildDetailRow(
              'Date',
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              Colors.white,
            ),
            const SizedBox(height: 16),

            // Type
            _buildDetailRow(
              'Type',
              transaction.type == TransactionType.expense
                  ? 'Expense'
                  : transaction.type == TransactionType.income
                      ? 'Income'
                      : 'Transfer',
              Colors.white,
            ),

            if (transaction.merchant != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Merchant', transaction.merchant!, Colors.white),
            ],

            if (transaction.description != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Description', transaction.description!, Colors.white),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
