import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import '../../weekly_wrap_screen.dart';
import '../../../widgets/savings_goal_card.dart';
import '../../../widgets/goal_dialogs.dart';

// PERFORMANCE: Pre-define transparent colors to avoid runtime alpha calculations
class _PerformanceColors {
  // Replace: Colors.white.withValues(alpha: 0.05)
  static const white05 = Color(0x0DFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.1)
  static const white10 = Color(0x1AFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.2)
  static const white20 = Color(0x33FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.3)
  static const white30 = Color(0x4DFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.5)
  static const white50 = Color(0x80FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.6)
  static const white60 = Color(0x99FFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.8)
  static const white80 = Color(0xCCFFFFFF);
  // Replace: Colors.white.withValues(alpha: 0.9)
  static const white90 = Color(0xE6FFFFFF);
  
  // Replace: Colors.black.withValues(alpha: 0.3)
  static const black30 = Color(0x4D000000);
  
  // Replace: Color(0xFF2A3B5C).withValues(alpha: 0.8)
  static const surfaceDark80 = Color(0xCC2A3B5C);
  // Replace: Color(0xFF1A1F3A).withValues(alpha: 0.8)
  static const background80 = Color(0xCC1A1F3A);
  // Replace: Color(0xFF1A1F3A).withValues(alpha: 0.5)
  static const background50 = Color(0x801A1F3A);
  // Replace: Color(0xFF00A8E8).withValues(alpha: 0.15)
  static const accent15 = Color(0x2600A8E8);
  
  // Replace: Color(0xFF00F5FF).withValues(alpha: 0.2)
  static const cyan20 = Color(0x3300F5FF);
  // Replace: Color(0xFF00F5FF).withValues(alpha: 0.3)
  static const cyan30 = Color(0x4D00F5FF);
}

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
        onTransactionEdit: widget.onTransactionEdit,
      ),
    );
  }

  Widget _buildTabSelector() {
    // PERFORMANCE: Wrap static button in RepaintBoundary
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _PerformanceColors.white10, // PERFORMANCE: Pre-computed color
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () => _showAllTransactionsSheet(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8E8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: _PerformanceColors.accent15, // PERFORMANCE: Pre-computed
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.receipt_long, color: Color(0xFF1A1F3A), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'VIEW ALL TRANSACTIONS',
                    textAlign: TextAlign.left,
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
      ),
    );
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
          final inThisMonth = !d.isBefore(thisMonthStart) && d.isBefore(nextMonthStart);
          if (inThisMonth) totalIncome += transaction.amount;
        }
      }
    } else {
      totalExpenses = 0;
      for (final transaction in transactions) {
        final d = transaction.date;
        final inThisMonth = !d.isBefore(thisMonthStart) && d.isBefore(nextMonthStart);
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
    final spentPercentage = totalBudget > 0 ? (totalExpenses / totalBudget) : 0.0;
    
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
              color: _PerformanceColors.surfaceDark80, // PERFORMANCE: Pre-computed
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _PerformanceColors.white10), // PERFORMANCE: Pre-computed
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text( // PERFORMANCE: Use const
                  'PERSONAL WALLET',
                  style: TextStyle(
                    color: _PerformanceColors.white60, // PERFORMANCE: Pre-computed
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${leftToSpend.abs().toStringAsFixed(0)} € ',
                      style: TextStyle(
                        color: leftToSpend < 0 ? const Color(0xFFE57373) : const Color(0xFF4CAF50),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: leftToSpend < 0 ? 'budget exceeded' : 'left to spend',
                      style: TextStyle(
                        color: leftToSpend < 0 ? const Color(0xFFE57373) : Colors.white,
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
          color: _PerformanceColors.background80, // PERFORMANCE: Pre-computed
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: _PerformanceColors.background50, // PERFORMANCE: Pre-computed
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: spentPercentage.clamp(0.0, 1.0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: percentage > 100
                      ? const Color(0xFFE57373) // Red - over budget
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

  Widget _buildFinancialSummary(double totalIncome, double totalExpenses, double leftToSpend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryItem('INCOME', '${totalIncome.toStringAsFixed(0)}€', const Color(0xFF4CAF50)),
        _buildSummaryItem('EXPENSES', '${totalExpenses.toStringAsFixed(0)}€', const Color(0xFFE57373)),
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
              color: _PerformanceColors.white60, // PERFORMANCE: Pre-computed
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF2A3B5C), // Use same surface color as other cards for consistency
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'WEEKLY INSIGHTS',
                      style: TextStyle(
                        color: _PerformanceColors.white90, // PERFORMANCE: Pre-computed
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text(
                'Your spending\nlast week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Here\'s your breakdown',
                style: TextStyle(
                  color: _PerformanceColors.white80, // PERFORMANCE: Pre-computed
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildWeeklyChart(),
              const SizedBox(height: 16),
              // View Weekly Wrap Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showWeeklyWrap(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F3A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
                  child: const Icon(
                    Icons.close,
                    color: _PerformanceColors.white80,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Empty wallet icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: _PerformanceColors.white20,
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
              const Text(
                'Start spending to see your\nweekly insights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _PerformanceColors.white80,
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
                    backgroundColor: _PerformanceColors.black30,
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
              color: _PerformanceColors.white05,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _PerformanceColors.white10,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.track_changes,
                  size: 48,
                  color: _PerformanceColors.white30,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Goals Yet',
                  style: TextStyle(
                    color: _PerformanceColors.white80,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a savings goal to start tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _PerformanceColors.white50,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: goals.length,
              padEnds: false,
              controller: PageController(viewportFraction: 0.9),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SavingsGoalCard(
                    goal: goal,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1F33),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border.fromBorderSide(BorderSide(color: _PerformanceColors.white10)),
                            ),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.add_circle_outline, color: Colors.white),
                                    title: const Text('Add Money', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      showAddMoneyDialog(context, goal, (amount) {
                                        final updatedGoal = goal;
                                        updatedGoal.currentAmount += amount;
                                        widget.onGoalUpdated?.call(updatedGoal);
                                        if (widget.onTransactionAdded != null) {
                                          final transaction = Transaction(
                                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                                            type: TransactionType.expense,
                                            amount: amount,
                                            category: 'Savings',
                                            categoryKey: 'savings',
                                            note: 'Saved for ${goal.name}',
                                            date: DateTime.now(),
                                            excludeFromBudget: true,
                                            description: 'Added to savings goal: ${goal.name}',
                                          );
                                          widget.onTransactionAdded?.call(transaction);
                                        }
                                      });
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.edit, color: Colors.white),
                                    title: const Text('Edit Goal', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      showEditGoalDialog(
                                        context,
                                        goal,
                                        onGoalUpdated: (g) => widget.onGoalUpdated?.call(g),
                                        onGoalDeleted: () => widget.onGoalDeleted?.call(goal),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Color(0xFFFF4D67)),
                                    title: const Text('Delete Goal', style: TextStyle(color: Color(0xFFFF4D67))),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      showEditGoalDialog(
                                        context,
                                        goal,
                                        onGoalUpdated: (g) => widget.onGoalUpdated?.call(g),
                                        onGoalDeleted: () => widget.onGoalDeleted?.call(goal),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      );
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
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewContent() {
    final double bottomNavReserve = MediaQuery.of(context).padding.bottom + 180.0;
    
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

// Stateful Widget for Month-based Transaction Filtering
class _TransactionsByMonthSheet extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, CategoryData> categories;
  final Function(Transaction)? onTransactionEdit;

  const _TransactionsByMonthSheet({
    required this.transactions,
    required this.categories,
    this.onTransactionEdit,
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
    final filtered = widget.transactions.where((transaction) {
      return transaction.date.year == selectedMonth.year &&
             transaction.date.month == selectedMonth.month;
    }).toList();
    
    // Sort by date (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
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
    // Allow navigation up to 2 years in the future to see recurring transactions
    final now = DateTime.now();
    final maxMonth = DateTime(now.year + 2, now.month);
    return selectedMonth.isBefore(maxMonth);
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
            color: _PerformanceColors.cyan30,
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
                color: _PerformanceColors.white30,
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
                      color: _PerformanceColors.cyan20,
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
                            color: _PerformanceColors.white60,
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
                  color: _PerformanceColors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _PerformanceColors.cyan20,
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
                        color: _canGoNext() ? Colors.white : _PerformanceColors.white30,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Divider(color: _PerformanceColors.white10, height: 1),
            
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
                            color: _PerformanceColors.white30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions in ${_getMonthYearText()}',
                            style: TextStyle(
                              color: _PerformanceColors.white60,
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
    // Get category data from appropriate source
    final categoryData = transaction.type == TransactionType.income
        ? incomeCategories[transaction.categoryKey]
        : categories[transaction.categoryKey];
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Open edit dialog instead of dismissing
        widget.onTransactionEdit?.call(transaction);
        return false; // Don't actually dismiss
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              _PerformanceColors.cyan30,
            ],
          ),
          border: Border(
            top: BorderSide(color: _PerformanceColors.white10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.edit, color: Color(0xFF00F5FF), size: 24),
            const SizedBox(width: 8),
            const Text(
              'EDIT',
              style: TextStyle(
                color: Color(0xFF00F5FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // Show transaction details
          _showTransactionDetails(context, transaction, categories, widget.onTransactionEdit);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F33),
            border: Border(
              top: BorderSide(color: _PerformanceColors.white10),
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
                      const Color(0x33808080),
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
                        color: _PerformanceColors.white60,
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
                      color: _PerformanceColors.white50,
                      fontSize: 10,
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

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    Map<String, CategoryData> categories,
    Function(Transaction)? onTransactionEdit,
  ) {
    // Get category data from appropriate source
    final categoryData = transaction.type == TransactionType.income
        ? incomeCategories[transaction.categoryKey]
        : categories[transaction.categoryKey];
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
            color: _PerformanceColors.cyan30,
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
                        const Color(0x33808080),
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
                          color: _PerformanceColors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: _PerformanceColors.white10),
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
            
            // Edit Button
            if (onTransactionEdit != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onTransactionEdit(transaction);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5FF),
                  foregroundColor: const Color(0xFF1A1F3A),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
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
            color: _PerformanceColors.white60,
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
