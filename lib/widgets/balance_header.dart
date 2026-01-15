import 'package:flutter/material.dart';
import '../models/balance.dart';

class BalanceHeader extends StatelessWidget {
  final double currentBalance;
  final Balance? balanceInfo;
  final VoidCallback onTap;

  const BalanceHeader({
    super.key,
    required this.currentBalance,
    required this.balanceInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (balanceInfo == null) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tap to set initial balance',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPositive = currentBalance >= 0;
    final balanceColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final backgroundColor =
        isPositive ? Colors.green.shade50 : Colors.red.shade50;

    return InkWell(
      onTap: onTap,
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
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
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Since',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  '${balanceInfo!.date.day.toString().padLeft(2, '0')}/${balanceInfo!.date.month.toString().padLeft(2, '0')}/${balanceInfo!.date.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
