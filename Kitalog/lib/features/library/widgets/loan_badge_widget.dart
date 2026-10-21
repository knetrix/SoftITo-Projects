import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Ödünç verilmiş kitapların kapağında görünen rozet.
class LoanBadgeWidget extends StatelessWidget {
  const LoanBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceS,
          vertical: AppSizes.spaceXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz, size: AppSizes.iconS, color: colors.onPrimary),
            const SizedBox(width: AppSizes.spaceXs),
            Text(
              context.l10n.loanedBadge,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
