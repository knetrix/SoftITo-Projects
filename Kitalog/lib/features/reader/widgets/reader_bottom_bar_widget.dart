import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Önceki/sonraki sayfa, sayfa göstergesi ve hızlı geçiş kaydırıcısı.
class ReaderBottomBarWidget extends StatelessWidget {
  const ReaderBottomBarWidget({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onJump,
  });

  final int pageIndex;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = pageCount - 1;
    return Material(
      color: context.colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceS),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.readerPrevious,
                onPressed: pageIndex > 0 ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: _PageSlider(pageIndex: pageIndex, pageCount: pageCount, onJump: onJump),
              ),
              Text(
                l10n.readerPageIndicator(pageIndex + 1, pageCount),
                style: context.textTheme.labelMedium,
              ),
              IconButton(
                tooltip: l10n.readerNext,
                onPressed: pageIndex < last ? onNext : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageSlider extends StatelessWidget {
  const _PageSlider({
    required this.pageIndex,
    required this.pageCount,
    required this.onJump,
  });

  final int pageIndex;
  final int pageCount;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final last = pageCount - 1;
    if (last <= 0) return const SizedBox.shrink();
    return Slider(
      value: pageIndex.toDouble().clamp(0, last.toDouble()),
      max: last.toDouble(),
      divisions: last,
      label: context.l10n.readerPageIndicator(pageIndex + 1, pageCount),
      onChanged: (v) => onJump(v.round()),
    );
  }
}
