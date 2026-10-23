import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/progress_bar_card.dart';
import '../../goals/models/goal_model.dart';

class DashboardGoalCard extends StatelessWidget {
  final GoalModel? goal;
  final VoidCallback onTap;

  const DashboardGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (goal == null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: AppColors.info, size: 28),
                const SizedBox(width: AppSizes.spaceMd),
                Expanded(
                  child: Text(
                    l10n.dashboardNoGoal,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  l10n.dashboardAddGoal,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ProgressBarCard(
      title: goal!.title,
      subtitle: l10n.dashboardNearestGoal,
      progress: goal!.progress,
      savedAmount: goal!.savedAmount,
      targetAmount: goal!.targetAmount,
      progressColor: goal!.isReached ? AppColors.success : theme.colorScheme.primary,
      onTap: onTap,
    );
  }
}
