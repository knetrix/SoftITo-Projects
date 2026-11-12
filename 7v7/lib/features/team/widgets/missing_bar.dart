import 'package:flutter/material.dart';
import '../../../core/widgets/app_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

/// Eksik bilgi satırı (`miss`): kırmızı, uyarı ikonu 18 + 14/700.
class MissingBar extends StatelessWidget {
  const MissingBar({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(PhosphorIconsFill.warningCircle, size: 18, color: c.error),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.bodySm(700, color: c.error))),
        ],
      ),
    );
  }
}
