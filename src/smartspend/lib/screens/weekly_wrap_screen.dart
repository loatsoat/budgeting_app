import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class WeeklyWrapScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, CategoryData> categories;

  const WeeklyWrapScreen({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  State<WeeklyWrapScreen> createState() => _WeeklyWrapScreenState();
}

class _WeeklyWrapScreenState extends State<WeeklyWrapScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late AnimationController _textController;
  late Animation<double> _slideAnimation;
  late Animation<double> _textAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 6;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    
    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _textController.reset();
      _slideController.reset();
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      
      Future.delayed(const Duration(milliseconds: 200), () {
        _slideController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          _textController.forward();
        });
      });
    } else {
      Navigator.of(context).pop();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1224),
              Color(0xFF1A1F33),
              Color(0xFF101528),
            ],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildWelcomePage(),
              _buildTotalSpentPage(),
              _buildBiggestTransactionPage(),
              _buildDailyAveragePage(),
              _buildSpendingStreakPage(),
              _buildSummaryPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildCard(
      index: 0,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _textAnimation,
            child: const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _textAnimation,
            child: const Text(
              'Your Weekly\nSpending Wrap',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _textAnimation,
            child: Text(
              'Let\'s see how you spent\nyour money this week',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 18,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSpentPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final totalSpent = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return _buildCard(
      index: 1,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _textAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💰', style: TextStyle(fontSize: 50)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: const Text(
            'Total Spent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'This week you spent',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            '${totalSpent.toStringAsFixed(0)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            '${weeklyTransactions.length} transactions',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBiggestTransactionPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final expenseTransactions = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    
    if (expenseTransactions.isEmpty) {
      return _buildNoDataPage('No Expenses', 'You haven\'t spent anything this week!');
    }
    
    // Find the biggest transaction
    final biggestTransaction = expenseTransactions
        .reduce((a, b) => a.amount > b.amount ? a : b);

    return _buildCard(
      index: 2,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _textAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💸', style: TextStyle(fontSize: 50)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: const Text(
            'Biggest Transaction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'Your largest expense was',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            '${biggestTransaction.amount.toStringAsFixed(0)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            biggestTransaction.category,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataPage(String title, String message) {
    return _buildCard(
      index: 2,
      content: [
        const Icon(
          Icons.sentiment_satisfied,
          size: 80,
          color: Colors.white,
        ),
        const SizedBox(height: 28),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyAveragePage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final totalSpent = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final dailyAverage = totalSpent / 7;

    return _buildCard(
      index: 3,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'Your daily average',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(height: 22),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            '€${dailyAverage.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'per day this week',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingStreakPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final daysWithSpending = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;

    return _buildCard(
      index: 4,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'You spent money on',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(height: 22),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            '$daysWithSpending',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 66,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'out of 7 days',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    return _buildCard(
      index: 5,
      isLast: true,
      content: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: const Icon(
            Icons.celebration,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 28),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: const Text(
            'Great job tracking\nyour spending!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: Text(
            'Keep it up and reach\nyour financial goals',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 18,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  List<Transaction> _getWeeklyTransactions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return widget.transactions.where((transaction) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEndDate = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
      
      return transactionDate.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(weekEndDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Shared gradient card providing consistent layout + scroll safety
  Widget _buildCard({
    required int index,
    required List<Widget> content,
    bool isLast = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _buildGenZGradient(index),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24 - 24 - 80,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: content,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLast ? () => Navigator.of(context).pop() : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.28),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Back to Overview' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildIndicators(),
            ],
          ),
        );
      },
    );
  }

  // Gen Z vibrant gradients per page
  LinearGradient _buildGenZGradient(int index) {
    switch (index) {
      case 0:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F5AF0), Color(0xFFFF7AC3), Color(0xFF00D1FF)],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFA07A), Color(0xFFFF6FB2), Color(0xFF8E44AD)],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CFF2E), Color(0xFF00E5A8), Color(0xFF00A3FF)],
        );
      case 3:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD1A0), Color(0xFFFF8FB1), Color(0xFFB388FF)],
        );
      case 4:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF00C2FF), Color(0xFF6C5CE7), Color(0xFFE84393)],
        );
      case 5:
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7AE582), Color(0xFFC084FC), Color(0xFFFF75C3)],
        );
    }
  }

  // Unified page indicators
  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}