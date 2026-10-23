import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/section_header.dart';
import '../../expenses/models/expense_model.dart';

class DashboardRecentExpenses extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final VoidCallback onViewAll;

  const DashboardRecentExpenses({
    super.key,
    required this.expenses,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final recent = expenses.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.dashboardRecentExpenses,
          actionLabel: l10n.dashboardViewAll,
          onAction: onViewAll,
        ),
        if (recent.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Center(
                child: Text(
                  l10n.dashboardNoExpenses,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          for (final item in recent)
            Card(
              margin: const EdgeInsets.symmetric(vertical: AppSizes.p4),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.category.icon, color: item.category.color, size: 20),
                ),
                title: Text(
                  item.category.label(l10n),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  item.date.formatDate(locale),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: AmountText(
                  amount: item.amount,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: onViewAll,
              ),
            ),
      ],
    );
  }
}
