import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Aylık biten kitap dağılımı (çizelge paketi olmadan, çekirdek widget'larla).
class MonthlyChartWidget extends StatelessWidget {
  const MonthlyChartWidget({
    super.key,
    required this.monthly,
    required this.maxValue,
  });

  final List<int> monthly;
  final int maxValue;

  static const double chartHeight = 120;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat.MMM(locale);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.goalMonthlyTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < monthly.length; i++)
                  Expanded(
                    child: _MonthBar(
                      label: monthFormat.format(DateTime(2000, i + 1)),
                      value: monthly[i],
                      maxValue: maxValue,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final int value;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final factor = maxValue == 0 ? 0.0 : value / maxValue;
    return Semantics(
      label: context.l10n.goalMonthSemantics(label, value),
      excludeSemantics: true,
      child: Column(
        children: [
          Text('$value', style: context.textTheme.labelSmall),
          const SizedBox(height: AppSizes.spaceXs),
          SizedBox(
            height: MonthlyChartWidget.chartHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: factor == 0 ? 0.02 : factor,
                widthFactor: 0.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: value == 0
                        ? context.colors.outlineVariant
                        : context.colors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS / 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
