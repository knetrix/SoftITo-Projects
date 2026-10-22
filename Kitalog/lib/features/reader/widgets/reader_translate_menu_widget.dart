import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/reader_translation_model.dart';

/// Üst çubuktaki çeviri düğmesi: orijinal, çeviri veya alt alta görünüm.
/// Çeviri sunulamıyorsa (platform / kitabın dili) hiçbir şey çizmez.
class ReaderTranslateMenuWidget extends StatelessWidget {
  const ReaderTranslateMenuWidget({
    super.key,
    required this.translation,
    required this.onSelected,
  });

  final ValueListenable<ReaderTranslationModel> translation;
  final ValueChanged<TranslationView> onSelected;

  static Map<TranslationView, String> _labels(
    AppLocalizations l10n,
    String? target,
  ) => {
    TranslationView.original: l10n.readerTranslationOriginal,
    TranslationView.translation: target == 'tr'
        ? l10n.readerTranslationTurkish
        : l10n.readerTranslationEnglish,
    TranslationView.both: l10n.readerTranslationBoth,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: translation,
      builder: (context, value, _) {
        if (!value.isAvailable) return const SizedBox.shrink();
        final view = value.view;
        return PopupMenuButton<TranslationView>(
          tooltip: context.l10n.readerTranslate,
          // Çeviri açıkken simge vurgulanır.
          icon: Icon(
            Icons.translate,
            color: view == TranslationView.original
                ? null
                : context.colors.primary,
          ),
          initialValue: view,
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final entry in _labels(
              context.l10n,
              value.targetLanguage,
            ).entries)
              CheckedPopupMenuItem<TranslationView>(
                value: entry.key,
                checked: entry.key == view,
                child: Text(entry.value),
              ),
          ],
        );
      },
    );
  }
}
