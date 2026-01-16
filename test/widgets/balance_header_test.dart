import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_dummy/widgets/balance_header.dart';
import 'package:test_dummy/models/balance.dart';

void main() {
  group('BalanceHeader', () {
    testWidgets('shows nothing when no balance set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 0.0,
              balanceInfo: null,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Current Balance'), findsNothing);
    });

    testWidgets('shows positive balance with correct styling', (tester) async {
      final balance = Balance(
        accountId: 1,
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 1500.50,
              balanceInfo: balance,
            ),
          ),
        ),
      );

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.textContaining('+1500.50'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('shows negative balance with correct styling', (tester) async {
      final balance = Balance(
        accountId: 1,
        amount: 1000.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: -500.0,
              balanceInfo: balance,
            ),
          ),
        ),
      );

      expect(find.textContaining('-500.00'), findsOneWidget);
    });

    testWidgets('shows zero balance correctly', (tester) async {
      final balance = Balance(
        accountId: 1,
        amount: 0.0,
        date: DateTime(2025, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceHeader(
              currentBalance: 0.0,
              balanceInfo: balance,
            ),
          ),
        ),
      );

      expect(find.textContaining('+0.00'), findsOneWidget);
    });
  });
}
