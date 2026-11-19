import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import '../widgets/wrap_slide_card.dart';

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

  // Slides [child] up from [dy] (and fades it in) in sync with the page-entry animations.
  Widget _reveal(double dy, Widget child, {bool fade = true}) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, dy),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: fade
          ? FadeTransition(opacity: _textAnimation, child: child)
          : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeklyTransactions = _getWeeklyTransactions();

    // If no transactions, show a message and return
    if (weeklyTransactions.isEmpty) {
      return const WrapEmptyState();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
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
        _reveal(
          0.5,
          const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 28),
        _reveal(
          0.3,
          const Text(
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
        const SizedBox(height: 14),
        _reveal(
          0.2,
          Text(
            'Let\'s see how you spent\nyour money this week',
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

  Widget _buildTotalSpentPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final totalSpent = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return _statSlide(
      index: 1,
      emoji: '💰',
      title: 'Total Spent',
      subtitle: 'This week you spent',
      value: '${totalSpent.toStringAsFixed(0)} €',
      caption: '${weeklyTransactions.length} transactions',
    );
  }

  Widget _buildBiggestTransactionPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final expenseTransactions = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return _buildNoDataPage(
        'No Expenses',
        'You haven\'t spent anything this week!',
      );
    }

    // Find the biggest transaction
    final biggestTransaction = expenseTransactions.reduce(
      (a, b) => a.amount > b.amount ? a : b,
    );

    return _statSlide(
      index: 2,
      emoji: '💸',
      title: 'Biggest Transaction',
      subtitle: 'Your largest expense was',
      value: '${biggestTransaction.amount.toStringAsFixed(0)} €',
      caption: biggestTransaction.category,
    );
  }

  // Shared layout of the "big number" slides: emoji badge, title, subtitle, value, caption.
  Widget _statSlide({
    required int index,
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
    required String caption,
  }) {
    return _buildCard(
      index: index,
      content: [
        _reveal(
          0.3,
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 50)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _reveal(
          0.2,
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          fade: false,
        ),
        const SizedBox(height: 12),
        _reveal(
          0.1,
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
          fade: false,
        ),
        const SizedBox(height: 28),
        _reveal(
          0.3,
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          fade: false,
        ),
        const SizedBox(height: 12),
        _reveal(
          0.1,
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
          fade: false,
        ),
      ],
    );
  }

  Widget _buildNoDataPage(String title, String message) {
    return _buildCard(
      index: 2,
      content: [
        const Icon(Icons.sentiment_satisfied, size: 80, color: Colors.white),
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

    return _numberSlide(
      index: 3,
      lead: 'Your daily average',
      value: '€${dailyAverage.toStringAsFixed(0)}',
      caption: 'per day this week',
    );
  }

  Widget _buildSpendingStreakPage() {
    final weeklyTransactions = _getWeeklyTransactions();
    final daysWithSpending = weeklyTransactions
        .where((t) => t.type == TransactionType.expense)
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;

    return _numberSlide(
      index: 4,
      lead: 'You spent money on',
      value: '$daysWithSpending',
      caption: 'out of 7 days',
      valueSize: 66,
      captionGap: 10,
    );
  }

  // Shared layout of the "lead-in, big number, caption" slides.
  Widget _numberSlide({
    required int index,
    required String lead,
    required String value,
    required String caption,
    double valueSize = 60,
    double captionGap = 12,
  }) {
    return _buildCard(
      index: index,
      content: [
        _reveal(
          0.3,
          Text(
            lead,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 24,
            ),
          ),
          fade: false,
        ),
        const SizedBox(height: 22),
        _reveal(
          0.5,
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          fade: false,
        ),
        SizedBox(height: captionGap),
        _reveal(
          0.2,
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
            ),
          ),
          fade: false,
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    return _buildCard(
      index: 5,
      isLast: true,
      content: [
        _reveal(
          0.3,
          const Icon(Icons.celebration, size: 80, color: Colors.white),
          fade: false,
        ),
        const SizedBox(height: 28),
        _reveal(
          0.2,
          const Text(
            'Great job tracking\nyour spending!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          fade: false,
        ),
        const SizedBox(height: 12),
        _reveal(
          0.1,
          Text(
            'Keep it up and reach\nyour financial goals',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 18,
              height: 1.35,
            ),
          ),
          fade: false,
        ),
      ],
    );
  }

  // Monday 00:00 up to (not including) next Monday 00:00. Built from calendar
  // fields rather than subtracting Durations so DST changes can't shift the day.
  List<Transaction> _getWeeklyTransactions() {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final nextWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 7,
    );
    return widget.transactions
        .where(
          (t) => !t.date.isBefore(weekStart) && t.date.isBefore(nextWeekStart),
        )
        .toList();
  }

  Widget _buildCard({
    required int index,
    required List<Widget> content,
    bool isLast = false,
  }) {
    return WrapSlideCard(
      index: index,
      content: content,
      isLast: isLast,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onNext: _nextPage,
    );
  }
}
