import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/models/account.dart';
import 'package:test_dummy/widgets/account_list_screen.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  final sampleAccounts = [
    AccountWithBalance(
      account: Account(id: 1, name: 'Main Account'),
      balance: 1500.50,
    ),
    AccountWithBalance(
      account: Account(id: 2, name: 'Savings'),
      balance: 5000.0,
    ),
    AccountWithBalance(
      account: Account(id: 3, name: 'Credit Card'),
      balance: -250.75,
    ),
  ];

  group('AccountListScreen', () {
    testWidgets('displays list of accounts', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Main Account'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
    });

    testWidgets('displays account balances', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Check that balance amounts are shown (may include currency formatting)
      expect(find.textContaining('1500'), findsOneWidget);
      expect(find.textContaining('5000'), findsOneWidget);
      expect(find.textContaining('250'), findsOneWidget);
    });

    testWidgets('positive balance shows green color', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: [
            AccountWithBalance(
              account: Account(id: 1, name: 'Positive'),
              balance: 100.0,
            ),
          ],
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find text widget with balance and verify it has green color
      final balanceText = tester.widget<Text>(
        find.textContaining('100'),
      );
      expect(balanceText.style?.color, Colors.green);
    });

    testWidgets('negative balance shows red color', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: [
            AccountWithBalance(
              account: Account(id: 1, name: 'Negative'),
              balance: -100.0,
            ),
          ],
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find text widget with negative indicator
      final balanceText = tester.widget<Text>(
        find.textContaining('100'),
      );
      expect(balanceText.style?.color, Colors.red);
    });

    testWidgets('displays empty state when no accounts', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: [],
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('No accounts'), findsOneWidget);
    });

    testWidgets('tapping account calls onSelectAccount', (tester) async {
      Account? selectedAccount;

      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {
            selectedAccount = account;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Savings'));
      await tester.pumpAndSettle();

      expect(selectedAccount, isNotNull);
      expect(selectedAccount!.name, 'Savings');
    });

    testWidgets('has add account button', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('app bar shows correct title', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Accounts'), findsOneWidget);
    });
  });
}
