import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/widgets/balance_dialog.dart';
import 'package:test_dummy/models/balance.dart';

void main() {
  group('BalanceDialog', () {
    testWidgets('renders with empty state (add mode)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      expect(find.text('Set Balance'), findsOneWidget);
      expect(find.text('Balance Amount'), findsOneWidget);
      expect(find.text('Effective Date'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders with existing balance (edit mode)', (tester) async {
      final existingBalance = Balance(
        accountId: 1,
        amount: 1500.0,
        date: DateTime(2025, 3, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceDialog(existingBalance: existingBalance, accountId: 1),
          ),
        ),
      );

      expect(find.text('Edit Balance'), findsOneWidget);
      expect(find.text('1500.00'), findsOneWidget);
      expect(find.text('15/03/2025'), findsOneWidget);
    });

    testWidgets('validates empty amount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('validates invalid amount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'abc');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('accepts valid amount with comma decimal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, '1234,56');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsNothing);
      expect(find.text('Please enter an amount'), findsNothing);
    });

    testWidgets('accepts negative amounts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, '-500');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsNothing);
    });

    testWidgets('cancel button closes dialog without returning value', (tester) async {
      Balance? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Balance>(
                  context: context,
                  builder: (_) => const BalanceDialog(accountId: 1),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('shows explanatory text about date', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      expect(
        find.text('Transactions on or after this date will affect the balance.'),
        findsOneWidget,
      );
    });

    testWidgets('shows calendar icon for date picker', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceDialog(accountId: 1),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
  });
}
