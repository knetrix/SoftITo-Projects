import 'package:flutter/material.dart';
import '../../../core/widgets/app_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';

enum LegalKind { terms, kvkk }

/// Paneller `terms` / `kvkk`: örnek metin uyarısı + 3 paragraf +
/// "Okudum, onaylıyorum" (kutuyu işaretler) + Vazgeç. Onayda `true` döner.
Future<bool> showLegalSheet(BuildContext context, LegalKind kind) async {
  final r = await showAppSheet<bool>(
    context,
    builder: (ctx) {
      final c = ctx.c;
      final l = AppLocalizations.of(ctx);
      final paras = kind == LegalKind.terms
          ? [l.termsP1, l.termsP2, l.termsP3]
          : [l.kvkkP1, l.kvkkP2, l.kvkkP3];
      return SheetBody(children: [
        SheetTitle(kind == LegalKind.terms ? l.agreeTermsA : l.agreeKvkkA),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsFill.warningCircle, size: 20, color: c.ink2),
              const SizedBox(width: 8),
              Expanded(child: Text(l.legalNote, style: AppTextStyles.bodySm(600, color: c.ink))),
            ],
          ),
        ),
        for (final p in paras)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(p, style: AppTextStyles.body(400, color: c.ink)),
          ),
        AppButton(label: l.legalOk, wide: true, onPressed: () => Navigator.of(ctx).pop(true)),
        AppButton(
          label: l.cancel,
          variant: AppButtonVariant.alt,
          wide: true,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ]);
    },
  );
  return r ?? false;
}
