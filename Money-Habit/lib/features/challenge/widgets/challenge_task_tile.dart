import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/challenge_controller.dart';
import '../models/challenge_model.dart';

class ChallengeTaskTile extends StatelessWidget {
  final ChallengeTaskModel task;
  final TaskStatus status;
  final VoidCallback onComplete;

  const ChallengeTaskTile({
    super.key,
    required this.task,
    required this.status,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final borderColor = switch (status) {
      TaskStatus.completed => AppColors.success,
      TaskStatus.today => theme.colorScheme.primary,
      TaskStatus.missed => theme.colorScheme.outline.withValues(alpha: 0.4),
      TaskStatus.locked => theme.colorScheme.outline.withValues(alpha: 0.2),
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
          color: borderColor,
          width: status == TaskStatus.today ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: status == TaskStatus.completed
                      ? AppColors.success
                      : (status == TaskStatus.today
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3)),
                  child: Text(
                    '${task.dayNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                _buildStatusBadge(context, l10n),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              task.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (status == TaskStatus.today) ...[
              const SizedBox(height: AppSizes.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.challengeCompleteButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, dynamic l10n) {
    return switch (status) {
      TaskStatus.completed => const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 20,
        ),
      TaskStatus.today => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p8,
            vertical: AppSizes.p4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.r8),
          ),
          child: Text(
            l10n.challengeTodayTask,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      TaskStatus.missed => Text(
          l10n.challengeMissed,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      TaskStatus.locked => Icon(
          Icons.lock_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
    };
  }
}
