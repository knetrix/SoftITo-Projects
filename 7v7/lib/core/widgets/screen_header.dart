import 'package:flutter/material.dart';
import 'app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import 'icon_circle_button.dart';

/// Üst çubuk `top`: güvenli alan + 4 üst, 20 yan, 8 alt; 28/900 başlık ve
/// sağda eylemler (ör. bildirim ikonu). Geri butonu varsa solda.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    this.title,
    this.onBack,
    this.actions = const [],
  });

  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 4, 20, 8),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (onBack != null) ...[
              IconCircleButton(
                icon: PhosphorIconsFill.caretLeft,
                semanticLabel: l.back,
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: title == null
                  ? const SizedBox()
                  : Semantics(
                      header: true,
                      child: Text(
                        title!,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title(color: c.ink),
                      ),
                    ),
            ),
            for (final a in actions) ...[const SizedBox(width: 8), a],
          ],
        ),
      ),
    );
  }
}

/// Bölüm başlığı (16/800) + sağda ikincil metin (14 `ink2`).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: AppTextStyles.body(800, color: c.ink)),
        ),
        const SizedBox(width: 12),
        if (trailing != null)
          Expanded(
            child: Text(
              trailing!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySm(400, color: c.ink2, tabular: true),
            ),
          ),
      ],
    );
  }
}

/// Tam ekran (sekme dışı) sayfalarda alt bar iç boşluğu: alt güvenli alan,
/// en az 8.
double bottomInset(BuildContext context) {
  final b = MediaQuery.of(context).padding.bottom;
  return b < 8 ? 8 : b;
}
