import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountFormDialog extends StatefulWidget {
  final Account? existingAccount;

  const AccountFormDialog({super.key, this.existingAccount});

  @override
  State<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingAccount?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.existingAccount != null;

  void _save() {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.existingAccount?.id,
        name: _nameController.text.trim(),
        createdAt: widget.existingAccount?.createdAt,
      );
      Navigator.of(context).pop(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Account' : 'Add Account'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an account name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
