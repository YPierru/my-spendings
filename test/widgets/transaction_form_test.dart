import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/transaction_form.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('TransactionForm', () {
    testWidgets('renders all form fields in add mode', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsWidgets);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
    });

    testWidgets('pre-fills data in edit mode', (tester) async {
      final transaction = Transaction(
        id: 1,
        accountId: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(transaction: transaction, categories: const ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsOneWidget);
      expect(find.text('15/1/2025'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Find and tap the submit button (FilledButton.icon)
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is FilledButton,
      );
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a label'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('can toggle between expense and income', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('can create new category', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create New Category'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'New Category'), findsOneWidget);
      expect(find.text('Select Existing Category'), findsOneWidget);
    });
  });
}
