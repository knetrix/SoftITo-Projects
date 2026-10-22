import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/loans_model.dart';

/// Sekmenin üstündeki özet: ödünçte, gecikmiş ve iadesi yaklaşan kitap sayısı.
class LoanSummaryWidget extends StatelessWidget {
  const LoanSummaryWidget({super.key, required this.state});

  final LoansModel state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, AppSizes.spaceS, AppSizes.spaceL, AppSizes.spaceS),
      child: Row(
        spacing: AppSizes.spaceS,
        children: [
          _StatTile(icon: Icons.swap_horiz, value: state.active.length, label: l10n.loansSummaryActive),
          _StatTile(
            icon: Icons.warning_amber_rounded,
            value: state.overdueCount,
            label: l10n.loansSummaryOverdue,
            danger: state.overdueCount > 0,
          ),
          _StatTile(icon: Icons.event_outlined, value: state.dueSoonCount, label: l10n.loansSummaryDueSoon),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label, this.danger = false});

  final IconData icon;
  final int value;
  final String label;

  /// Gecikmiş ödünç varsa kutucuk hata renginde gösterilir.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = danger ? colors.errorContainer : colors.surfaceContainerHigh;
    final foreground = danger ? colors.onErrorContainer : colors.onSurface;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: background,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppSizes.iconM, color: danger ? foreground : colors.primary),
              Text('$value', style: context.textTheme.headlineSmall?.copyWith(color: foreground)),
              Text(label, maxLines: 2, style: context.textTheme.labelMedium?.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
