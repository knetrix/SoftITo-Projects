import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/repositories/translation/translation_engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/reader_translation_model.dart';

/// Metin sayfasının üstünde çeviri durumu: dil paketi indiriliyor, sayfa
/// çevriliyor veya hata (tekrar dene). Gösterilen sayfanın çevirisi hazırsa
/// ya da orijinal görünümdeyken hiçbir şey çizmez.
class ReaderTranslationBannerWidget extends StatelessWidget {
  const ReaderTranslationBannerWidget({
    super.key,
    required this.translation,
    required this.pageIndex,
    required this.onRetry,
  });

  final ReaderTranslationModel translation;
  final int pageIndex;
  final VoidCallback onRetry;

  TranslationFailure? get _failure =>
      translation.status == TranslationStatus.failure ? translation.failure : null;

  /// Gösterilecek mesaj; bant gerekmiyorsa `null`.
  String? _message(AppLocalizations l10n) {
    if (!translation.showsTranslation || translation.modelPromptPending) return null;
    if (translation.status == TranslationStatus.downloadingModel) return l10n.readerTranslationDownloading;
    return switch (_failure) {
      TranslationFailure.modelDownload || TranslationFailure.downloadDeclined => l10n.readerTranslationErrorModel,
      TranslationFailure.translate => l10n.readerTranslationErrorTranslate,
      null => translation.pages.containsKey(pageIndex) ? null : l10n.readerTranslationTranslating,
    };
  }

  @override
  Widget build(BuildContext context) {
    final message = _message(context.l10n);
    if (message == null) return const SizedBox.shrink();
    final failed = _failure != null;
    return Material(
      color: context.colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL, vertical: AppSizes.spaceS),
        // "Tekrar dene" mesajın altında: dar ekranda ve büyük yazıda satırı taşırmaz.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              spacing: AppSizes.spaceM,
              children: [
                if (failed)
                  Icon(Icons.error_outline, size: AppSizes.iconS, color: context.colors.error)
                else
                  const SizedBox.square(
                    dimension: AppSizes.iconS,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                Expanded(child: Text(message, style: context.textTheme.bodySmall)),
              ],
            ),
            if (failed) TextButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
