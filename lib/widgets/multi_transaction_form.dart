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

class _StagedTransaction {
  DateTime date;
  bool isExpense;
  String category;
  String label;
  double amount;

  _StagedTransaction({
    required this.date,
    required this.isExpense,
    required this.category,
    required this.label,
    required this.amount,
  });
}

class _MultiTransactionFormState extends State<MultiTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  // Staged transactions list
  final List<_StagedTransaction> _stagedTransactions = [];
  int? _editingIndex;

  // Single-form controllers and state
  final TextEditingController _amountController = TextEditingController();
  DateTime _formDate = DateTime.now();
  bool _formIsExpense = true;
  String _formCategory = '';
  int _formKeyCounter = 0;

  // Shared defaults state
  bool _useSharedDate = false;
  DateTime _sharedDate = DateTime.now();

  // Label autocomplete cache: category -> labels
  final Map<String, List<String>> _labelCache = {};

  // Autocomplete's internal controller reference
  TextEditingController? _labelController;

  String get _defaultCategory {
    if (widget.initialCategory != null && widget.categories.contains(widget.initialCategory)) {
      return widget.initialCategory!;
    }
    return widget.categories.isNotEmpty ? widget.categories.first : '';
  }

  @override
  void initState() {
    super.initState();
    _formCategory = _defaultCategory;
    if (_defaultCategory.isNotEmpty) {
      _getLabelsForCategory(_defaultCategory);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _formDate = DateTime.now();
      _formIsExpense = true;
      _formCategory = _defaultCategory;
      _amountController.clear();
      _formKeyCounter++;
      _editingIndex = null;
    });
  }

  void _addToStaging() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );
    final date = _useSharedDate ? _sharedDate : _formDate;

    setState(() {
      _stagedTransactions.add(_StagedTransaction(
        date: date,
        isExpense: _formIsExpense,
        category: _formCategory,
        label: _labelController?.text.trim() ?? '',
        amount: amount,
      ));
    });
    _clearForm();
  }

  void _updateStaged() {
    if (!_formKey.currentState!.validate()) return;
    if (_editingIndex == null) return;

    final amount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );
    final date = _useSharedDate ? _sharedDate : _formDate;

    setState(() {
      final staged = _stagedTransactions[_editingIndex!];
      staged.date = date;
      staged.isExpense = _formIsExpense;
      staged.category = _formCategory;
      staged.label = _labelController?.text.trim() ?? '';
      staged.amount = amount;
    });
    _clearForm();
  }

  void _editStaged(int index) {
    final staged = _stagedTransactions[index];
    setState(() {
      _editingIndex = index;
      _formDate = staged.date;
      _formIsExpense = staged.isExpense;
      _formCategory = staged.category;
      _amountController.text = staged.amount.toString().replaceAll('.', ',');
      // Remove trailing ,0 for whole numbers
      if (_amountController.text.endsWith(',0')) {
        _amountController.text = _amountController.text.substring(0, _amountController.text.length - 2);
      }
      _formKeyCounter++;
    });
    // Label will be set after Autocomplete rebuilds via initialValue
  }

  void _deleteStaged(int index) {
    setState(() {
      _stagedTransactions.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _formDate = DateTime.now();
        _formIsExpense = true;
        _formCategory = _defaultCategory;
        _amountController.clear();
        _formKeyCounter++;
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });
  }

  void _submit() {
    if (_stagedTransactions.isEmpty) return;

    final transactions = <Transaction>[];
    for (final staged in _stagedTransactions) {
      transactions.add(Transaction(
        accountId: widget.accountId,
        date: staged.date,
        category: staged.category,
        label: staged.label,
        debit: staged.isExpense ? staged.amount : 0.0,
        credit: staged.isExpense ? 0.0 : staged.amount,
      ));
    }

    Navigator.pop(context, transactions);
  }

  Future<void> _selectSharedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sharedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _sharedDate = picked;
        for (final staged in _stagedTransactions) {
          staged.date = picked;
        }
      });
    }
  }

  Future<void> _selectFormDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _formDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _formDate = picked);
    }
  }

  Future<List<String>> _getLabelsForCategory(String category) async {
    if (widget.onLoadLabels == null) return [];
    if (_labelCache.containsKey(category)) return _labelCache[category]!;
    final labels = await widget.onLoadLabels!(category);
    _labelCache[category] = labels;
    return labels;
  }

  Widget _buildLabelAutocomplete({String? initialValue}) {
    return Autocomplete<String>(
      key: ValueKey('label_autocomplete_$_formKeyCounter'),
      initialValue: initialValue != null ? TextEditingValue(text: initialValue) : null,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        if (_formCategory.isEmpty) return const Iterable<String>.empty();
        final labels = _labelCache[_formCategory] ?? const [];
        final query = textEditingValue.text.toLowerCase();
        return labels.where((l) => l.toLowerCase().contains(query));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _labelController = controller;
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
        _labelController?.text = selection;
      },
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _formIsExpense = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: _formIsExpense ? Colors.red.shade100 : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              border: Border.all(
                color: _formIsExpense ? Colors.red.shade300 : Colors.grey.shade300,
                width: _formIsExpense ? 2 : 1,
              ),
            ),
            child: Icon(
              Icons.remove,
              size: 18,
              color: _formIsExpense ? Colors.red.shade700 : Colors.grey.shade400,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _formIsExpense = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: !_formIsExpense ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              border: Border.all(
                color: !_formIsExpense ? Colors.green.shade300 : Colors.grey.shade300,
                width: !_formIsExpense ? 2 : 1,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 18,
              color: !_formIsExpense ? Colors.green.shade700 : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharedDateCard() {
    return Card(
      key: const Key('shared_defaults_card'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Use same date for all'),
              value: _useSharedDate,
              onChanged: (value) {
                setState(() {
                  _useSharedDate = value;
                  if (value) {
                    for (final staged in _stagedTransactions) {
                      staged.date = _sharedDate;
                    }
                  }
                });
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
          ],
        ),
      ),
    );
  }

  Widget _buildEntryForm() {
    final isEditing = _editingIndex != null;
    final editingLabel = isEditing ? _stagedTransactions[_editingIndex!].label : null;

    return Card(
      key: const Key('entry_form_card'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + Category row
            Row(
              children: [
                if (!_useSharedDate) ...[
                  GestureDetector(
                    onTap: _selectFormDate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_formDate.day}/${_formDate.month}/${_formDate.year}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.categories.isNotEmpty)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('category_dropdown_$_formKeyCounter'),
                      initialValue: widget.categories.contains(_formCategory) ? _formCategory : null,
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
                          setState(() => _formCategory = value);
                          _getLabelsForCategory(value);
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Label with autocomplete
            _buildLabelAutocomplete(initialValue: isEditing ? editingLabel : null),
            const SizedBox(height: 8),

            // Type toggle + Amount + Add/Update button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeToggle(),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
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
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    key: Key(isEditing ? 'update_button' : 'add_button'),
                    onPressed: isEditing ? _updateStaged : _addToStaging,
                    child: Text(isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagedTable() {
    if (_stagedTransactions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: List.generate(_stagedTransactions.length, (index) {
          final staged = _stagedTransactions[index];
          final isEditing = _editingIndex == index;
          final amountText = staged.amount.truncateToDouble() == staged.amount
              ? staged.amount.toInt().toString()
              : staged.amount.toStringAsFixed(2);

          return GestureDetector(
            onTap: () => _editStaged(index),
            child: Container(
              key: ValueKey('staged_row_$index'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEditing ? Colors.blue.shade50 : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${staged.date.day.toString().padLeft(2, '0')}/${staged.date.month.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      staged.category,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: Text(
                      staged.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${staged.isExpense ? '-' : '+'}$amountText €',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: staged.isExpense ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 32,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _deleteStaged(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
                  _buildSharedDateCard(),
                  _buildStagedTable(),
                  const SizedBox(height: 12),
                  _buildEntryForm(),
                ],
              ),
            ),
            if (_stagedTransactions.isNotEmpty)
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
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: Text('Save All (${_stagedTransactions.length})'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
