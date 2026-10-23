import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/amount_text.dart';

class ExpenseMonthFilter extends StatelessWidget {
  final DateTime currentMonth;
  final int totalAmount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ExpenseMonthFilter({
    super.key,
    required this.currentMonth,
    required this.totalAmount,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p8,
          vertical: AppSizes.p12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            ),
            Column(
              children: [
                Text(
                  currentMonth.formatMonthYear(locale),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXs),
                AmountText(
                  amount: totalAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
