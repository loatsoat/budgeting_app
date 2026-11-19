import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend/models/budget_models.dart';
import 'package:smartspend/services/budget_ledger.dart';

Transaction tx(
  String id, {
  double amount = 10,
  String categoryKey = 'food',
  String category = 'Groceries',
  TransactionType type = TransactionType.expense,
  DateTime? date,
  bool exclude = false,
  RecurrenceType recurrence = RecurrenceType.never,
  DateTime? recurrenceEnd,
}) => Transaction(
  id: id,
  type: type,
  amount: amount,
  category: category,
  categoryKey: categoryKey,
  note: 'n',
  date: date ?? DateTime(2025, 3, 10),
  excludeFromBudget: exclude,
  recurrence: recurrence,
  recurrenceEndDate: recurrenceEnd,
);

BudgetLedger emptyLedger() =>
    BudgetLedger(transactions: [], categoryBudgets: {});

double spent(BudgetLedger l, String key, String sub) =>
    l.categoryBudgets[key]![sub]!.spent;

void main() {
  group('BudgetLedger', () {
    test('add counts an expense and creates missing subcategories', () {
      final l = emptyLedger()..add(tx('1', amount: 12.5));
      expect(spent(l, 'food', 'Groceries'), 12.5);
      expect(l.totalSpent, 12.5);
    });

    test('add of an excluded expense creates the row but adds nothing', () {
      final l = emptyLedger()..add(tx('1', exclude: true));
      expect(spent(l, 'food', 'Groceries'), 0);
    });

    test('update moves the amount between categories', () {
      final l = emptyLedger()..add(tx('1', amount: 30));
      l.update(tx('1', amount: 20, categoryKey: 'transport', category: 'Bus'));
      expect(spent(l, 'food', 'Groceries'), 0);
      expect(spent(l, 'transport', 'Bus'), 20);
      expect(l.transactions.single.amount, 20);
    });

    test('delete reverses spent and the savings goal balance', () {
      final goal = SavingsGoal(
        id: 'g',
        name: 'Laptop',
        targetAmount: 1200,
        currentAmount: 100,
      );
      final l = BudgetLedger(
        transactions: [],
        categoryBudgets: {},
        savingsGoals: [goal],
      );
      final saving = tx(
        's',
        amount: 100,
        categoryKey: 'savings',
        category: 'Laptop',
      );
      l.add(saving);
      l.delete(saving);
      expect(goal.currentAmount, 0);
      expect(l.transactions, isEmpty);
      expect(spent(l, 'savings', 'Laptop'), 0);
    });

    test('syncSavingsWithGoals budgets the monthly instalment', () {
      final l = BudgetLedger(
        transactions: [],
        categoryBudgets: {},
        savingsGoals: [
          SavingsGoal(
            id: 'g',
            name: 'Trip',
            targetAmount: 600,
            durationMonths: 6,
          ),
        ],
      )..syncSavingsWithGoals();
      expect(l.categoryBudgets['savings']!['Trip']!.budgeted, 100);
    });

    test('incomeForMonth ignores other months and expenses', () {
      final l = emptyLedger()
        ..add(
          tx(
            'a',
            amount: 900,
            type: TransactionType.income,
            date: DateTime(2025, 3, 1),
          ),
        )
        ..add(
          tx(
            'b',
            amount: 500,
            type: TransactionType.income,
            date: DateTime(2025, 2, 28),
          ),
        )
        ..add(tx('c', amount: 50, date: DateTime(2025, 3, 5)));
      expect(l.incomeForMonth(DateTime(2025, 3, 20)), 900);
    });

    test(
      'generateRecurring creates monthly occurrences up to the end date',
      () {
        final rent = tx(
          'r',
          amount: 500,
          categoryKey: 'housing',
          category: 'Rent',
          date: DateTime(2025, 1, 1),
          recurrence: RecurrenceType.monthly,
          recurrenceEnd: DateTime(2025, 4, 1),
        );
        final l = emptyLedger()..add(rent);
        final added = l.generateRecurring(
          base: rent,
          now: DateTime(2025, 2, 15),
        );
        expect(added, 3); // Feb, Mar, Apr
        // Jan template + Feb occurrence count; Mar/Apr are in the future.
        expect(spent(l, 'housing', 'Rent'), 1000);
        expect(l.transactions.where((t) => t.excludeFromBudget).length, 2);
      },
    );

    test('generateRecurring does not duplicate existing occurrences', () {
      final weekly = tx(
        'w',
        date: DateTime(2025, 1, 1),
        recurrence: RecurrenceType.weekly,
        recurrenceEnd: DateTime(2025, 1, 29),
      );
      final l = emptyLedger()..add(weekly);
      expect(l.generateRecurring(now: DateTime(2025, 6, 1)), 4);
      expect(l.generateRecurring(now: DateTime(2025, 6, 1)), 0);
    });

    test('updating a recurring template drops its old occurrences', () {
      final rent = tx(
        'r',
        amount: 500,
        date: DateTime(2025, 1, 1),
        recurrence: RecurrenceType.monthly,
        recurrenceEnd: DateTime(2025, 3, 1),
      );
      final l = emptyLedger()..add(rent);
      l.generateRecurring(base: rent, now: DateTime(2025, 12, 31));
      expect(l.transactions.length, 3);

      l.update(tx('r', amount: 400, date: DateTime(2025, 1, 1)));
      expect(l.transactions.map((t) => t.id), ['r']);
      expect(spent(l, 'food', 'Groceries'), 400);
    });

    test('nextOccurrence rolls over year ends and adds whole weeks', () {
      expect(
        BudgetLedger.nextOccurrence(
          DateTime(2025, 12, 15),
          RecurrenceType.monthly,
        ),
        DateTime(2026, 1, 15),
      );
      expect(
        BudgetLedger.nextOccurrence(
          DateTime(2025, 1, 1),
          RecurrenceType.biweekly,
        ),
        DateTime(2025, 1, 15),
      );
    });
  });
}
