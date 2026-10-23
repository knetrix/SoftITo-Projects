import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../challenge/models/challenge_model.dart';

class DashboardChallengeCard extends StatelessWidget {
  final ChallengeModel? challenge;
  final ChallengeTaskModel? todayTask;
  final VoidCallback onTap;

  const DashboardChallengeCard({
    super.key,
    required this.challenge,
    required this.todayTask,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (challenge == null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.darkSecondary, size: 28),
                const SizedBox(width: AppSizes.spaceMd),
                Expanded(
                  child: Text(
                    l10n.dashboardNoChallenge,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  l10n.dashboardStartChallenge,
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

    final streak = challenge!.currentStreak;
    final isTodayDone = todayTask?.isCompleted ?? false;

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
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.warning, size: 22),
                      const SizedBox(width: AppSizes.spaceXs),
                      Text(
                        l10n.dashboardDaysStreak(streak),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Text(
                todayTask?.title ?? l10n.challengeCompletedTask,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spaceXs),
              Text(
                todayTask?.description ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                children: [
                  Icon(
                    isTodayDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isTodayDone ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: AppSizes.spaceXs),
                  Text(
                    isTodayDone ? l10n.challengeCompletedTask : l10n.challengeTodayTask,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isTodayDone ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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
