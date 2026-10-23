import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/widgets/app_text_field.dart';

class SetBudgetDialog extends StatefulWidget {
  final int currentLimit;
  final ValueChanged<int> onSave;

  const SetBudgetDialog({
    super.key,
    required this.currentLimit,
    required this.onSave,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentLimit > 0
        ? (widget.currentLimit / 100).toStringAsFixed(0)
        : '';
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final kurus = _controller.text.toKurus();
    if (kurus != null) {
      widget.onSave(kurus);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.budgetLimitInput),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          labelText: l10n.budgetMonthlyLimit,
          prefixIcon: const Icon(Icons.currency_lira),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          validator: (v) => v?.toKurus() == null ? l10n.errorInvalidAmount : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, AppSizes.buttonHeight * 0.8),
          ),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
