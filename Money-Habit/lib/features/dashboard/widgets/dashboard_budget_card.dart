import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/widgets/amount_text.dart';

class DashboardBudgetCard extends StatelessWidget {
  final int limit;
  final int spent;
  final int remaining;
  final bool isOver;
  final VoidCallback onTap;

  const DashboardBudgetCard({
    super.key,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.isOver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final statusColor = isOver ? AppColors.error : AppColors.success;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dashboardRemainingBudget,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSm),
              AmountText(
                amount: remaining.abs(),
                prefix: isOver ? '-' : '',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.budgetSpent}: ${spent.toCurrency(locale)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${l10n.budgetMonthlyLimit}: ${limit.toCurrency(locale)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
