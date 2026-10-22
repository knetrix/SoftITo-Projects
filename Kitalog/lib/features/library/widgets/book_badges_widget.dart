import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';

/// Kapağın köşesindeki biçim rozetleri: fiziksel kopya varsa "Fiziksel"
/// (kopya ödünç verildiyse onun yerine "Ödünçte"), dijital sürüm varsa
/// "Dijital". İkisi de yoksa (ör. istek listesi) rozet gösterilmez.
class BookBadgesWidget extends StatelessWidget {
  const BookBadgesWidget({super.key, required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: AppSizes.spaceXs,
      children: [
        if (book.isLent)
          _Badge(icon: Icons.swap_horiz, label: l10n.loanedBadge, emphasized: true)
        else if (book.isOwned)
          _Badge(icon: Icons.menu_book_outlined, label: l10n.physicalBadge),
        if (book.hasDigitalEdition)
          _Badge(icon: Icons.tablet_mac_outlined, label: l10n.digitalBadge),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, this.emphasized = false});

  final IconData icon;
  final String label;

  /// Ödünç gibi dikkat gerektiren durum vurgulu renkle gösterilir.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = emphasized ? colors.primary : colors.surfaceContainerHighest;
    final foreground = emphasized ? colors.onPrimary : colors.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceS, vertical: AppSizes.spaceXs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.spaceXs,
          children: [
            Icon(icon, size: AppSizes.iconS, color: foreground),
            Text(label, style: context.textTheme.labelSmall?.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
