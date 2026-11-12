import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// Link `lnk` (§2.9): 44 min yükseklik, 700, altı çizili; vurgu ya da `ink`.
class AppLink extends StatelessWidget {
  const AppLink({
    super.key,
    required this.text,
    this.onTap,
    this.ink = false,
    this.small = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool ink;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = ink ? c.ink : c.accent;
    return Pressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Center(
            widthFactor: 1,
            child: Text(
              text,
              style: AppTextStyles.s(small ? 14 : 16, 700, color: color)
                  .copyWith(
                decoration: TextDecoration.underline,
                decorationColor: color,
                decorationThickness: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
