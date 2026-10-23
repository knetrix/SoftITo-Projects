import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/challenge_model.dart';

class ChallengeHeaderCard extends StatelessWidget {
  final ChallengeModel challenge;
  final int? currentDay;

  const ChallengeHeaderCard({
    super.key,
    required this.challenge,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final completedCount = challenge.completedTaskCount;
    final progress = (completedCount / challenge.tasks.length).clamp(0.0, 1.0);
    final displayDay = currentDay != null ? currentDay!.clamp(1, 10) : 1;

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
                  challenge.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.challengeDaysCounter(displayDay),
                  style: theme.textTheme.titleSmall?.copyWith(
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
                value: progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  challenge.isCompleted ? AppColors.success : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.warning, size: 20),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      l10n.challengeCurrentStreak(challenge.currentStreak),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined, color: AppColors.darkSecondary, size: 20),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      l10n.challengeBestStreak(challenge.bestStreak),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
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
