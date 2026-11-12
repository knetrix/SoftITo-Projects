import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

enum IconButtonVariant { normal, danger, pri, plain }

/// İkon buton `ib` (§2.9): 44×44 daire, `chip` zemin, ikon 22.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = IconButtonVariant.normal,
    this.size = 44,
    this.iconSize = 22,
    this.badge,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IconButtonVariant variant;
  final double size;
  final double iconSize;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (Color? bg, Color fg, Color? border) = switch (variant) {
      IconButtonVariant.normal => (c.chip, c.ink, null),
      IconButtonVariant.danger => (null, c.error, c.error),
      IconButtonVariant.pri => (c.accent, c.onAccent, null),
      IconButtonVariant.plain => (null, c.ink, null),
    };
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: bg,
                shape: CircleBorder(
                  side: border == null
                      ? BorderSide.none
                      : BorderSide(color: border, width: 1.5),
                ),
              ),
              child: Icon(icon, size: iconSize, color: fg),
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.label(800, color: c.bg, tabular: true)
                        .copyWith(height: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
