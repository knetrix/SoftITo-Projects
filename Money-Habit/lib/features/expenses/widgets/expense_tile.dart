import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/amount_text.dart';
import '../models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDismissed;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final category = expense.category;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.p4),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          title: Text(
            category.label(l10n),
            style: context.textStyles.titleSmall,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.note != null && expense.note!.isNotEmpty)
                Text(
                  expense.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall,
                ),
              Text(
                expense.date.formatDate(locale),
                style: context.textStyles.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: AmountText(
            amount: expense.amount,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
