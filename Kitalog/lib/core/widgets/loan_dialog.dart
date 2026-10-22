import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/models/loan_model.dart';
import '../../../core/utils/validators.dart';

/// Ödünç verme: kime, ne zaman (bugün), iade tarihi (isteğe bağlı).
class LoanDialog extends StatefulWidget {
  const LoanDialog({super.key});

  static Future<LoanModel?> show(BuildContext context) {
    return showDialog<LoanModel>(
      context: context,
      builder: (_) => const LoanDialog(),
    );
  }

  @override
  State<LoanDialog> createState() => _LoanDialogState();
}

class _LoanDialogState extends State<LoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _borrower = TextEditingController();
  DateTime? _dueAt;

  @override
  void dispose() {
    _borrower.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueAt = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      LoanModel(
        borrowerName: _borrower.text.trim(),
        lentAt: DateTime.now(),
        dueAt: _dueAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.loanLend),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _borrower,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(labelText: l10n.loanBorrower),
              validator: (v) => Validators.required(v)?.message(l10n),
            ),
            _DueDateTile(
              dueAt: _dueAt,
              onPick: _pickDate,
              onClear: () => setState(() => _dueAt = null),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _submit,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class _DueDateTile extends StatelessWidget {
  const _DueDateTile({
    required this.dueAt,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? dueAt;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = dueAt;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(
        date == null ? l10n.loanDueDate : l10n.loanDueAt(context.formatDate(date)),
      ),
      trailing: date == null
          ? null
          : IconButton(
              tooltip: l10n.loanClearDate,
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
      onTap: onPick,
    );
  }
}
