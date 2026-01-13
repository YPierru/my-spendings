import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/services/csv_parser.dart';

void main() {
  final sampleTransactions = [
    Transaction(
      date: DateTime(2025, 1, 15),
      category: 'Food',
      label: 'Groceries',
      debit: 50.0,
      credit: 0.0,
    ),
    Transaction(
      date: DateTime(2025, 1, 20),
      category: 'Food',
      label: 'Restaurant',
      debit: 30.0,
      credit: 0.0,
    ),
    Transaction(
      date: DateTime(2025, 1, 10),
      category: 'Transport',
      label: 'Gas',
      debit: 60.0,
      credit: 0.0,
    ),
    Transaction(
      date: DateTime(2025, 1, 25),
      category: 'Salary',
      label: 'Monthly pay',
      debit: 0.0,
      credit: 2000.0,
    ),
  ];

  group('CsvParser.getExpensesByCategory', () {
    test('aggregates expenses by category', () {
      final result = CsvParser.getExpensesByCategory(sampleTransactions);

      expect(result['Food'], 80.0);
      expect(result['Transport'], 60.0);
      expect(result.containsKey('Salary'), false);
    });

    test('returns empty map for empty list', () {
      expect(CsvParser.getExpensesByCategory([]), isEmpty);
    });
  });

  group('CsvParser.getBalanceByCategory', () {
    test('calculates net balance per category', () {
      final result = CsvParser.getBalanceByCategory(sampleTransactions);

      expect(result['Food'], 80.0);
      expect(result['Transport'], 60.0);
      expect(result['Salary'], -2000.0);
    });

    test('returns empty map for empty list', () {
      expect(CsvParser.getBalanceByCategory([]), isEmpty);
    });
  });

  group('CsvParser.getMonthlyTotals', () {
    test('aggregates expenses and income by month', () {
      final result = CsvParser.getMonthlyTotals(sampleTransactions);

      expect(result[1]!['expenses'], 140.0);
      expect(result[1]!['income'], 2000.0);
    });

    test('returns empty map for empty list', () {
      expect(CsvParser.getMonthlyTotals([]), isEmpty);
    });
  });

  group('CsvParser totals', () {
    test('getTotalExpenses sums all expenses', () {
      expect(CsvParser.getTotalExpenses(sampleTransactions), 140.0);
      expect(CsvParser.getTotalExpenses([]), 0.0);
    });

    test('getTotalIncome sums all income', () {
      expect(CsvParser.getTotalIncome(sampleTransactions), 2000.0);
      expect(CsvParser.getTotalIncome([]), 0.0);
    });
  });
}
