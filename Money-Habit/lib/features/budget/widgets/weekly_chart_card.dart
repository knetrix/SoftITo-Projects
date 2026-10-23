import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import 'weekly_bar_chart_painter.dart';

class WeeklyChartCard extends StatelessWidget {
  final Map<DateTime, int> dailyExpenses;

  const WeeklyChartCard({
    super.key,
    required this.dailyExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.budgetWeeklyExpenses,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: WeeklyBarChartPainter(
                  dailyExpenses: dailyExpenses,
                  barColor: theme.colorScheme.primary,
                  trackColor: theme.colorScheme.outline.withValues(alpha: 0.15),
                  textColor: theme.colorScheme.onSurfaceVariant,
                  localeCode: locale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
