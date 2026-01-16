import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountWithBalance {
  final Account account;
  final double balance;

  AccountWithBalance({required this.account, required this.balance});
}

class AccountListScreen extends StatelessWidget {
  final List<AccountWithBalance> accounts;
  final Future<void> Function() onAddAccount;
  final Future<void> Function(int id) onDeleteAccount;
  final void Function(Account account) onSelectAccount;

  const AccountListScreen({
    super.key,
    required this.accounts,
    required this.onAddAccount,
    required this.onDeleteAccount,
    required this.onSelectAccount,
  });

  String _formatBalance(double balance) {
    final sign = balance >= 0 ? '+' : '';
    return '$sign${balance.toStringAsFixed(2)} \u20AC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No accounts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to create your first account',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final item = accounts[index];
                final isPositive = item.balance >= 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isPositive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      item.account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _formatBalance(item.balance),
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showDeleteConfirmation(context, item.account),
                    ),
                    onTap: () => onSelectAccount(item.account),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddAccount,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? This will permanently delete all transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onDeleteAccount(account.id!);
    }
  }
}
