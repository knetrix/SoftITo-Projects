import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Ödüncün durumunu gösteren küçük etiket: gecikme hata renginde, yaklaşan
/// iade vurgu renginde, diğerleri sade.
enum LoanStatusTone { neutral, warning, danger }

class LoanStatusChipWidget extends StatelessWidget {
  const LoanStatusChipWidget({super.key, required this.icon, required this.label, this.tone = LoanStatusTone.neutral});

  final IconData icon;
  final String label;
  final LoanStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      LoanStatusTone.danger => (colors.errorContainer, colors.onErrorContainer),
      LoanStatusTone.warning => (colors.primaryContainer, colors.onPrimaryContainer),
      LoanStatusTone.neutral => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.radiusChip)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceS, vertical: AppSizes.spaceXs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.spaceXs,
          children: [
            Icon(icon, size: AppSizes.iconS, color: foreground),
            Flexible(
              child: Text(label, style: context.textTheme.labelMedium?.copyWith(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
