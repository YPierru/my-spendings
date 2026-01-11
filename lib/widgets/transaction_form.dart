import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final List<String> categories;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.categories,
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
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();

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
      _category = widget.categories.isNotEmpty ? widget.categories.first : '';
      _label = '';
      _amount = 0.0;
      _isExpense = true;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
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
        date: _date,
        category: category,
        label: _label,
        debit: _isExpense ? _amount : 0.0,
        credit: _isExpense ? 0.0 : _amount,
      );

      Navigator.pop(context, transaction);
    }
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
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Expense'), icon: Icon(Icons.remove)),
                ButtonSegment(value: false, label: Text('Income'), icon: Icon(Icons.add)),
              ],
              selected: {_isExpense},
              onSelectionChanged: (selected) {
                setState(() => _isExpense = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // Category
            Row(
              children: [
                Expanded(
                  child: _isNewCategory
                      ? TextFormField(
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
                        )
                      : DropdownButtonFormField<String>(
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
                            }
                          },
                          validator: (value) {
                            if (!_isNewCategory && value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isNewCategory ? Icons.list : Icons.add),
                  tooltip: _isNewCategory ? 'Select existing' : 'Add new',
                  onPressed: () {
                    setState(() => _isNewCategory = !_isNewCategory);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _label = value?.trim() ?? '',
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
