import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/multi_transaction_form.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('MultiTransactionForm', () {
    testWidgets('renders with empty entry form', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Transactions'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
      // Add button visible
      expect(find.text('Add'), findsOneWidget);
      // Save All not visible when no staged transactions
      expect(find.textContaining('Save All'), findsNothing);
    });

    testWidgets('entry form has date picker, toggle, category, label, amount', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1));
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
    });

    testWidgets('validation errors on Add with empty fields', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Tap Add without filling fields
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a label'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('Add stages transaction and clears form', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Bread');
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '4,50');
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Staged table should show the transaction
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('-4.50 €'), findsOneWidget);
      // Save All button should appear
      expect(find.textContaining('Save All (1)'), findsOneWidget);

      // Form should be cleared
      final labelField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Label'),
      );
      expect(labelField.controller?.text, isEmpty);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('delete removes staged transaction', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Stage a transaction
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Bread');
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '4,50');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Delete it
      final deleteButton = find.byIcon(Icons.close);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Staged table should be gone and Save All hidden
      expect(find.textContaining('Save All'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('tap staged row loads into form for editing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Stage a transaction
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Bread');
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '4,50');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Tap the staged row
      await tester.tap(find.byKey(const ValueKey('staged_row_0')));
      await tester.pumpAndSettle();

      // Button should say "Update" instead of "Add"
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Add'), findsNothing);

      // Amount should be populated
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
      final amountField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Amount'),
      );
      expect(amountField.controller?.text, equals('4,5'));

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Save All returns List<Transaction> with staged data', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      List<Transaction>? result;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<List<Transaction>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MultiTransactionForm(
                      categories: ['Food', 'Transport'],
                      accountId: 1,
                    ),
                  ),
                );
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Stage first transaction
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Bread');
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '4,50');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Stage second transaction
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Bus');
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '2');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Save All
      final saveButton = find.textContaining('Save All');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.length, equals(2));
      expect(result![0].label, equals('Bread'));
      expect(result![0].amount, equals(4.50));
      expect(result![0].accountId, equals(1));
      expect(result![0].isExpense, isTrue);
      expect(result![1].label, equals('Bus'));
      expect(result![1].amount, equals(2.0));

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Cancel/back returns null', (tester) async {
      List<Transaction>? result;
      bool navigatorPopped = false;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<List<Transaction>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MultiTransactionForm(
                      categories: ['Food', 'Transport'],
                      accountId: 1,
                    ),
                  ),
                );
                navigatorPopped = true;
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(navigatorPopped, isTrue);
      expect(result, isNull);
    });

    testWidgets('can toggle between expense and income', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1));

      // Tap income toggle
      final addIcons = find.byIcon(Icons.add);
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1));
    });

    group('Shared defaults', () {
      testWidgets('shared date toggle hides form date picker', (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));

        await tester.pumpWidget(makeTestableWidget(
          const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
        ));
        await tester.pumpAndSettle();

        // Initially one date picker in entry form
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);

        // Enable shared date
        final shareDateSwitch = find.ancestor(
          of: find.text('Use same date for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareDateSwitch);
        await tester.pumpAndSettle();

        // Now one date picker in shared defaults card only
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('shared_defaults_card')),
            matching: find.byIcon(Icons.calendar_today),
          ),
          findsOneWidget,
        );

        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
