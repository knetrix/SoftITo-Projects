import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/percent_extensions.dart';
import '../../../core/widgets/amount_text.dart';
import '../../expenses/models/expense_model.dart';
import 'donut_chart_painter.dart';

class CategoryDistributionCard extends StatelessWidget {
  final Map<ExpenseCategory, int> categoryAmounts;

  const CategoryDistributionCard({super.key, required this.categoryAmounts});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final total = categoryAmounts.values.fold<int>(0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.budgetCategoryDistribution,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p24),
                child: Center(
                  child: Text(
                    l10n.budgetNoCategoryData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      categoryAmounts: categoryAmounts,
                      emptyColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              Column(
                children: [
                  for (final entry in categoryAmounts.entries)
                    if (entry.value > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.p4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: entry.key.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spaceSm),
                            Expanded(
                              child: Text(
                                entry.key.label(l10n),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              ((entry.value / total) * 100).round().toPercent(
                                locale,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spaceSm),
                            AmountText(
                              amount: entry.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
