import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/widgets/account_form_dialog.dart';
import 'package:test_dummy/models/account.dart';

void main() {
  group('AccountFormDialog', () {
    testWidgets('renders with empty state (add mode)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccountFormDialog(),
          ),
        ),
      );

      expect(find.text('Add Account'), findsOneWidget);
      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders with existing account (edit mode)', (tester) async {
      final existingAccount = Account(
        id: 1,
        name: 'My Savings',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountFormDialog(existingAccount: existingAccount),
          ),
        ),
      );

      expect(find.text('Edit Account'), findsOneWidget);
      expect(find.text('My Savings'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccountFormDialog(),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter an account name'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog without returning value', (tester) async {
      Account? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Account>(
                  context: context,
                  builder: (_) => const AccountFormDialog(),
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

    testWidgets('save button returns account on valid input', (tester) async {
      Account? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Account>(
                  context: context,
                  builder: (_) => const AccountFormDialog(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'New Account');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'New Account');
    });

    testWidgets('edit mode preserves id on save', (tester) async {
      Account? result;
      final existingAccount = Account(
        id: 42,
        name: 'Original Name',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Account>(
                  context: context,
                  builder: (_) => AccountFormDialog(existingAccount: existingAccount),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear and enter new name
      await tester.enterText(find.byType(TextFormField).first, 'Updated Name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.id, 42);
      expect(result!.name, 'Updated Name');
    });
  });
}
