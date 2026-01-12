import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/services/csv_parser.dart';

void main() {
  group('CsvParser.getExpensesByCategory', () {
    test('aggregates expenses by category', () {
      final transactions = [
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
      ];

      final result = CsvParser.getExpensesByCategory(transactions);

      expect(result['Food'], 80.0);
      expect(result['Transport'], 60.0);
      expect(result.length, 2);
    });

    test('ignores income transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getExpensesByCategory(transactions);

      expect(result['Food'], 50.0);
      expect(result.containsKey('Salary'), false);
      expect(result.length, 1);
    });

    test('sorts categories by expense amount descending', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Transport',
          label: 'Gas',
          debit: 100.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 10),
          category: 'Entertainment',
          label: 'Movie',
          debit: 25.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getExpensesByCategory(transactions);
      final keys = result.keys.toList();

      expect(keys[0], 'Transport'); // 100.0
      expect(keys[1], 'Food'); // 50.0
      expect(keys[2], 'Entertainment'); // 25.0
    });

    test('returns empty map for empty list', () {
      final result = CsvParser.getExpensesByCategory([]);
      expect(result, isEmpty);
    });

    test('returns empty map when all transactions are income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getExpensesByCategory(transactions);
      expect(result, isEmpty);
    });

    test('handles single expense', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getExpensesByCategory(transactions);
      expect(result['Food'], 50.0);
      expect(result.length, 1);
    });
  });

  group('CsvParser.getBalanceByCategory', () {
    test('calculates net balance with expenses only', () {
      final transactions = [
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
      ];

      final result = CsvParser.getBalanceByCategory(transactions);
      expect(result['Food'], 80.0); // positive = net expense
    });

    test('calculates net balance with income only', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getBalanceByCategory(transactions);
      expect(result['Salary'], -2000.0); // negative = net income
    });

    test('calculates net balance with mixed expenses and income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Business',
          label: 'Office supplies',
          debit: 150.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Business',
          label: 'Consulting fee',
          debit: 0.0,
          credit: 500.0,
        ),
      ];

      final result = CsvParser.getBalanceByCategory(transactions);
      expect(result['Business'], -350.0); // 150 - 500 = -350 (net income)
    });

    test('sorts categories by absolute value descending', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 10),
          category: 'Transport',
          label: 'Gas',
          debit: 100.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getBalanceByCategory(transactions);
      final keys = result.keys.toList();

      expect(keys[0], 'Salary'); // abs(-2000.0)
      expect(keys[1], 'Transport'); // abs(100.0)
      expect(keys[2], 'Food'); // abs(50.0)
    });

    test('returns empty map for empty list', () {
      final result = CsvParser.getBalanceByCategory([]);
      expect(result, isEmpty);
    });

    test('handles category with equal expenses and income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Business',
          label: 'Cost',
          debit: 100.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Business',
          label: 'Revenue',
          debit: 0.0,
          credit: 100.0,
        ),
      ];

      final result = CsvParser.getBalanceByCategory(transactions);
      expect(result['Business'], 0.0); // balanced
    });
  });

  group('CsvParser.getMonthlyTotals', () {
    test('aggregates expenses and income by month', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 25),
          category: 'Transport',
          label: 'Gas',
          debit: 60.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getMonthlyTotals(transactions);

      expect(result[1]!['expenses'], 110.0); // 50 + 60
      expect(result[1]!['income'], 2000.0);
      expect(result.length, 1);
    });

    test('separates months correctly', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 2, 20),
          category: 'Food',
          label: 'Restaurant',
          debit: 30.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 2, 1),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getMonthlyTotals(transactions);

      expect(result[1]!['expenses'], 50.0);
      expect(result[1]!['income'], 0.0);
      expect(result[2]!['expenses'], 30.0);
      expect(result[2]!['income'], 2000.0);
      expect(result.length, 2);
    });

    test('handles month with only expenses', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getMonthlyTotals(transactions);

      expect(result[1]!['expenses'], 50.0);
      expect(result[1]!['income'], 0.0);
    });

    test('handles month with only income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getMonthlyTotals(transactions);

      expect(result[1]!['expenses'], 0.0);
      expect(result[1]!['income'], 2000.0);
    });

    test('returns empty map for empty list', () {
      final result = CsvParser.getMonthlyTotals([]);
      expect(result, isEmpty);
    });

    test('handles all 12 months', () {
      final transactions = List.generate(
        12,
        (index) => Transaction(
          date: DateTime(2025, index + 1, 15),
          category: 'Test',
          label: 'Test',
          debit: 100.0,
          credit: 0.0,
        ),
      );

      final result = CsvParser.getMonthlyTotals(transactions);

      expect(result.length, 12);
      for (int i = 1; i <= 12; i++) {
        expect(result[i]!['expenses'], 100.0);
        expect(result[i]!['income'], 0.0);
      }
    });
  });

  group('CsvParser.getTotalExpenses', () {
    test('sums all expense transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Transport',
          label: 'Gas',
          debit: 60.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 25),
          category: 'Entertainment',
          label: 'Movie',
          debit: 25.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getTotalExpenses(transactions);
      expect(result, 135.0);
    });

    test('ignores income transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getTotalExpenses(transactions);
      expect(result, 50.0);
    });

    test('returns zero for empty list', () {
      final result = CsvParser.getTotalExpenses([]);
      expect(result, 0.0);
    });

    test('returns zero when all transactions are income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getTotalExpenses(transactions);
      expect(result, 0.0);
    });

    test('handles single expense', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 123.45,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getTotalExpenses(transactions);
      expect(result, 123.45);
    });
  });

  group('CsvParser.getTotalIncome', () {
    test('sums all income transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Bonus',
          label: 'Year-end bonus',
          debit: 0.0,
          credit: 500.0,
        ),
      ];

      final result = CsvParser.getTotalIncome(transactions);
      expect(result, 2500.0);
    });

    test('ignores expense transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      final result = CsvParser.getTotalIncome(transactions);
      expect(result, 2000.0);
    });

    test('returns zero for empty list', () {
      final result = CsvParser.getTotalIncome([]);
      expect(result, 0.0);
    });

    test('returns zero when all transactions are expenses', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      final result = CsvParser.getTotalIncome(transactions);
      expect(result, 0.0);
    });

    test('handles single income', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2345.67,
        ),
      ];

      final result = CsvParser.getTotalIncome(transactions);
      expect(result, 2345.67);
    });
  });

  group('CsvParser aggregation integration', () {
    test('aggregation functions work together consistently', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 20),
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

      final totalExpenses = CsvParser.getTotalExpenses(transactions);
      final totalIncome = CsvParser.getTotalIncome(transactions);
      final expensesByCategory = CsvParser.getExpensesByCategory(transactions);
      final balanceByCategory = CsvParser.getBalanceByCategory(transactions);
      final monthlyTotals = CsvParser.getMonthlyTotals(transactions);

      // Verify totals
      expect(totalExpenses, 110.0);
      expect(totalIncome, 2000.0);

      // Verify expenses by category sum matches total expenses
      final categoryExpensesSum = expensesByCategory.values.fold(0.0, (sum, val) => sum + val);
      expect(categoryExpensesSum, totalExpenses);

      // Verify monthly totals match overall totals for single month
      expect(monthlyTotals[1]!['expenses'], totalExpenses);
      expect(monthlyTotals[1]!['income'], totalIncome);

      // Verify balance calculation
      expect(balanceByCategory['Food'], 50.0);
      expect(balanceByCategory['Transport'], 60.0);
      expect(balanceByCategory['Salary'], -2000.0);
    });
  });
}
