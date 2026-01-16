import 'package:flutter/material.dart';

class DeleteAccountDialog extends StatefulWidget {
  final String accountName;

  const DeleteAccountDialog({super.key, required this.accountName});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_checkName);
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _checkName() {
    setState(() {
      _canDelete = _confirmController.text == widget.accountName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will permanently delete "${widget.accountName}" and all its transactions.',
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          Text(
            'Type "${widget.accountName}" to confirm:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            decoration: InputDecoration(
              hintText: widget.accountName,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
