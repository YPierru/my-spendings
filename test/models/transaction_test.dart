import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';

void main() {
  group('Transaction.parseDate', () {
    test('parses all French month abbreviations', () {
      final testCases = {
        '15-janv': 1,
        '28-fevr': 2,
        '28-févr': 2,
        '31-mars': 3,
        '30-avr': 4,
        '15-mai': 5,
        '30-juin': 6,
        '14-juil': 7,
        '15-aout': 8,
        '15-août': 8,
        '30-sept': 9,
        '31-oct': 10,
        '30-nov': 11,
        '25-dec': 12,
        '25-déc': 12,
      };

      for (final entry in testCases.entries) {
        final date = Transaction.parseDate(entry.key, year: 2025);
        expect(date, isNotNull, reason: 'Failed for: ${entry.key}');
        expect(date!.month, entry.value, reason: 'Month mismatch for: ${entry.key}');
      }
    });

    test('handles case insensitivity', () {
      expect(Transaction.parseDate('15-JANV', year: 2025)?.month, 1);
      expect(Transaction.parseDate('15-JaNv', year: 2025)?.month, 1);
    });

    test('returns null for invalid formats', () {
      expect(Transaction.parseDate('invalid', year: 2025), isNull);
      expect(Transaction.parseDate('-janv', year: 2025), isNull);
      expect(Transaction.parseDate('abc-janv', year: 2025), isNull);
      expect(Transaction.parseDate('15-xyz', year: 2025), isNull);
      expect(Transaction.parseDate('', year: 2025), isNull);
    });
  });

  group('Transaction.parseAmount', () {
    test('parses various amount formats', () {
      expect(Transaction.parseAmount('123,45'), 123.45);
      expect(Transaction.parseAmount('123.45'), 123.45);
      expect(Transaction.parseAmount('100'), 100.0);
      expect(Transaction.parseAmount('1 234,56'), 1234.56);
      expect(Transaction.parseAmount('0,00'), 0.0);
      expect(Transaction.parseAmount(''), 0.0);
      expect(Transaction.parseAmount('abc'), 0.0);
    });
  });

  group('Transaction serialization', () {
    test('toMap and fromMap roundtrip', () {
      final original = Transaction(
        id: 42,
        date: DateTime(2025, 3, 21),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      final map = original.toMap();
      final restored = Transaction.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.date, original.date);
      expect(restored.category, original.category);
      expect(restored.label, original.label);
      expect(restored.debit, original.debit);
      expect(restored.credit, original.credit);
    });

    test('fromMap handles null values', () {
      final map = {
        'date': '2025-01-15T00:00:00.000',
        'category': 'Food',
        'label': null,
        'debit': null,
        'credit': null,
      };

      final transaction = Transaction.fromMap(map);
      expect(transaction.label, '');
      expect(transaction.debit, 0.0);
      expect(transaction.credit, 0.0);
    });
  });

  group('Transaction properties', () {
    test('isExpense and isIncome', () {
      final expense = Transaction(
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      final income = Transaction(
        date: DateTime(2025, 1, 15),
        category: 'Salary',
        label: 'Monthly salary',
        debit: 0.0,
        credit: 2000.0,
      );

      expect(expense.isExpense, true);
      expect(expense.isIncome, false);
      expect(expense.amount, 50.0);

      expect(income.isExpense, false);
      expect(income.isIncome, true);
      expect(income.amount, 2000.0);
    });

    test('copyWith creates modified copy', () {
      final original = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      final copy = original.copyWith(category: 'Restaurant', debit: 75.0);

      expect(copy.id, original.id);
      expect(copy.category, 'Restaurant');
      expect(copy.debit, 75.0);
      expect(copy.label, original.label);
    });
  });
}
