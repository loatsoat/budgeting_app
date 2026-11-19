import '../../../models/budget_models.dart';

/// Sample transactions shown by the simulated bank-card connection
/// (there is no real banking API behind it).
List<Transaction> demoBankTransactions() => [
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
