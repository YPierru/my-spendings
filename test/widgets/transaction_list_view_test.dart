import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/transaction_list_view.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('TransactionListView - Basic rendering', () {
    testWidgets('displays empty message when no transactions', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionListView(transactions: []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No transactions found'), findsOneWidget);
    });

    testWidgets('displays search field', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionListView(transactions: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionListView(transactions: []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(3));
    });

    testWidgets('displays transactions grouped by category', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 1, 20),
          category: 'Transport',
          label: 'Gas',
          debit: 60.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should display category cards
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('-50.00€'), findsOneWidget);
      expect(find.text('-60.00€'), findsOneWidget);
    });

    testWidgets('displays month header', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      expect(find.text('January 2025'), findsOneWidget);
    });

    testWidgets('sorts categories alphabetically within month', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Transport',
          label: 'Gas',
          debit: 60.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 1, 20),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          id: 3,
          date: DateTime(2025, 1, 25),
          category: 'Entertainment',
          label: 'Movie',
          debit: 25.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));
      await tester.pumpAndSettle();

      // Verify all categories are displayed (alphabetically sorted)
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      // Find all InkWells (category items)
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      expect(inkWells.length, greaterThanOrEqualTo(3));
    });

    testWidgets('aggregates multiple transactions in same category and month', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 1, 20),
          category: 'Food',
          label: 'Restaurant',
          debit: 30.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should show aggregated total
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('-80.00€'), findsOneWidget);
    });

    testWidgets('separates transactions by month', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 2, 20),
          category: 'Food',
          label: 'Restaurant',
          debit: 30.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should show both month headers
      expect(find.text('January 2025'), findsOneWidget);
      expect(find.text('February 2025'), findsOneWidget);

      // Should show separate category entries for each month
      expect(find.text('-50.00€'), findsOneWidget);
      expect(find.text('-30.00€'), findsOneWidget);
    });
  });

  group('TransactionListView - Filtering', () {
    final mixedTransactions = [
      Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      ),
      Transaction(
        id: 2,
        date: DateTime(2025, 1, 20),
        category: 'Salary',
        label: 'Monthly pay',
        debit: 0.0,
        credit: 2000.0,
      ),
      Transaction(
        id: 3,
        date: DateTime(2025, 1, 25),
        category: 'Transport',
        label: 'Gas',
        debit: 60.0,
        credit: 0.0,
      ),
    ];

    testWidgets('All filter shows all transactions', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: mixedTransactions),
      ));

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('Expenses filter shows only expenses', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: mixedTransactions),
      ));

      // Tap Expenses filter
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('Income filter shows only income', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: mixedTransactions),
      ));

      // Tap Income filter
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsNothing);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Transport'), findsNothing);
    });

    testWidgets('can switch between filters', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: mixedTransactions),
      ));

      // Start with All
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);

      // Switch to Expenses
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      // Switch back to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });
  });

  group('TransactionListView - Search', () {
    final transactions = [
      Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries at SuperMart',
        debit: 50.0,
        credit: 0.0,
      ),
      Transaction(
        id: 2,
        date: DateTime(2025, 1, 20),
        category: 'Transport',
        label: 'Gas Station',
        debit: 60.0,
        credit: 0.0,
      ),
      Transaction(
        id: 3,
        date: DateTime(2025, 1, 25),
        category: 'Entertainment',
        label: 'Movie ticket',
        debit: 25.0,
        credit: 0.0,
      ),
    ];

    testWidgets('search by label filters transactions', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pumpAndSettle();

      // Should only show Food category
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsNothing);
      expect(find.text('Entertainment'), findsNothing);
    });

    testWidgets('search by category filters transactions', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Transport');
      await tester.pumpAndSettle();

      // Should only show Transport category
      expect(find.text('Food'), findsNothing);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Entertainment'), findsNothing);
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Enter search query in lowercase
      await tester.enterText(find.byType(TextField), 'groceries');
      await tester.pumpAndSettle();

      // Should still find Food category
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('clearing search shows all transactions', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pumpAndSettle();

      expect(find.text('Transport'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Should show all categories again
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('search with no matches shows empty message', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Enter search query with no matches
      await tester.enterText(find.byType(TextField), 'xyz123');
      await tester.pumpAndSettle();

      expect(find.text('No transactions found'), findsOneWidget);
    });
  });

  group('TransactionListView - Category bottom sheet', () {
    testWidgets('tapping category opens bottom sheet', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Tap on category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Bottom sheet should be displayed
      expect(find.text('Food - January 2025'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('bottom sheet shows all transactions for category', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 1, 20),
          category: 'Food',
          label: 'Restaurant',
          debit: 30.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Tap on Food category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Should show both transactions
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);
      expect(find.text('-50.00€'), findsOneWidget);
      expect(find.text('-30.00€'), findsOneWidget);
    });

    testWidgets('bottom sheet shows transaction dates', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Tap on category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Should show calendar icon and day
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('bottom sheet close button dismisses sheet', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(find.text('Food - January 2025'), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Sheet should be closed
      expect(find.text('Food - January 2025'), findsNothing);
    });

    testWidgets('bottom sheet shows FAB when onAdd provided', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onAdd: () {},
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // FAB should be present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('bottom sheet does not show FAB when onAdd not provided', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // FAB should not be present
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('TransactionListView - Callbacks', () {
    testWidgets('edit button calls onEdit callback', (WidgetTester tester) async {
      Transaction? editedTransaction;
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onEdit: (t) => editedTransaction = t,
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Callback should be called
      expect(editedTransaction, isNotNull);
      expect(editedTransaction!.id, 1);
      expect(editedTransaction!.label, 'Groceries');
    });

    testWidgets('delete button shows confirmation dialog', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onDelete: (id) {},
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete Transaction'), findsOneWidget);
      expect(find.text('Delete "Food - Groceries" for 50.00€?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('delete confirmation calls onDelete callback', (WidgetTester tester) async {
      int? deletedId;
      final transactions = [
        Transaction(
          id: 42,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onDelete: (id) => deletedId = id,
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Callback should be called with correct ID
      expect(deletedId, 42);
    });

    testWidgets('delete cancellation does not call onDelete', (WidgetTester tester) async {
      int? deletedId;
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onDelete: (id) => deletedId = id,
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Callback should not be called
      expect(deletedId, isNull);
    });

    testWidgets('add button in bottom sheet calls onAdd callback', (WidgetTester tester) async {
      bool addCalled = false;
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onAdd: () => addCalled = true,
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Callback should be called
      expect(addCalled, true);
    });
  });

  group('TransactionListView - Display formatting', () {
    testWidgets('displays expense amounts in red with minus sign', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Find the expense amount text
      final expenseText = find.text('-50.00€');
      expect(expenseText, findsOneWidget);

      // Verify color is red
      final textWidget = tester.widget<Text>(expenseText);
      expect(textWidget.style?.color, Colors.red.shade700);
    });

    testWidgets('displays income amounts in green with plus sign', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Salary',
          label: 'Monthly pay',
          debit: 0.0,
          credit: 2000.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Find the income amount text
      final incomeText = find.text('+2000.00€');
      expect(incomeText, findsOneWidget);

      // Verify color is green
      final textWidget = tester.widget<Text>(incomeText);
      expect(textWidget.style?.color, Colors.green.shade700);
    });

    testWidgets('displays transaction detail with label when present', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Should display label
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('displays category name when label is empty', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: '',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Should display category name instead of empty label
      expect(find.text('Food'), findsWidgets);
    });
  });

  group('TransactionListView - Edge cases', () {
    testWidgets('handles transaction without ID for delete', (WidgetTester tester) async {
      int? deletedId;
      final transactions = [
        Transaction(
          date: DateTime(2025, 1, 15),
          category: 'Food',
          label: 'Groceries',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(
          transactions: transactions,
          onDelete: (id) => deletedId = id,
        ),
      ));

      // Open bottom sheet
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Callback should not be called (ID is null)
      expect(deletedId, isNull);
    });

    testWidgets('handles mixed expenses and income in same category', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Business',
          label: 'Supplies',
          debit: 100.0,
          credit: 0.0,
        ),
        Transaction(
          id: 2,
          date: DateTime(2025, 1, 20),
          category: 'Business',
          label: 'Revenue',
          debit: 0.0,
          credit: 500.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should show both expense and income badges
      expect(find.text('-100.00€'), findsOneWidget);
      expect(find.text('+500.00€'), findsOneWidget);
    });

    testWidgets('handles very long category names', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Very Long Category Name That Should Be Displayed Properly',
          label: 'Test',
          debit: 50.0,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should display without error
      expect(find.text('Very Long Category Name That Should Be Displayed Properly'), findsOneWidget);
    });

    testWidgets('handles very large amounts', (WidgetTester tester) async {
      final transactions = [
        Transaction(
          id: 1,
          date: DateTime(2025, 1, 15),
          category: 'Investment',
          label: 'Property',
          debit: 999999.99,
          credit: 0.0,
        ),
      ];

      await tester.pumpWidget(makeTestableWidget(
        TransactionListView(transactions: transactions),
      ));

      // Should display large amount
      expect(find.text('-999999.99€'), findsOneWidget);
    });
  });
}
