import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final List<String> categories;
  final String? initialCategory;
  final int accountId;
  final Future<List<String>> Function(String category)? onLoadLabels;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.categories,
    this.initialCategory,
    required this.accountId,
    this.onLoadLabels,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late String _category;
  late String _label;
  late double _amount;
  late bool _isExpense;
  bool _isNewCategory = false;
  final _categoryController = TextEditingController();
  TextEditingController _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, List<String>> _labelCache = {};

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _date = t.date;
      _category = t.category;
      _label = t.label;
      _amount = t.amount;
      _isExpense = t.isExpense;
      _labelController.text = t.label;
      _amountController.text = t.amount.toStringAsFixed(2);
    } else {
      _date = DateTime.now();
      // Use initialCategory if provided and valid, otherwise use first category
      if (widget.initialCategory != null &&
          widget.categories.contains(widget.initialCategory)) {
        _category = widget.initialCategory!;
      } else {
        _category = widget.categories.isNotEmpty ? widget.categories.first : '';
      }
      _label = '';
      _amount = 0.0;
      _isExpense = true;
    }
    // Pre-load labels for the initial category
    if (_category.isNotEmpty) {
      _getLabelsForCategory(_category);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<List<String>> _getLabelsForCategory(String category) async {
    if (widget.onLoadLabels == null) return [];
    if (_labelCache.containsKey(category)) return _labelCache[category]!;
    final labels = await widget.onLoadLabels!(category);
    _labelCache[category] = labels;
    return labels;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final category = _isNewCategory ? _categoryController.text.trim() : _category;

      final transaction = Transaction(
        id: widget.transaction?.id,
        accountId: widget.accountId,
        date: _date,
        category: category,
        label: _label,
        debit: _isExpense ? _amount : 0.0,
        credit: _isExpense ? 0.0 : _amount,
      );

      Navigator.pop(context, transaction);
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            Icon(icon, color: isSelected ? iconColor : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? iconColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
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
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const Divider(),

            // Type toggle
            const SizedBox(height: 8),
            const Text('Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: 'Expense',
                    icon: Icons.remove,
                    isSelected: _isExpense,
                    backgroundColor: Colors.red.shade50,
                    selectedColor: Colors.red.shade100,
                    borderColor: Colors.red.shade300,
                    iconColor: Colors.red.shade700,
                    onTap: () => setState(() => _isExpense = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    label: 'Income',
                    icon: Icons.add,
                    isSelected: !_isExpense,
                    backgroundColor: Colors.green.shade50,
                    selectedColor: Colors.green.shade100,
                    borderColor: Colors.green.shade300,
                    iconColor: Colors.green.shade700,
                    onTap: () => setState(() => _isExpense = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isNewCategory) ...[
                  DropdownButtonFormField<String>(
                    initialValue: widget.categories.contains(_category) ? _category : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                        _getLabelsForCategory(value);
                      }
                    },
                    validator: (value) {
                      if (!_isNewCategory && value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isNewCategory = true),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Category'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'New Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isNewCategory && (value == null || value.trim().isEmpty)) {
                        return 'Please enter a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isNewCategory = false),
                    icon: const Icon(Icons.list),
                    label: const Text('Select Existing Category'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Label with autocomplete
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _labelController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                final category = _isNewCategory ? _categoryController.text : _category;
                if (category.isEmpty) return const Iterable<String>.empty();
                final labels = _labelCache[category] ?? const [];
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
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                  onSaved: (value) => _label = value?.trim() ?? '',
                );
              },
              onSelected: (selection) {
                _labelController.text = selection;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
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
              onSaved: (value) {
                _amount = double.parse(value!.replaceAll(',', '.'));
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            FilledButton.icon(
              onPressed: _submit,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? 'Save Changes' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
