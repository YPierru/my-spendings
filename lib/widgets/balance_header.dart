import 'package:flutter/material.dart';
import '../models/balance.dart';

class BalanceHeader extends StatelessWidget {
  final double currentBalance;
  final Balance? balanceInfo;

  const BalanceHeader({
    super.key,
    required this.currentBalance,
    required this.balanceInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (balanceInfo == null) {
      return const SizedBox.shrink();
    }

    final isPositive = currentBalance >= 0;
    final balanceColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final backgroundColor =
        isPositive ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: balanceColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            '${currentBalance >= 0 ? '+' : ''}${currentBalance.toStringAsFixed(2)} \u20AC',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: balanceColor,
            ),
          ),
        ],
      ),
    );
  }
}
