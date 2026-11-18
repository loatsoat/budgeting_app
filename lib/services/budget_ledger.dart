import '../models/budget_models.dart';
import '../utils/constants.dart';

/// In-memory bookkeeping for the budget screen: keeps each subcategory's
/// `spent` total and each savings goal's balance consistent as transactions
/// are added, edited and deleted.
///
/// No widgets, BuildContext or storage involved, so it can be unit-tested;
/// the screen calls these inside setState and persists afterwards.
class BudgetLedger {
  List<Transaction> transactions;
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets;
  List<SavingsGoal> savingsGoals;

  BudgetLedger({
    required this.transactions,
    required this.categoryBudgets,
    List<SavingsGoal>? savingsGoals,
  }) : savingsGoals = savingsGoals ?? [];

  /// Starter budgets for a brand-new user before anything is saved.
  BudgetLedger.withDefaultBudgets()
    : this(
        transactions: [],
        categoryBudgets: {
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
        },
      );

  static const savingsKey = 'savings';

  // ---- totals ----

  double get totalSpent => _sum((b) => b.spent);
  double get totalBudgeted => _sum((b) => b.budgeted);

  double _sum(double Function(SubcategoryBudget) pick) => categoryBudgets.values
      .expand((subs) => subs.values)
      .fold(0.0, (sum, b) => sum + pick(b));

  /// Income in the calendar month containing [now]; counting all-time income
  /// would inflate the budget when it is set to follow income.
  double incomeForMonth(DateTime now) {
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              !t.date.isBefore(monthStart) &&
              t.date.isBefore(nextMonthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ---- derived state ----

  /// Rebuilds every subcategory's `spent` from the transaction list.
  void recalculateSpent() {
    for (final subs in categoryBudgets.values) {
      for (final budget in subs.values) {
        budget.spent = 0;
      }
    }
    for (final t in transactions) {
      if (_counts(t)) _addSpent(t.categoryKey, t.category, t.amount);
    }
  }

  /// The savings category mirrors the goals: one subcategory per goal,
  /// budgeted at its monthly instalment (not the full target).
  void syncSavingsWithGoals() {
    categoryBudgets[savingsKey] = {
      for (final goal in savingsGoals)
        goal.name: SubcategoryBudget(
          budgeted: goal.monthlyAmount,
          spent: goal.currentAmount,
        ),
    };
  }

  // ---- goals ----

  void addGoal(SavingsGoal goal) {
    savingsGoals.add(goal);
    syncSavingsWithGoals();
  }

  void updateGoal(SavingsGoal goal) {
    final index = savingsGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) savingsGoals[index] = goal;
    syncSavingsWithGoals();
  }

  void removeGoal(SavingsGoal goal) {
    savingsGoals.removeWhere((g) => g.id == goal.id);
    syncSavingsWithGoals();
  }

  // ---- transactions ----

  void add(Transaction t) {
    transactions.add(t);
    if (t.type == TransactionType.expense) {
      // Excluded expenses still get a subcategory row, just with nothing added.
      _addSpent(t.categoryKey, t.category, t.excludeFromBudget ? 0 : t.amount);
    }
  }

  /// A swiped-in bank transaction only counts toward categories that already exist.
  void acceptBankTransaction(Transaction t) {
    transactions.add(t);
    if (categoryBudgets.containsKey(t.categoryKey)) {
      _addSpent(t.categoryKey, t.category, t.amount);
    }
  }

  void update(Transaction updated) {
    final index = transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    final old = transactions[index];
    _reverse(old);

    // A recurring template owns its generated occurrences ("<id>_<date>");
    // drop them so they are regenerated from the edited template.
    if (old.recurrence != RecurrenceType.never) {
      bool isOccurrence(Transaction t) => t.id.startsWith('${old.id}_');
      transactions.where(isOccurrence).toList().forEach(_reverse);
      transactions.removeWhere(isOccurrence);
    }

    // Look the template up again: removing occurrences may have shifted it.
    transactions[transactions.indexWhere((t) => t.id == updated.id)] = updated;
    if (_counts(updated)) {
      _addSpent(updated.categoryKey, updated.category, updated.amount);
      if (updated.categoryKey == savingsKey) {
        _adjustGoal(updated.category, updated.amount);
      }
    }
    syncSavingsWithGoals();
  }

  void delete(Transaction t) {
    if (_counts(t)) _removeSpent(t.categoryKey, t.category, t.amount);
    if (t.categoryKey == savingsKey) {
      _adjustGoal(t.category, -t.amount);
      syncSavingsWithGoals();
    }
    transactions.removeWhere((x) => x.id == t.id);
  }

  /// Materialises occurrences of recurring transactions (all templates, or
  /// just [base]) up to their end date, or 12 months after the start.
  /// Occurrences after [now] are excluded from the budget so future rent
  /// doesn't count against this month. Returns how many were added.
  int generateRecurring({Transaction? base, DateTime? now}) {
    now ??= DateTime.now();
    final existing = transactions.map(_dedupeKey).toSet();
    final templates = base != null
        ? [base]
        : transactions
              .where((t) => t.recurrence != RecurrenceType.never)
              .toList();

    var added = 0;
    for (final tmpl in templates) {
      if (tmpl.recurrence == RecurrenceType.never) continue;
      final end =
          tmpl.recurrenceEndDate ??
          DateTime(tmpl.date.year, tmpl.date.month + 12, tmpl.date.day);

      for (
        var next = nextOccurrence(tmpl.date, tmpl.recurrence);
        !next.isAfter(end);
        next = nextOccurrence(next, tmpl.recurrence)
      ) {
        final occurrence = Transaction(
          id: '${tmpl.id}_${next.toIso8601String()}',
          type: tmpl.type,
          amount: tmpl.amount,
          category: tmpl.category,
          categoryKey: tmpl.categoryKey,
          note: tmpl.note,
          date: next,
          merchant: tmpl.merchant,
          description: tmpl.description,
          excludeFromBudget: next.isAfter(now),
          // Occurrences are plain transactions so they never spawn their own.
          recurrence: RecurrenceType.never,
          recurrenceEndDate: null,
        );
        if (existing.add(_dedupeKey(occurrence))) {
          transactions.add(occurrence);
          if (_counts(occurrence)) {
            _addSpent(
              occurrence.categoryKey,
              occurrence.category,
              occurrence.amount,
            );
          }
          added++;
        }
      }
    }
    return added;
  }

  static DateTime nextOccurrence(DateTime from, RecurrenceType type) {
    switch (type) {
      case RecurrenceType.weekly:
        return from.add(const Duration(days: 7));
      case RecurrenceType.biweekly:
        return from.add(const Duration(days: 14));
      case RecurrenceType.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case RecurrenceType.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case RecurrenceType.yearly:
        return DateTime(from.year + 1, from.month, from.day);
      case RecurrenceType.never:
        return from;
    }
  }

  // ---- helpers ----

  bool _counts(Transaction t) =>
      t.type == TransactionType.expense && !t.excludeFromBudget;

  /// Undo a transaction's effect on category totals and savings goals.
  void _reverse(Transaction t) {
    if (!_counts(t)) return;
    _removeSpent(t.categoryKey, t.category, t.amount);
    if (t.categoryKey == savingsKey) _adjustGoal(t.category, -t.amount);
  }

  void _addSpent(String categoryKey, String subcategory, double amount) {
    categoryBudgets
            .putIfAbsent(categoryKey, () => {})
            .putIfAbsent(
              subcategory,
              () => SubcategoryBudget(budgeted: 0, spent: 0),
            )
            .spent +=
        amount;
  }

  void _removeSpent(String categoryKey, String subcategory, double amount) {
    final budget = categoryBudgets[categoryKey]?[subcategory];
    if (budget != null) budget.spent -= amount;
  }

  // Goals are matched by name because savings transactions store the goal
  // name as their subcategory.
  void _adjustGoal(String goalName, double delta) {
    for (final goal in savingsGoals) {
      if (goal.name == goalName) {
        goal.currentAmount += delta;
        return;
      }
    }
  }

  // Same day, amount, category, note and merchant = same occurrence.
  static String _dedupeKey(Transaction t) =>
      '${t.categoryKey}|${t.category}|${t.amount.toStringAsFixed(2)}|${t.note}|'
      '${t.merchant}|${DateTime(t.date.year, t.date.month, t.date.day).toIso8601String()}';
}
