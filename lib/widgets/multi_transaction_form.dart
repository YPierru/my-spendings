import 'package:flutter/material.dart';
import '../models/transaction.dart';

class MultiTransactionForm extends StatefulWidget {
  final List<String> categories;
  final int accountId;
  final String? initialCategory;
  final Future<List<String>> Function(String category)? onLoadLabels;

  const MultiTransactionForm({
    super.key,
    required this.categories,
    required this.accountId,
    this.initialCategory,
    this.onLoadLabels,
  });

  @override
  State<MultiTransactionForm> createState() => _MultiTransactionFormState();
}

class _TransactionEntry {
  DateTime date;
  bool isExpense;
  String category;
  TextEditingController labelController;
  final TextEditingController amountController;

  _TransactionEntry({
    required this.date,
    required this.isExpense,
    required this.category,
  })  : labelController = TextEditingController(),
        amountController = TextEditingController();

  void dispose() {
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

  // Label autocomplete cache: category -> labels
  final Map<String, List<String>> _labelCache = {};

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
    // Pre-load labels for the default category
    if (_defaultCategory.isNotEmpty) {
      _getLabelsForCategory(_defaultCategory);
    }
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

  Future<List<String>> _getLabelsForCategory(String category) async {
    if (widget.onLoadLabels == null) return [];
    if (_labelCache.containsKey(category)) return _labelCache[category]!;
    final labels = await widget.onLoadLabels!(category);
    _labelCache[category] = labels;
    return labels;
  }

  Widget _buildLabelAutocomplete(_TransactionEntry entry) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        final category = _useSharedCategory ? _sharedCategory : entry.category;
        if (category.isEmpty) return const Iterable<String>.empty();
        final labels = _labelCache[category] ?? const [];
        final query = textEditingValue.text.toLowerCase();
        return labels.where((l) => l.toLowerCase().contains(query));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Use the Autocomplete's controller as the entry's label controller
        entry.labelController = controller;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
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
        );
      },
      onSelected: (selection) {
        entry.labelController.text = selection;
      },
    );
  }

  Widget _buildTypeToggle(_TransactionEntry entry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => entry.isExpense = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.isExpense ? Colors.red.shade100 : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              border: Border.all(
                color: entry.isExpense ? Colors.red.shade300 : Colors.grey.shade300,
                width: entry.isExpense ? 2 : 1,
              ),
            ),
            child: Icon(
              Icons.remove,
              size: 18,
              color: entry.isExpense ? Colors.red.shade700 : Colors.grey.shade400,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => entry.isExpense = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: !entry.isExpense ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              border: Border.all(
                color: !entry.isExpense ? Colors.green.shade300 : Colors.grey.shade300,
                width: !entry.isExpense ? 2 : 1,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 18,
              color: !entry.isExpense ? Colors.green.shade700 : Colors.grey.shade400,
            ),
          ),
        ),
      ],
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
                      _getLabelsForCategory(value);
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
            // Date row (or just remove button when shared date enabled)
            if (!_useSharedDate)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEntryDate(index),
                      child: Row(
                        children: [
                          Text(
                            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
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
            if (!_useSharedDate) const SizedBox(height: 8),

            // Category dropdown (with remove button when shared date hides the date row)
            if (!_useSharedCategory && widget.categories.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                          _getLabelsForCategory(value);
                        }
                      },
                    ),
                  ),
                  if (_useSharedDate && showRemoveButton) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeEntry(index),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            if (!_useSharedCategory && widget.categories.isNotEmpty) const SizedBox(height: 8),

            // Remove button when both shared date and shared category are enabled
            if (_useSharedDate && _useSharedCategory && showRemoveButton)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeEntry(index),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

            // Label with autocomplete
            _buildLabelAutocomplete(entry),
            const SizedBox(height: 8),

            // Type toggle + Amount on same row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeToggle(entry),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
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
