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
  });
}
