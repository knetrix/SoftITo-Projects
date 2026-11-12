import 'package:flutter/material.dart';

import '../../../core/widgets/app_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_link.dart';

/// "Hesabın yok mu? Hesap oluştur" satırı (`swap`).
class SwapRow extends StatelessWidget {
  const SwapRow({
    super.key,
    required this.text,
    required this.link,
    required this.onTap,
  });
  final String text;
  final String link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(text, style: AppTextStyles.body(400, color: c.ink2)),
        AppLink(text: link, onTap: onTap),
      ],
    );
  }
}

/// Onay kutusu (`chk`): 44×44 dokunma alanı, 22 px kutu, sola -10 kaydırılmış.
class AgreeCheck extends StatelessWidget {
  const AgreeCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    required this.linkText,
    required this.suffix,
    required this.onLink,
    this.error,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;
  final String linkText;
  final String suffix;
  final VoidCallback onLink;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // `.chk{margin-left:-10px}`: 44'lük dokunma alanı 10 px sola taşar, kutu
    // metin hizasında durur. Negatif boşluk yerine tüm satır kaydırılır.
    return Transform.translate(
      offset: const Offset(-10, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            checked: value,
            label: semanticLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(!value),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: value ? c.team : c.card,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: value ? c.team : c.ink2,
                        width: 1.5,
                      ),
                    ),
                    child: value
                        ? Icon(
                            PhosphorIconsFill.check,
                            size: 16,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    AppLink(
                      text: linkText,
                      ink: true,
                      small: true,
                      onTap: onLink,
                    ),
                    Text(
                      suffix,
                      style: AppTextStyles.bodySm(400, color: c.ink2),
                    ),
                  ],
                ),
                ?error,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
