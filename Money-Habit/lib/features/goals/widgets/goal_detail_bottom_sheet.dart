import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../../../core/extensions/percent_extensions.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../models/goal_model.dart';

class GoalDetailBottomSheet extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onAddMoney;
  final VoidCallback onDelete;

  const GoalDetailBottomSheet({
    super.key,
    required this.goal,
    required this.onAddMoney,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final percent = (goal.progress * 100).toInt();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: l10n.goalsDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isReached ? AppColors.success : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.savedAmount.toCurrency(locale)} / ${goal.targetAmount.toCurrency(locale)}',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  percent.toPercent(locale),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.isReached ? AppColors.success : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceLg),
            AppPrimaryButton(
              label: l10n.goalsAddStep,
              icon: Icons.add,
              onPressed: onAddMoney,
            ),
            const SizedBox(height: AppSizes.spaceLg),
            Text(
              l10n.goalsStepsHistory,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: goal.steps.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      child: Center(
                        child: Text(
                          l10n.goalsNoSteps,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: goal.steps.length,
                      itemBuilder: (context, index) {
                        final step = goal.steps[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.arrow_upward, size: 16),
                          ),
                          title: AmountText(
                            amount: step.amount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          subtitle: step.note != null ? Text(step.note!) : null,
                          trailing: Text(
                            step.date.formatDate(locale),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
