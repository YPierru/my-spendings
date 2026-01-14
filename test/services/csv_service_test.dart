import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/services/csv_service.dart';

void main() {
  group('CsvService.generateCsv', () {
    test('generates correct header', () {
      final csv = CsvService.generateCsv([]);
      expect(csv.trim(), 'Date;Category;Label;Amount');
    });

    test('formats expense as negative amount', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 3, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      final csv = CsvService.generateCsv(transactions);
      final lines = csv.trim().split('\n');

      expect(lines.length, 2);
      expect(lines[1], '15/03/2025;Food;Groceries;-50.00');
    });

    test('formats income as positive amount', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 25),
          category: 'Salary',
          label: 'Monthly salary',
          debit: 0.0,
          credit: 4500.0,
        ),
      ];

      final csv = CsvService.generateCsv(transactions);
      final lines = csv.trim().split('\n');

      expect(lines.length, 2);
      expect(lines[1], '25/01/2025;Salary;Monthly salary;4500.00');
    });

    test('pads single digit day and month with zero', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 5),
          category: 'Test',
          label: 'Test',
          debit: 10.0,
          credit: 0.0,
        ),
      ];

      final csv = CsvService.generateCsv(transactions);
      expect(csv, contains('05/01/2025'));
    });

    test('replaces semicolons in label and category with commas', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 6, 15),
          category: 'Cat;egory',
          label: 'Lab;el',
          debit: 25.0,
          credit: 0.0,
        ),
      ];

      final csv = CsvService.generateCsv(transactions);
      final lines = csv.trim().split('\n');

      expect(lines[1], '15/06/2025;Cat,egory;Lab,el;-25.00');
    });

    test('handles multiple transactions', () {
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 10),
          category: 'Food',
          label: 'Lunch',
          debit: 15.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Paycheck',
          debit: 0.0,
          credit: 3000.0,
        ),
      ];

      final csv = CsvService.generateCsv(transactions);
      final lines = csv.trim().split('\n');

      expect(lines.length, 3);
      expect(lines[0], 'Date;Category;Label;Amount');
      expect(lines[1], '10/01/2025;Food;Lunch;-15.00');
      expect(lines[2], '15/01/2025;Salary;Paycheck;3000.00');
    });
  });

  group('CsvService.parseCsv', () {
    test('parses valid CSV with header', () {
      const csv = '''Date;Category;Label;Amount
15/03/2025;Food;Groceries;-50.00
25/01/2025;Salary;Monthly;4500.00''';

      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, 2);
      expect(result.skipped, 0);

      expect(result.transactions[0].category, 'Food');
      expect(result.transactions[0].label, 'Groceries');
      expect(result.transactions[0].debit, 50.0);
      expect(result.transactions[0].credit, 0.0);
      expect(result.transactions[0].date, DateTime(2025, 3, 15));

      expect(result.transactions[1].category, 'Salary');
      expect(result.transactions[1].credit, 4500.0);
    });

    test('skips invalid lines and counts them', () {
      const csv = '''Date;Category;Label;Amount
15/03/2025;Food;Groceries;-50.00
invalid line
25/01/2025;Salary;Monthly;4500.00
another;bad''';

      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, 2);
      expect(result.skipped, 2);
    });

    test('handles empty lines', () {
      const csv = '''Date;Category;Label;Amount

15/03/2025;Food;Groceries;-50.00

25/01/2025;Salary;Monthly;4500.00
''';

      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, 2);
      expect(result.skipped, 0);
    });

    test('parses CSV without header', () {
      const csv = '''15/03/2025;Food;Groceries;-50.00
25/01/2025;Salary;Monthly;4500.00''';

      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, 2);
      expect(result.skipped, 0);
    });

    test('handles comma decimal separator', () {
      const csv = '''Date;Category;Label;Amount
15/03/2025;Food;Groceries;-50,99''';

      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, 1);
      expect(result.transactions[0].debit, 50.99);
    });
  });

  group('CsvService.parseLine', () {
    test('parses valid expense line', () {
      final transaction = CsvService.parseLine('15/03/2025;Food;Groceries;-50.00');

      expect(transaction, isNotNull);
      expect(transaction!.date, DateTime(2025, 3, 15));
      expect(transaction.category, 'Food');
      expect(transaction.label, 'Groceries');
      expect(transaction.debit, 50.0);
      expect(transaction.credit, 0.0);
      expect(transaction.isExpense, true);
    });

    test('parses valid income line', () {
      final transaction = CsvService.parseLine('25/01/2025;Salary;Monthly;4500.00');

      expect(transaction, isNotNull);
      expect(transaction!.date, DateTime(2025, 1, 25));
      expect(transaction.category, 'Salary');
      expect(transaction.label, 'Monthly');
      expect(transaction.debit, 0.0);
      expect(transaction.credit, 4500.0);
      expect(transaction.isIncome, true);
    });

    test('returns null for line with too few parts', () {
      expect(CsvService.parseLine('15/03/2025;Food;Groceries'), isNull);
      expect(CsvService.parseLine('15/03/2025;Food'), isNull);
      expect(CsvService.parseLine('invalid'), isNull);
    });

    test('returns null for invalid date format', () {
      expect(CsvService.parseLine('2025-03-15;Food;Groceries;-50.00'), isNull);
      expect(CsvService.parseLine('15-03-2025;Food;Groceries;-50.00'), isNull);
      expect(CsvService.parseLine('invalid;Food;Groceries;-50.00'), isNull);
    });

    test('returns null for invalid amount', () {
      expect(CsvService.parseLine('15/03/2025;Food;Groceries;abc'), isNull);
    });

    test('trims whitespace from fields', () {
      final transaction = CsvService.parseLine('15/03/2025; Food ; Groceries ; -50.00 ');

      expect(transaction, isNotNull);
      expect(transaction!.category, 'Food');
      expect(transaction.label, 'Groceries');
      expect(transaction.debit, 50.0);
    });
  });

  group('CsvService roundtrip', () {
    test('export then import produces equivalent transactions', () {
      final original = [
        Transaction(
          date: DateTime(2025, 3, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          date: DateTime(2025, 1, 25),
          category: 'Salary',
          label: 'Monthly salary',
          debit: 0.0,
          credit: 4500.0,
        ),
      ];

      final csv = CsvService.generateCsv(original);
      final result = CsvService.parseCsv(csv);

      expect(result.transactions.length, original.length);
      expect(result.skipped, 0);

      for (int i = 0; i < original.length; i++) {
        expect(result.transactions[i].date, original[i].date);
        expect(result.transactions[i].category, original[i].category);
        expect(result.transactions[i].label, original[i].label);
        expect(result.transactions[i].debit, original[i].debit);
        expect(result.transactions[i].credit, original[i].credit);
      }
    });
  });
}
