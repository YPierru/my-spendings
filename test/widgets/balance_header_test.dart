import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/widgets/balance_header.dart';
import 'package:test_dummy/models/balance.dart';

void main() {
  group('BalanceHeader', () {
    testWidgets('shows prompt when no balance set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 0.0,
              balanceInfo: null,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tap to set initial balance'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('shows positive balance with correct styling', (tester) async {
      final balance = Balance(
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 1500.50,
              balanceInfo: balance,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.textContaining('+1500.50'), findsOneWidget);
      expect(find.text('Since'), findsOneWidget);
      expect(find.text('15/01/2025'), findsOneWidget);
    });

    testWidgets('shows negative balance with correct styling', (tester) async {
      final balance = Balance(
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: -500.0,
              balanceInfo: balance,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('-500.00'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped (no balance)', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 0.0,
              balanceInfo: null,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BalanceHeader));
      expect(tapped, isTrue);
    });

    testWidgets('calls onTap when tapped (with balance)', (tester) async {
      bool tapped = false;
      final balance = Balance(
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 1500.0,
              balanceInfo: balance,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BalanceHeader));
      expect(tapped, isTrue);
    });

    testWidgets('shows edit icon when balance is set', (tester) async {
      final balance = Balance(
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 1000.0,
              balanceInfo: balance,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows zero balance correctly', (tester) async {
      final balance = Balance(
        amount: 0.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 0.0,
              balanceInfo: balance,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('+0.00'), findsOneWidget);
    });
  });
}
