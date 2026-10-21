import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Hedef kitap sayısı ayarlayıcı (−/+).
class GoalTargetStepperWidget extends StatelessWidget {
  const GoalTargetStepperWidget({
    super.key,
    required this.target,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int target;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSizes.spaceL,
      children: [
        IconButton.outlined(
          tooltip: l10n.goalDecrease,
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        Flexible(
          child: Text(
            l10n.goalTarget(target),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
        ),
        IconButton.filled(
          tooltip: l10n.goalIncrease,
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
