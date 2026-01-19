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
  final Future<void> Function(Account account) onEditAccount;
  final Future<void> Function(int id) onDeleteAccount;
  final void Function(Account account) onSelectAccount;
  final bool isDemoMode;
  final Future<void> Function() onToggleDemoMode;

  const AccountListScreen({
    super.key,
    required this.accounts,
    required this.onAddAccount,
    required this.onEditAccount,
    required this.onDeleteAccount,
    required this.onSelectAccount,
    required this.isDemoMode,
    required this.onToggleDemoMode,
  });

  String _formatBalance(double balance) {
    final sign = balance >= 0 ? '+' : '';
    return '$sign${balance.toStringAsFixed(2)} \u20AC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('My Accounts'),
            if (isDemoMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_demo') {
                onToggleDemoMode();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_demo',
                child: Text(isDemoMode ? 'Exit Demo Mode' : 'Demo Mode'),
              ),
            ],
          ),
        ],
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => onEditAccount(item.account),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _showDeleteConfirmation(context, item.account),
                        ),
                      ],
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
