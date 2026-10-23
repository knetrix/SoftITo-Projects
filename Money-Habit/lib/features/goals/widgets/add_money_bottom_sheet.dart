import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';

class AddMoneyBottomSheet extends StatefulWidget {
  final String goalTitle;
  final void Function(int amount, String? note) onMoneyAdded;

  const AddMoneyBottomSheet({
    super.key,
    required this.goalTitle,
    required this.onMoneyAdded,
  });

  @override
  State<AddMoneyBottomSheet> createState() => _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends State<AddMoneyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final kurus = _amountController.text.toKurus();
    if (kurus == null) return;

    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
    widget.onMoneyAdded(kurus, note);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.p24,
        right: AppSizes.p24,
        top: AppSizes.p24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.goalTitle} – ${l10n.goalsAddStep}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppTextField(
                controller: _amountController,
                labelText: l10n.goalsStepAmount,
                prefixIcon: const Icon(Icons.currency_lira),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) => v?.toKurus() == null ? l10n.errorInvalidAmount : null,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              AppTextField(
                controller: _noteController,
                labelText: l10n.goalsStepNote,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppPrimaryButton(
                label: l10n.commonSave,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
