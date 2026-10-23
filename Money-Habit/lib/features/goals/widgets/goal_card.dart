import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/extensions/percent_extensions.dart';
import '../models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onAddMoney;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final percent = (goal.progress * 100).toInt();
    final isCompleted = goal.isReached;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
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
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p8,
                        vertical: AppSizes.p4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      child: Text(
                        l10n.goalsCompletedBadge,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      percent.toPercent(locale),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.success : theme.colorScheme.primary,
                  ),
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
                        '${goal.savedAmount.toCurrency(locale)} / ${goal.targetAmount.toCurrency(locale)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: onAddMoney,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p12,
                        vertical: AppSizes.p4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.goalsAddStep),
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
