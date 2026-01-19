import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/transaction_list_view.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  final sampleTransactions = [
    Transaction(
      id: 1,
      accountId: 1,
      date: DateTime(2025, 1, 15),
      category: 'Food',
      label: 'Groceries',
      debit: 50.0,
      credit: 0.0,
    ),
    Transaction(
      id: 2,
      accountId: 1,
      date: DateTime(2025, 1, 20),
      category: 'Salary',
      label: 'Monthly pay',
      debit: 0.0,
      credit: 2000.0,
    ),
    Transaction(
      id: 3,
      accountId: 1,
      date: DateTime(2025, 1, 25),
      category: 'Transport',
      label: 'Gas',
      debit: 60.0,
      credit: 0.0,
    ),
  ];

  group('TransactionListView', () {
    testWidgets('displays transactions grouped by category', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: sampleTransactions),
      ));
      await tester.pumpAndSettle();

      expect(find.text('January 2025'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('displays filter chips', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: sampleTransactions),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('filters by expense/income', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: sampleTransactions),
      ));
      await tester.pumpAndSettle();

      // Filter to expenses only
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      // Filter to income only
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsNothing);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('search filters transactions', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: sampleTransactions),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
      expect(find.text('Transport'), findsNothing);
    });

    testWidgets('tapping category opens bottom sheet', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: sampleTransactions),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(find.text('Food - January 2025'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('edit callback works', (tester) async {
      Transaction? editedTransaction;

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: sampleTransactions,
          onEdit: (t) => editedTransaction = t,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(editedTransaction?.label, 'Groceries');
    });

    testWidgets('delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: sampleTransactions,
          onDelete: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Transaction'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    group('Last transaction date display', () {
      testWidgets('displays last transaction date when transactions exist', (tester) async {
        await tester.pumpWidget(makeTestableWidget(
          TransactionListView(transactions: sampleTransactions),
        ));
        await tester.pumpAndSettle();

        // Should display the most recent transaction date (25/01/2025)
        expect(find.text('Last transaction date: 25/01/2025'), findsOneWidget);
      });

      testWidgets('does not display last transaction date when list is empty', (tester) async {
        await tester.pumpWidget(makeTestableWidget(
          TransactionListView(transactions: <Transaction>[]),
        ));
        await tester.pumpAndSettle();

        // Should not show the last transaction date text when no transactions
        expect(find.textContaining('Last transaction date:'), findsNothing);
      });

      testWidgets('displays correct date with multiple months', (tester) async {
        final multiMonthTransactions = [
          Transaction(
            id: 1,
            accountId: 1,
            date: DateTime(2024, 12, 5),
            category: 'Food',
            label: 'Old groceries',
            debit: 30.0,
            credit: 0.0,
          ),
          Transaction(
            id: 2,
            accountId: 1,
            date: DateTime(2025, 2, 10),
            category: 'Transport',
            label: 'Recent gas',
            debit: 40.0,
            credit: 0.0,
          ),
        ];

        await tester.pumpWidget(makeTestableWidget(
          TransactionListView(transactions: multiMonthTransactions),
        ));
        await tester.pumpAndSettle();

        // Should display the most recent date (February 10, 2025)
        expect(find.text('Last transaction date: 10/02/2025'), findsOneWidget);
      });
    });
  });
}
