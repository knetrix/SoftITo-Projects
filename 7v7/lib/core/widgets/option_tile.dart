import 'package:flutter/material.dart';
import 'app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';
import 'pressable.dart';

/// Seçenek `opt` (§2.9): 52 min, köşe 16, `chip` zemin 16/700;
/// seçili: `accent` zemin + sağda `check-circle`.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.selected = false,
    this.onTap,
    this.centered = false,
    this.compact = false,
    this.tabular = false,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final bool selected;
  final VoidCallback? onTap;

  /// Izgara (3 sütun) seçenekleri: ortalı, 8/4 iç boşluk, 14 px.
  final bool centered;
  final bool compact;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = selected ? c.onAccent : c.ink;
    final titleStyle = centered
        ? AppTextStyles.bodySm(700, color: fg, tabular: true)
        : AppTextStyles.body(700, color: fg);
    final t = titleWidget ??
        Text(title ?? '',
            maxLines: centered ? 1 : null,
            overflow: centered ? TextOverflow.ellipsis : null,
            style: titleStyle);
    return Pressable(
      onTap: onTap,
      selected: selected,
      child: Container(
        constraints: BoxConstraints(minHeight: SheetScope.inSheet(context) ? 48 : 52),
        padding: centered
            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.accent : c.chip,
          borderRadius: BorderRadius.circular(16),
        ),
        child: centered
            ? Center(child: t)
            : Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        t,
                        if (subtitle != null)
                          Text(subtitle!,
                              style: AppTextStyles.bodySm(500, color: fg)),
                      ],
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 12),
                    Icon(PhosphorIconsFill.checkCircle, size: 20, color: fg),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Çip `chip` (§2.9): 44, hap, `chip` zemin 14/700; seçili `ink` zemin, `bg` metin.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: selected ? c.ink : c.chip,
          shape: const StadiumBorder(),
        ),
        child: Text(label,
            style: AppTextStyles.bodySm(700, color: selected ? c.bg : c.ink)),
      ),
    );
  }
}

/// Segment `seg` (§2.9): `chip` zemin hap kap, 4 iç boşluk, 44'lük düğmeler;
/// seçili `card` zemin + hafif gölge.
class AppSegment extends StatelessWidget {
  const AppSegment({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(color: c.chip, shape: const StadiumBorder()),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? c.card : null,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: i == index
                          ? const [
                              BoxShadow(
                                color: AppColors.segShadow,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      labels[i],
                      style: AppTextStyles.bodySm(700,
                          color: i == index ? c.ink : c.ink2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
