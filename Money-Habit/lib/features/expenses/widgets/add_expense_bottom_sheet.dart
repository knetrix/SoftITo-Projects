import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/expense_model.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final ValueChanged<ExpenseModel> onExpenseAdded;

  const AddExpenseBottomSheet({
    super.key,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.market;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final kurus = _amountController.text.toKurus();
    if (kurus == null) return;

    final expense = ExpenseModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: kurus,
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    widget.onExpenseAdded(expense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

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
                l10n.expensesNewTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppTextField(
                controller: _amountController,
                labelText: l10n.expensesAmount,
                prefixIcon: const Icon(Icons.currency_lira),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) => v?.toKurus() == null ? l10n.errorInvalidAmount : null,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              Text(
                l10n.expensesCategory,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Wrap(
                spacing: AppSizes.p8,
                runSpacing: AppSizes.p8,
                children: [
                  for (final cat in ExpenseCategory.values)
                    ChoiceChip(
                      avatar: Icon(cat.icon, size: 16, color: cat.color),
                      label: Text(cat.label(l10n)),
                      selected: _selectedCategory == cat,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.expensesDate),
                trailing: Text(
                  _selectedDate.formatDate(locale),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              AppTextField(
                controller: _noteController,
                labelText: l10n.expensesNote,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppPrimaryButton(
                label: l10n.commonSave,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
