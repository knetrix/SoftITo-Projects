import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Yüzde ve sayfa bilgisiyle ilerleme çubuğu.
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.pageCount,
  });

  final double progress;
  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Semantics(
      label: context.l10n.progressSemantics(percent),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusChip),
            child: LinearProgressIndicator(value: progress),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.l10n.pageProgress(currentPage, pageCount),
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall,
                ),
              ),
              Text(
                context.l10n.progressPercent(percent),
                style: context.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
