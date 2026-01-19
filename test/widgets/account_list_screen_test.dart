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
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
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
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
        ),
      ));
      await tester.pumpAndSettle();

      // Check that balance amounts are shown (may include currency formatting)
      expect(find.textContaining('1500'), findsOneWidget);
      expect(find.textContaining('5000'), findsOneWidget);
      expect(find.textContaining('250'), findsOneWidget);
    });

    testWidgets('displays empty state when no accounts', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: [],
          onAddAccount: () async {},
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
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
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {
            selectedAccount = account;
          },
          isDemoMode: false,
          onToggleDemoMode: () async {},
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
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('has edit button on each account', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onEditAccount: (account) async {},
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should have edit button for each account (3 edit icons)
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(3));
    });

    testWidgets('tapping edit button calls onEditAccount', (tester) async {
      Account? editedAccount;

      await tester.pumpWidget(makeTestableWidget(
        AccountListScreen(
          accounts: sampleAccounts,
          onAddAccount: () async {},
          onEditAccount: (account) async {
            editedAccount = account;
          },
          onDeleteAccount: (id) async {},
          onSelectAccount: (account) {},
          isDemoMode: false,
          onToggleDemoMode: () async {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find and tap the edit button for the first account
      final editButtons = find.byIcon(Icons.edit_outlined);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(editedAccount, isNotNull);
      expect(editedAccount!.name, 'Main Account');
    });
  });
}
