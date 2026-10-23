import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final void Function(String title, int targetAmount) onGoalAdded;

  const AddGoalBottomSheet({
    super.key,
    required this.onGoalAdded,
  });

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final kurus = _targetAmountController.text.toKurus();
    if (kurus == null) return;

    widget.onGoalAdded(_titleController.text.trim(), kurus);
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
                l10n.goalsAdd,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppTextField(
                controller: _titleController,
                labelText: l10n.goalsNewTitle,
                prefixIcon: const Icon(Icons.flag_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.errorRequired : null,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              AppTextField(
                controller: _targetAmountController,
                labelText: l10n.goalsTargetAmount,
                prefixIcon: const Icon(Icons.currency_lira),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) => v?.toKurus() == null ? l10n.errorInvalidAmount : null,
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
