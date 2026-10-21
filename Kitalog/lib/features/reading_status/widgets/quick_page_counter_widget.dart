import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Hızlı sayfa sayacı (−/+).
class QuickPageCounterWidget extends StatelessWidget {
  const QuickPageCounterWidget({
    super.key,
    required this.currentPage,
    required this.onChange,
  });

  final int currentPage;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          tooltip: l10n.pageDecrement,
          onPressed: () => onChange(-1),
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceM),
          child: Text('$currentPage', style: context.textTheme.titleMedium),
        ),
        IconButton.filled(
          tooltip: l10n.pageIncrement,
          onPressed: () => onChange(1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
