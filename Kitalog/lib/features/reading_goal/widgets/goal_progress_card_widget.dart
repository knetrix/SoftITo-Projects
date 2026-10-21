import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Hedef ilerleme kartı: Biten / Hedef ve ilerleme çubuğu.
class GoalProgressCardWidget extends StatelessWidget {
  const GoalProgressCardWidget({
    super.key,
    required this.year,
    required this.finished,
    required this.target,
    required this.remaining,
    required this.progress,
  });

  final int year;
  final int finished;
  final int target;
  final int remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXl),
        child: Column(
          children: [
            Text(l10n.goalYearLabel(year), style: context.textTheme.labelLarge),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              l10n.goalProgress(finished, target),
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spaceL),
            Semantics(
              label: l10n.goalProgress(finished, target),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSizes.spaceM,
                borderRadius: BorderRadius.circular(AppSizes.radiusChip),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              remaining == 0 ? l10n.goalCompleted : l10n.goalRemaining(remaining),
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
