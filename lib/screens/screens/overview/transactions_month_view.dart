import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';
import 'overview_colors.dart';

// New full-screen month view with swipe navigation
class TransactionsMonthView extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, CategoryData>? categories;
  final Function(Transaction)? onTransactionEdit;

  const TransactionsMonthView({
    super.key,
    required this.transactions,
    this.categories,
    this.onTransactionEdit,
  });

  @override
  State<TransactionsMonthView> createState() => _TransactionsMonthViewState();
}

class _TransactionsMonthViewState extends State<TransactionsMonthView> {
  late PageController _pageController;
  late List<DateTime> _monthsList;
  late int _currentMonthIndex;

  @override
  void initState() {
    super.initState();
    _monthsList = _generateMonthsList();

    // Find current month index
    final now = DateTime.now();
    _currentMonthIndex = _monthsList.indexWhere(
      (month) => month.year == now.year && month.month == now.month,
    );
    if (_currentMonthIndex == -1) _currentMonthIndex = 0;

    _pageController = PageController(initialPage: _currentMonthIndex);
  }

  List<DateTime> _generateMonthsList() {
    if (widget.transactions.isEmpty) {
      return [DateTime.now()];
    }

    // Find earliest and latest transaction dates
    DateTime earliest = widget.transactions.first.date;
    DateTime latest = widget.transactions.first.date;

    for (final transaction in widget.transactions) {
      if (transaction.date.isBefore(earliest)) earliest = transaction.date;
      if (transaction.date.isAfter(latest)) latest = transaction.date;
    }

    // Include current month even if no transactions
    final now = DateTime.now();
    if (latest.isBefore(now)) latest = now;

    // Generate list of months from earliest to latest
    final List<DateTime> months = [];
    DateTime current = DateTime(earliest.year, earliest.month);
    final end = DateTime(latest.year, latest.month);

    while (!current.isAfter(end)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }

    // Reverse so newest months come first
    return months.reversed.toList();
  }

  List<Transaction> _getTransactionsForMonth(DateTime month) {
    return widget.transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Transactions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthNavigationHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              reverse: true,
              onPageChanged: (index) {
                setState(() {
                  _currentMonthIndex = index;
                });
              },
              itemCount: _monthsList.length,
              itemBuilder: (context, index) {
                final month = _monthsList[index];
                final transactions = _getTransactionsForMonth(month);
                return _buildMonthTransactions(month, transactions);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigationHeader() {
    final currentMonth = _monthsList[_currentMonthIndex];
    final monthName = _getMonthName(currentMonth.month);
    final year = currentMonth.year;
    final canGoPrevious = _currentMonthIndex > 0;
    final canGoNext = _currentMonthIndex < _monthsList.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        border: Border(
          bottom: BorderSide(color: OverviewColors.white10, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: canGoPrevious
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: canGoPrevious
                  ? const Color(0xFF5B8DEF)
                  : OverviewColors.white30,
              size: 32,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Could show month picker here
              },
              child: Column(
                children: [
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    year.toString(),
                    style: const TextStyle(
                      color: OverviewColors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: canGoNext
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: canGoNext
                  ? const Color(0xFF5B8DEF)
                  : OverviewColors.white30,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTransactions(
    DateTime month,
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: OverviewColors.white30),
            const SizedBox(height: 16),
            Text(
              'No transactions this month',
              style: TextStyle(color: OverviewColors.white60, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe left or right to view other months',
              style: TextStyle(color: OverviewColors.white50, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Calculate monthly totals
    double totalIncome = 0;
    double totalExpenses = 0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpenses += transaction.amount;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Monthly summary
        Row(
          children: [
            Expanded(
              child: _buildMonthlySummaryCard(
                'Income',
                totalIncome,
                const Color(0xFF4CAF50),
                Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMonthlySummaryCard(
                'Expenses',
                totalExpenses,
                Colors.red,
                Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Transaction count
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${transactions.length} transaction${transactions.length != 1 ? 's' : ''}',
            style: const TextStyle(
              color: OverviewColors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Transactions list
        ...transactions.map(
          (transaction) => _buildTransactionItem(transaction),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B5C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: OverviewColors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final category = widget.categories?[transaction.categoryKey];
    final isIncome = transaction.type == TransactionType.income;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.onTransactionEdit?.call(transaction);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3B5C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (category?.solidColor ?? Colors.grey).withValues(
                  alpha: 0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  category?.icon ?? '💰',
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
                    transaction.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (transaction.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        transaction.note,
                        style: const TextStyle(
                          color: OverviewColors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatDate(transaction.date),
                      style: const TextStyle(
                        color: OverviewColors.white50,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}€${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? const Color(0xFF4CAF50) : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month).substring(0, 3)}';
    }
  }
}
