import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// 1-5 puan gösterimi; `onChanged` verilirse seçilebilir.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = AppSizes.iconM,
  });

  final int? rating;
  final ValueChanged<int>? onChanged;
  final double size;

  static const int maxRating = 5;

  @override
  Widget build(BuildContext context) {
    final value = rating ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= maxRating; i++)
          _Star(
            filled: i <= value,
            size: size,
            semanticsLabel: context.l10n.ratingStarSemantics(i),
            onTap: onChanged == null ? null : () => onChanged!(i),
          ),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.filled,
    required this.size,
    required this.semanticsLabel,
    required this.onTap,
  });

  final bool filled;
  final double size;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      filled ? Icons.star_rounded : Icons.star_outline_rounded,
      size: size,
      color: filled ? AppColors.star : context.colors.outline,
    );
    if (onTap == null) return icon;
    return IconButton(
      onPressed: onTap,
      tooltip: semanticsLabel,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size + 12, height: size + 12),
      icon: icon,
    );
  }
}
