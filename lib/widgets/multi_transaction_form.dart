import 'package:flutter/material.dart';
import '../models/transaction.dart';

class MultiTransactionForm extends StatefulWidget {
  final List<String> categories;
  final int accountId;
  final String? initialCategory;

  const MultiTransactionForm({
    super.key,
    required this.categories,
    required this.accountId,
    this.initialCategory,
  });

  @override
  State<MultiTransactionForm> createState() => _MultiTransactionFormState();
}

class _TransactionEntry {
  DateTime date;
  bool isExpense;
  String category;
  final TextEditingController labelController;
  final TextEditingController amountController;

  _TransactionEntry({
    required this.date,
    required this.isExpense,
    required this.category,
  })  : labelController = TextEditingController(),
        amountController = TextEditingController();

  void dispose() {
    labelController.dispose();
    amountController.dispose();
  }
}

class _MultiTransactionFormState extends State<MultiTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final List<_TransactionEntry> _entries = [];

  // Shared defaults state
  bool _useSharedDate = false;
  DateTime _sharedDate = DateTime.now();
  bool _useSharedCategory = false;
  String _sharedCategory = '';

  String get _defaultCategory {
    if (widget.initialCategory != null && widget.categories.contains(widget.initialCategory)) {
      return widget.initialCategory!;
    }
    return widget.categories.isNotEmpty ? widget.categories.first : '';
  }

  @override
  void initState() {
    super.initState();
    _sharedCategory = _defaultCategory;
    _addEntry();
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entries.add(_TransactionEntry(
        date: DateTime.now(),
        isExpense: true,
        category: _defaultCategory,
      ));
    });
  }

  void _removeEntry(int index) {
    if (_entries.length > 1) {
      setState(() {
        _entries[index].dispose();
        _entries.removeAt(index);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transactions = <Transaction>[];
      for (final entry in _entries) {
        final amount = double.parse(
          entry.amountController.text.replaceAll(',', '.'),
        );
        final date = _useSharedDate ? _sharedDate : entry.date;
        final category = _useSharedCategory ? _sharedCategory : entry.category;

        transactions.add(Transaction(
          accountId: widget.accountId,
          date: date,
          category: category,
          label: entry.labelController.text.trim(),
          debit: entry.isExpense ? amount : 0.0,
          credit: entry.isExpense ? 0.0 : amount,
        ));
      }

      Navigator.pop(context, transactions);
    }
  }

  Future<void> _selectSharedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sharedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _sharedDate = picked);
    }
  }

  Future<void> _selectEntryDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entries[index].date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _entries[index].date = picked);
    }
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color backgroundColor,
    required Color selectedColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? borderColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? iconColor : Colors.grey.shade600, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? iconColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedDefaultsCard() {
    return Card(
      key: const Key('shared_defaults_card'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shared Defaults',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Use same date for all'),
              value: _useSharedDate,
              onChanged: (value) {
                setState(() => _useSharedDate = value);
              },
            ),
            if (_useSharedDate)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${_sharedDate.day}/${_sharedDate.month}/${_sharedDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, size: 20),
                onTap: _selectSharedDate,
              ),
            const Divider(),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Use same category for all'),
              value: _useSharedCategory,
              onChanged: (value) {
                setState(() => _useSharedCategory = value);
              },
            ),
            if (_useSharedCategory && widget.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DropdownButtonFormField<String>(
                  initialValue: widget.categories.contains(_sharedCategory) ? _sharedCategory : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: widget.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sharedCategory = value);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(int index) {
    final entry = _entries[index];
    final showRemoveButton = _entries.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with entry number and remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (showRemoveButton)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeEntry(index),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Date picker (hidden if shared date enabled)
            if (!_useSharedDate)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, size: 20),
                onTap: () => _selectEntryDate(index),
              ),

            // Type toggle
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: 'Expense',
                    icon: Icons.remove,
                    isSelected: entry.isExpense,
                    backgroundColor: Colors.red.shade50,
                    selectedColor: Colors.red.shade100,
                    borderColor: Colors.red.shade300,
                    iconColor: Colors.red.shade700,
                    onTap: () => setState(() => entry.isExpense = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTypeButton(
                    label: 'Income',
                    icon: Icons.add,
                    isSelected: !entry.isExpense,
                    backgroundColor: Colors.green.shade50,
                    selectedColor: Colors.green.shade100,
                    borderColor: Colors.green.shade300,
                    iconColor: Colors.green.shade700,
                    onTap: () => setState(() => entry.isExpense = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category dropdown (hidden if shared category enabled)
            if (!_useSharedCategory && widget.categories.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: widget.categories.contains(entry.category) ? entry.category : null,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: widget.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => entry.category = value);
                  }
                },
              ),
            if (!_useSharedCategory && widget.categories.isNotEmpty) const SizedBox(height: 12),

            // Label
            TextFormField(
              controller: entry.labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a label';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Amount
            TextFormField(
              controller: entry.amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixText: '\u20AC',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSharedDefaultsCard(),
                  ...List.generate(_entries.length, (index) => _buildEntryCard(index)),
                ],
              ),
            ),
            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('add_another_button'),
                      onPressed: _addEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: Text('Save All (${_entries.length})'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
