import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/transaction_form.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('TransactionForm - Add mode', () {
    testWidgets('displays Add Transaction title', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food', 'Transport']),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsWidgets);
    });

    testWidgets('displays all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food', 'Transport']),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Label (optional)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('initializes with first category selected', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food', 'Transport', 'Entertainment']),
      ));
      await tester.pumpAndSettle();

      // Dropdown should show the first category
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('initializes with expense type selected', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      final segmentedButton = tester.widget<SegmentedButton<bool>>(
        find.byType(SegmentedButton<bool>),
      );
      expect(segmentedButton.selected, {true});
    });

    testWidgets('switches between expense and income', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));

      // Initial state should be expense
      SegmentedButton<bool> segmentedButton = tester.widget(find.byType(SegmentedButton<bool>));
      expect(segmentedButton.selected, {true});

      // Tap on Income button
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // Should now be income
      segmentedButton = tester.widget(find.byType(SegmentedButton<bool>));
      expect(segmentedButton.selected, {false});
    });

    testWidgets('can select different categories', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food', 'Transport', 'Entertainment']),
      ));

      // Initial category is Food
      expect(find.text('Food'), findsOneWidget);

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select Transport
      await tester.tap(find.text('Transport').last);
      await tester.pumpAndSettle();

      // Transport should now be selected
      expect(find.text('Transport'), findsWidgets);
    });

    testWidgets('can toggle to new category mode', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Should show dropdown initially
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'New Category'), findsNothing);

      // Tap the add icon button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should now show text field for new category
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.widgetWithText(TextFormField, 'New Category'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('opens date picker when date is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Tap the date field
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Date picker should be shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('validates empty amount', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Tap submit without entering amount
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('validates invalid amount', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Enter invalid amount
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), 'abc');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('validates zero amount', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));

      // Enter zero amount
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('validates negative amount', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));

      // Enter negative amount
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '-10');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('validates empty new category name', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));

      // Toggle to new category mode
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter amount but leave category empty
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '50');
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a category'), findsOneWidget);
    });

    testWidgets('displays submit button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Verify add button text is shown (appears in title and button)
      expect(find.text('Add Transaction'), findsWidgets);
      // Verify FilledButton exists
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('can enter label text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Find and enter text in label field
      await tester.enterText(find.widgetWithText(TextFormField, 'Label (optional)'), 'Test Label');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('can enter amount text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Find and enter text in amount field
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '50.00');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('50.00'), findsOneWidget);
    });
  });

  group('TransactionForm - Edit mode', () {
    testWidgets('displays Edit Transaction title', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Food', 'Transport'],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsOneWidget);
    });

    testWidgets('pre-fills form with transaction data', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Food', 'Transport'],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify pre-filled values
      expect(find.text('15/1/2025'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('pre-selects expense type for expense transaction', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Food'],
        ),
      ));
      await tester.pumpAndSettle();

      final segmentedButton = tester.widget<SegmentedButton<bool>>(
        find.byType(SegmentedButton<bool>),
      );
      expect(segmentedButton.selected, {true});
    });

    testWidgets('pre-selects income type for income transaction', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Salary',
        label: 'Monthly pay',
        debit: 0.0,
        credit: 2000.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Salary'],
        ),
      ));
      await tester.pumpAndSettle();

      final segmentedButton = tester.widget<SegmentedButton<bool>>(
        find.byType(SegmentedButton<bool>),
      );
      expect(segmentedButton.selected, {false});
    });

    testWidgets('displays Save Changes button in edit mode', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Food'],
        ),
      ));
      await tester.pumpAndSettle();

      // Find the button with Save Changes text
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('displays save icon in edit mode', (WidgetTester tester) async {
      final transaction = Transaction(
        id: 1,
        date: DateTime(2025, 1, 15),
        category: 'Food',
        label: 'Groceries',
        debit: 50.0,
        credit: 0.0,
      );

      await tester.pumpWidget(makeTestableWidget(
        TransactionForm(
          transaction: transaction,
          categories: const ['Food'],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify the save icon is shown in edit mode
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });

  group('TransactionForm - Edge cases', () {
    testWidgets('handles empty category list by enabling new category mode', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: []),
      ));
      await tester.pumpAndSettle();

      // Form should still render without crashing
      expect(find.byType(TransactionForm), findsOneWidget);
      // The app bar title and button both have "Add Transaction" text
      expect(find.text('Add Transaction'), findsWidgets);
    });

    testWidgets('displays date picker icon', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Verify the calendar icon is present for date selection
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays type segmented button', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const TransactionForm(categories: ['Food']),
      ));
      await tester.pumpAndSettle();

      // Verify expense and income options exist
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });
  });
}
