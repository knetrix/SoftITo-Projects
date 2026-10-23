import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/amount_text.dart';

class BudgetSummaryCard extends StatelessWidget {
  final int limitAmount;
  final int spentAmount;
  final int remainingAmount;
  final bool isOver;
  final VoidCallback onEditLimit;

  const BudgetSummaryCard({
    super.key,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.isOver,
    required this.onEditLimit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final ratio = limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0.0;
    final progressColor = isOver ? AppColors.error : AppColors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.budgetMonthlyLimit,
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.budgetSetLimit),
                  onPressed: onEditLimit,
                ),
              ],
            ),
            AmountText(
              amount: limitAmount,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.budgetSpent,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AmountText(
                      amount: spentAmount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isOver ? AppColors.error : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOver ? l10n.budgetOverBudget : l10n.budgetRemaining,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOver ? AppColors.error : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AmountText(
                      amount: remainingAmount.abs(),
                      prefix: isOver ? '-' : '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isOver ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
