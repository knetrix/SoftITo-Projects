import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/validation_extensions.dart';
import '../models/loan_model.dart';
import '../utils/validators.dart';

/// Ödünç verme: kime, ne zaman (bugün), iade tarihi (isteğe bağlı).
/// [initial] verilirse mevcut ödünç düzenlenir: kime ve iade tarihi
/// değiştirilebilir, veriliş tarihi korunur.
class LoanDialog extends StatefulWidget {
  const LoanDialog({super.key, this.initial});

  final LoanModel? initial;

  static Future<LoanModel?> show(BuildContext context, {LoanModel? initial}) {
    return showDialog<LoanModel>(
      context: context,
      builder: (_) => LoanDialog(initial: initial),
    );
  }

  @override
  State<LoanDialog> createState() => _LoanDialogState();
}

class _LoanDialogState extends State<LoanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _borrower = TextEditingController(text: widget.initial?.borrowerName);
  late DateTime? _dueAt = widget.initial?.dueAt;

  @override
  void dispose() {
    _borrower.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // Düzenlemede iade tarihi veriliş gününden önce olamaz (geçmiş bir gün
    // seçilebilir); yeni ödünçte bugünden başlar.
    final lentAt = widget.initial?.lentAt ?? now;
    final firstDate = DateTime(lentAt.year, lentAt.month, lentAt.day);
    final lastDate = now.add(const Duration(days: 365 * 3));
    var initialDate = _dueAt ?? now.add(const Duration(days: 14));
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _dueAt = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      LoanModel(
        borrowerName: _borrower.text.trim(),
        lentAt: widget.initial?.lentAt ?? DateTime.now(),
        dueAt: _dueAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.loanLend : l10n.loansEditTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _borrower,
              autofocus: widget.initial == null,
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
