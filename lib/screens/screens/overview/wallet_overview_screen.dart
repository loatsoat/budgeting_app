import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import 'overview_colors.dart';
import 'transactions_month_view.dart';
import 'savings_goals_section.dart';
import 'weekly_insights_card.dart';

class WalletOverviewContent extends StatefulWidget {
  final List<Transaction>? transactions;
  final Map<String, CategoryData>? categories;
  final double? totalBudget;
  final double? totalSpent;
  final Function(Transaction)? onTransactionEdit;
  final ValueChanged<bool>? onListStateChanged;
  final ValueNotifier<int>? tabNotifier;
  final bool? budgetEqualsIncome;
  final List<SavingsGoal>? savingsGoals;
  final Function(SavingsGoal)? onGoalCreated;
  final Function(SavingsGoal)? onGoalUpdated;
  final Function(SavingsGoal)? onGoalDeleted;
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
    this.budgetEqualsIncome,
    this.savingsGoals,
    this.onGoalCreated,
    this.onGoalUpdated,
    this.onGoalDeleted,
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
            Expanded(child: _buildOverviewContent()),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector() {
    // PERFORMANCE: Wrap static button in RepaintBoundary
    // Commented out - Transactions now have a dedicated tab in bottom navigation
    return const SizedBox.shrink();
  }

  Widget _buildPersonalWalletCard() {
    final transactions = widget.transactions ?? [];

    // Prefer totalSpent provided by parent (BudgetApp) to keep values in sync.
    double totalExpenses;
    double totalIncome = 0;

    // Compute values for the current calendar month to avoid inflated totals
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    if (widget.totalSpent != null) {
      totalExpenses = widget.totalSpent!;
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          final d = transaction.date;
          final inThisMonth =
              !d.isBefore(thisMonthStart) && d.isBefore(nextMonthStart);
          if (inThisMonth) totalIncome += transaction.amount;
        }
      }
    } else {
      totalExpenses = 0;
      for (final transaction in transactions) {
        final d = transaction.date;
        final inThisMonth =
            !d.isBefore(thisMonthStart) && d.isBefore(nextMonthStart);
        if (!inThisMonth) continue;

        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpenses += transaction.amount;
        }
      }
    }

    final totalBudget = widget.totalBudget ?? 1000.0;
    // Note: totalBudget from parent (app_budget.dart) already includes income (availableBudget)
    // So we don't add income again here
    final leftToSpend = totalBudget - totalExpenses;
    final spentPercentage = totalBudget > 0
        ? (totalExpenses / totalBudget)
        : 0.0;

    // PERFORMANCE: Wrap card in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: OverviewColors.surfaceDark80, // PERFORMANCE: Pre-computed
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: OverviewColors.white10,
              ), // PERFORMANCE: Pre-computed
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${leftToSpend.abs().toStringAsFixed(0)} € ',
                        style: TextStyle(
                          color: leftToSpend < 0
                              ? Colors.red
                              : const Color(0xFF4CAF50),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: leftToSpend < 0
                            ? 'budget exceeded'
                            : 'left to spend',
                        style: TextStyle(
                          color: leftToSpend < 0 ? Colors.red : Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildProgressBar(double spentPercentage) {
    final percentage = spentPercentage * 100;
    final displayPercentage = percentage.clamp(0.0, 100.0);

    // PERFORMANCE: Wrap static progress bar in RepaintBoundary
    return RepaintBoundary(
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: OverviewColors.background80, // PERFORMANCE: Pre-computed
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: OverviewColors.background50, // PERFORMANCE: Pre-computed
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: spentPercentage.clamp(0.0, 1.0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: percentage > 100
                      ? Colors
                            .red // Red - over budget
                      : percentage > 80
                      ? const Color(0xFFFF9800) // Orange - warning
                      : const Color(0xFF4CAF50), // Green - under budget
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${displayPercentage.toStringAsFixed(0)}%',
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
      ),
    );
  }

  Widget _buildFinancialSummary(
    double totalIncome,
    double totalExpenses,
    double leftToSpend,
  ) {
    // Show INCOME when the "Budget = Income" switch is ON; otherwise show BUDGET.
    final showIncome = (widget.budgetEqualsIncome ?? false);
    final incomeLabel = showIncome ? 'INCOME' : 'BUDGET';
    final incomeAmountValue = showIncome
        ? totalIncome
        : (widget.totalBudget ?? totalIncome);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryItem(
          incomeLabel,
          '${incomeAmountValue.toStringAsFixed(0)}€',
          const Color(0xFF4CAF50),
        ),
        _buildSummaryItem(
          'EXPENSES',
          '${totalExpenses.toStringAsFixed(0)}€',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    // PERFORMANCE: Wrap static summary items in RepaintBoundary
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: OverviewColors.white60, // PERFORMANCE: Pre-computed
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
      ),
    );
  }

  Widget _buildWeeklyInsightsCard() {
    // PERFORMANCE: Wrap card in RepaintBoundary
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value * 1.5),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: WeeklyInsightsCard(
            transactions: widget.transactions ?? [],
            categories: widget.categories ?? {},
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsSection() {
    return SavingsGoalsSection(
      goals: widget.savingsGoals ?? [],
      onGoalCreated: widget.onGoalCreated,
      onGoalUpdated: widget.onGoalUpdated,
      onGoalDeleted: widget.onGoalDeleted,
      onTransactionAdded: widget.onTransactionAdded,
    );
  }

  Widget _buildOverviewContent() {
    final double bottomNavReserve =
        MediaQuery.of(context).padding.bottom + 180.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildViewAllTransactionsButton(),
          const SizedBox(height: 20),
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

  Widget _buildViewAllTransactionsButton() {
    return GestureDetector(
      onTap: () => _showAllTransactions(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5B8DEF), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF5B8DEF), size: 20),
            const SizedBox(width: 12),
            const Text(
              'VIEW ALL TRANSACTIONS',
              style: TextStyle(
                color: Color(0xFF5B8DEF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTransactions() {
    final transactions = widget.transactions ?? [];

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transactions yet'),
          backgroundColor: Color(0xFF5B8DEF),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionsMonthView(
          transactions: transactions,
          categories: widget.categories,
          onTransactionEdit: widget.onTransactionEdit,
        ),
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
}
