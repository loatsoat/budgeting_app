import 'package:flutter_test/flutter_test.dart';
import 'package:hci_app/services/expense_categorizer.dart';

void main() {
  group('ExpenseCategorizer', () {
    final categorizer = ExpenseCategorizer();

    test('Categorize food transaction with high confidence', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Starbucks Coffee',
        merchantName: 'Starbucks',
      );
      expect(prediction.category, equals('Food & Dining'));
      expect(prediction.confidence, greaterThanOrEqualTo(0.5));
    });

    test('Categorize transportation transaction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Uber Rideshare',
        merchantName: 'Uber',
      );
      expect(prediction.category, equals('Transportation'));
      expect(prediction.confidence, greaterThanOrEqualTo(0.5));
    });

    test('Categorize shopping transaction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Clothes Purchase',
        merchantName: 'Target',
      );
      expect(prediction.category, equals('Shopping'));
    });

    test('Categorize healthcare transaction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Medicine Prescription',
        merchantName: 'CVS',
      );
      expect(prediction.category, equals('Healthcare'));
    });

    test('Categorize entertainment transaction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Monthly Subscription',
        merchantName: 'Netflix',
      );
      expect(prediction.category, equals('Entertainment'));
    });

    test('Categorize fitness transaction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Gym Membership',
        merchantName: 'Planet Fitness',
      );
      expect(prediction.category, equals('Fitness'));
    });

    test('Handle unknown transaction with fallback category', () {
      final prediction = categorizer.categorizeExpense(
        description: 'XYZ Random Text ABCD',
        merchantName: null,
      );
      expect(prediction.category, equals('Other'));
    });

    test('Confidence score is between 0 and 1', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Starbucks',
        merchantName: null,
      );
      expect(prediction.confidence, greaterThanOrEqualTo(0.0));
      expect(prediction.confidence, lessThanOrEqualTo(1.0));
    });

    test('High confidence prediction', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Amazon Purchase Shopping',
        merchantName: 'Amazon',
      );
      expect(prediction.category, equals('Shopping'));
      expect(prediction.confidence, greaterThanOrEqualTo(0.5));
    });

    test('Provide alternative categories', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Restaurant and Shopping',
        merchantName: null,
      );
      expect(prediction.alternativeCategories.isNotEmpty, true);
    });

    test('Get all available categories', () {
      final categories = categorizer.getAvailableCategories();
      expect(categories.length, greaterThan(0));
      expect(categories.contains('Food & Dining'), true);
      expect(categories.contains('Transportation'), true);
      expect(categories.contains('Shopping'), true);
    });

    test('Category count is at least 10', () {
      final categories = categorizer.getAvailableCategories();
      expect(categories.length, greaterThanOrEqualTo(10));
    });

    test('Multiple similar descriptions categorized same', () {
      final pred1 = categorizer.categorizeExpense(
        description: 'Starbucks Cafe',
        merchantName: null,
      );
      final pred2 = categorizer.categorizeExpense(
        description: 'Starbucks Coffee',
        merchantName: null,
      );
      expect(pred1.category, equals(pred2.category));
    });

    test('Case insensitivity in categorization', () {
      final pred1 = categorizer.categorizeExpense(
        description: 'STARBUCKS',
        merchantName: null,
      );
      final pred2 = categorizer.categorizeExpense(
        description: 'starbucks',
        merchantName: null,
      );
      expect(pred1.category, equals(pred2.category));
    });

    test('Merchant name influences categorization', () {
      final prediction = categorizer.categorizeExpense(
        description: 'Transaction',
        merchantName: 'Starbucks',
      );
      expect(prediction.category, equals('Food & Dining'));
    });
  });
}
