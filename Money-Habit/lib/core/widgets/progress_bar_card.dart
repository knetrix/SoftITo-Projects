import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/money_extensions.dart';
import '../extensions/percent_extensions.dart';

class ProgressBarCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double progress; // 0.0 - 1.0
  final int savedAmount; // kuruş
  final int targetAmount; // kuruş
  final Color? progressColor;
  final VoidCallback? onTap;

  const ProgressBarCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.progress,
    required this.savedAmount,
    required this.targetAmount,
    this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final percent = (progress * 100).toInt();
    final effectiveColor = progressColor ?? AppColors.success;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSizes.spaceXs),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Text(
                    percent.toPercent(localeCode),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: effectiveColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                ),
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    savedAmount.toCurrency(localeCode),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    targetAmount.toCurrency(localeCode),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
