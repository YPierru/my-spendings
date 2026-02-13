import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/transaction.dart';
import 'package:test_dummy/widgets/multi_transaction_form.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('MultiTransactionForm', () {
    testWidgets('renders with one empty entry by default', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Transactions'), findsOneWidget);
      // Should have one entry card with label and amount fields
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
    });

    testWidgets('"Add Another" button adds new entry row', (tester) async {
      // Use a larger test surface to ensure button is visible
      await tester.binding.setSurfaceSize(const Size(800, 800));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Initially one entry
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);

      // Find and tap the Add Another button by key
      final addButton = find.byKey(const Key('add_another_button'));
      expect(addButton, findsOneWidget);

      // Tap the button
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Now should have two entries
      expect(find.widgetWithText(TextFormField, 'Label'), findsNWidgets(2));

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('remove button removes entry but cannot remove last one', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Add a second entry
      final addButton = find.byKey(const Key('add_another_button'));
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Label'), findsNWidgets(2));

      // Find remove buttons (X icons)
      final removeButtons = find.byIcon(Icons.close);
      expect(removeButtons, findsNWidgets(2));

      // Remove the first entry
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      // Should now have only one entry
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);

      // The last entry should not have a remove button
      expect(find.byIcon(Icons.close), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('each entry has date picker, expense/income toggle, category, label, amount',
        (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Date picker
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // Expense/Income toggle (compact - and + icons)
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1));

      // Category dropdown
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      // Label and Amount text fields
      expect(find.widgetWithText(TextFormField, 'Label'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
    });

    testWidgets('validates all entries on save - shows error for empty label', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Try to save without filling required fields
      final saveButton = find.textContaining('Save All');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a label'), findsOneWidget);
    });

    testWidgets('validates all entries on save - shows error for invalid amount', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Fill label but not amount
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Test');
      await tester.pumpAndSettle();

      final saveButton = find.textContaining('Save All');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('shows validation errors per entry when multiple entries exist', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Add second entry
      final addButton = find.byKey(const Key('add_another_button'));
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill only first entry
      final labelFields = find.widgetWithText(TextFormField, 'Label');
      await tester.enterText(labelFields.first, 'Entry 1');
      await tester.pumpAndSettle();

      final amountFields = find.widgetWithText(TextFormField, 'Amount');
      await tester.enterText(amountFields.first, '10');
      await tester.pumpAndSettle();

      // Try to save
      final saveButton = find.textContaining('Save All');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation errors for second entry
      expect(find.text('Please enter a label'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('"Save All" returns List<Transaction> with correct data', (tester) async {
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

      // Open the form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.widgetWithText(TextFormField, 'Label'), 'Test Transaction');
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25,50');
      await tester.pumpAndSettle();

      // Save
      final saveButton = find.textContaining('Save All');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.length, equals(1));
      expect(result![0].label, equals('Test Transaction'));
      expect(result![0].amount, equals(25.50));
      expect(result![0].accountId, equals(1));
      expect(result![0].isExpense, isTrue);
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

      // Open the form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(navigatorPopped, isTrue);
      expect(result, isNull);
    });

    group('Shared defaults', () {
      testWidgets('"Use same date" toggle applies date to all entries', (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));

        await tester.pumpWidget(makeTestableWidget(
          const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
        ));
        await tester.pumpAndSettle();

        // Add second entry
        final addButton = find.byKey(const Key('add_another_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Initially should have two date pickers (calendar icons)
        expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));

        // Find and tap the "Use same date for all" switch
        final shareDateSwitch = find.ancestor(
          of: find.text('Use same date for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareDateSwitch);
        await tester.pumpAndSettle();

        // Now should have only one date picker in shared defaults section
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('"Use same category" toggle applies category to all entries', (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));

        await tester.pumpWidget(makeTestableWidget(
          const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
        ));
        await tester.pumpAndSettle();

        // Add second entry
        final addButton = find.byKey(const Key('add_another_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Initially should have two category dropdowns
        expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

        // Find and tap the "Use same category for all" switch
        final shareCategorySwitch = find.ancestor(
          of: find.text('Use same category for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareCategorySwitch);
        await tester.pumpAndSettle();

        // Now should have only one category dropdown in shared defaults section
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('when shared date is enabled, individual date pickers are hidden',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));

        await tester.pumpWidget(makeTestableWidget(
          const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
        ));
        await tester.pumpAndSettle();

        // Add second entry
        final addButton = find.byKey(const Key('add_another_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Enable shared date
        final shareDateSwitch = find.ancestor(
          of: find.text('Use same date for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareDateSwitch);
        await tester.pumpAndSettle();

        // Individual entries should not have date picker, only shared section has one
        final calendarIcons = find.byIcon(Icons.calendar_today);
        expect(calendarIcons, findsOneWidget);

        // The single date picker should be in shared defaults card
        expect(
          find.descendant(
            of: find.byKey(const Key('shared_defaults_card')),
            matching: find.byIcon(Icons.calendar_today),
          ),
          findsOneWidget,
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('when shared category is enabled, individual category selectors are hidden',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));

        await tester.pumpWidget(makeTestableWidget(
          const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
        ));
        await tester.pumpAndSettle();

        // Add second entry
        final addButton = find.byKey(const Key('add_another_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Enable shared category
        final shareCategorySwitch = find.ancestor(
          of: find.text('Use same category for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareCategorySwitch);
        await tester.pumpAndSettle();

        // Individual entries should not have category dropdown, only shared section has one
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

        // The single dropdown should be in shared defaults card
        expect(
          find.descendant(
            of: find.byKey(const Key('shared_defaults_card')),
            matching: find.byType(DropdownButtonFormField<String>),
          ),
          findsOneWidget,
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('shared date is applied to all transactions on save', (tester) async {
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

        // Add second entry
        final addButton = find.byKey(const Key('add_another_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Enable shared date
        final shareDateSwitch = find.ancestor(
          of: find.text('Use same date for all'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(shareDateSwitch);
        await tester.pumpAndSettle();

        // Fill in both entries
        final labelFields = find.widgetWithText(TextFormField, 'Label');
        await tester.enterText(labelFields.at(0), 'Entry 1');
        await tester.enterText(labelFields.at(1), 'Entry 2');
        await tester.pumpAndSettle();

        final amountFields = find.widgetWithText(TextFormField, 'Amount');
        await tester.enterText(amountFields.at(0), '10');
        await tester.enterText(amountFields.at(1), '20');
        await tester.pumpAndSettle();

        // Save
        final saveButton = find.textContaining('Save All');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.length, equals(2));
        // Both should have the same date (shared date, which defaults to today)
        expect(result![0].date.day, equals(result![1].date.day));
        expect(result![0].date.month, equals(result![1].date.month));
        expect(result![0].date.year, equals(result![1].date.year));

        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('can toggle between expense and income for each entry', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Initially both toggle icons should be visible (- for expense, + for income)
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1)); // + icon in toggle (and possibly in bottom bar)

      // Tap the + icon (income toggle) — it's inside the entry card
      final addIcons = find.byIcon(Icons.add);
      // The first Icons.add is the income toggle, tap it
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      // Both toggle icons should still be visible
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeast(1));
    });

    testWidgets('Save All button shows transaction count', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));

      await tester.pumpWidget(makeTestableWidget(
        const MultiTransactionForm(categories: ['Food', 'Transport'], accountId: 1),
      ));
      await tester.pumpAndSettle();

      // Initially shows "Save All (1)"
      expect(find.textContaining('Save All (1)'), findsOneWidget);

      // Add another entry
      final addButton = find.byKey(const Key('add_another_button'));
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Now shows "Save All (2)"
      expect(find.textContaining('Save All (2)'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
