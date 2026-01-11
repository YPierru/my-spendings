import 'package:flutter/material.dart';
import '../models/transaction.dart';

enum SortOption { dateDesc, dateAsc, amountDesc, amountAsc }

class TransactionListSheet extends StatefulWidget {
  final String title;
  final List<Transaction> transactions;
  final ScrollController scrollController;

  const TransactionListSheet({
    super.key,
    required this.title,
    required this.transactions,
    required this.scrollController,
  });

  @override
  State<TransactionListSheet> createState() => _TransactionListSheetState();
}

class _TransactionListSheetState extends State<TransactionListSheet> {
  SortOption _sortOption = SortOption.dateDesc;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  List<Transaction> get _sortedTransactions {
    final list = List<Transaction>.from(widget.transactions);
    switch (_sortOption) {
      case SortOption.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
      case SortOption.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
      case SortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case SortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.transactions.fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.transactions.length} transactions - ${total.toStringAsFixed(0)}€',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSortButton(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.transactions.isEmpty
                ? const Center(child: Text('No transactions'))
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _sortedTransactions.length,
                    itemBuilder: (context, index) {
                      final t = _sortedTransactions[index];
                      return ListTile(
                        title: Text(
                          t.label.isNotEmpty ? t.label : 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_formatDate(t.date)),
                        trailing: Text(
                          '${t.isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)}€',
                          style: TextStyle(
                            color: t.isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: (option) => setState(() => _sortOption = option),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SortOption.dateDesc,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: _sortOption == SortOption.dateDesc
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('Date (newest first)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortOption.dateAsc,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: _sortOption == SortOption.dateAsc
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('Date (oldest first)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortOption.amountDesc,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: _sortOption == SortOption.amountDesc
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('Amount (high to low)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortOption.amountAsc,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: _sortOption == SortOption.amountAsc
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('Amount (low to high)'),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}
