import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';
import 'pressable.dart';

enum AppButtonVariant { pri, alt, danger, sent }

/// Buton (§2.9): pri / alt / danger / gönderildi; `small` = 44 yükseklik, 14 px.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.pri,
    this.small = false,
    this.wide = false,
    this.height,
    this.semanticLabel,
    this.iconOnly,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool small;
  final bool wide;
  final double? height;
  final String? semanticLabel;

  /// Yalnızca ikon (24 px) — ör. yeşil tik "Takımı kaydet".
  final IconData? iconOnly;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final h = height ?? (small ? 44.0 : (SheetScope.inSheet(context) ? 48.0 : 52.0));
    final (Color? bg, Color fg, Color? border) = switch (variant) {
      AppButtonVariant.pri => (c.accent, c.onAccent, null),
      AppButtonVariant.alt => (c.chip, c.ink, null),
      AppButtonVariant.danger => (null, c.error, c.error),
      AppButtonVariant.sent => (null, c.ink2, c.line),
    };
    final content = iconOnly != null
        ? Icon(iconOnly, size: 24, color: fg)
        : Row(
      mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button(color: fg, size: small ? 14 : 16),
          ),
        ),
      ],
    );
    final box = Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: iconOnly != null ? 0 : (small ? 16 : 24)),
      decoration: ShapeDecoration(
        color: bg,
        shape: StadiumBorder(
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border, width: 1.5),
        ),
      ),
      // Geniş değilse içerik kadar; Container(alignment:) gevşek kısıtta
      // tüm genişliği kaplardı.
      child: Center(widthFactor: wide ? null : 1, child: content),
    );
    if (variant == AppButtonVariant.sent) {
      return Semantics(
        button: true,
        enabled: false,
        label: semanticLabel,
        child: box,
      );
    }
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: box,
    );
  }
}
