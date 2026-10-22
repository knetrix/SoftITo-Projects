import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/repositories/translation/translation_engine.dart';
import '../models/reader_translation_model.dart';

/// Seçilen metnin çevirisi (alt panel): seçilen metin, çevirisi, "Kopyala" ve
/// seçilen (orijinal) metni "Alıntı olarak kaydet". İki düğme de pencereyi kapatır.
class ReaderTranslationSheet extends StatelessWidget {
  const ReaderTranslationSheet({
    super.key,
    required this.selection,
    required this.onSaveQuote,
    required this.onRetry,
  });

  final SelectionTranslation? selection;
  final VoidCallback onSaveQuote;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final current = selection;
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceL,
          0,
          AppSizes.spaceL,
          AppSizes.spaceL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizes.spaceM,
          children: [
            Text(l10n.readerTranslate, style: context.textTheme.titleMedium),
            if (current != null) ...[
              Text(
                current.text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
              _TranslationResult(selection: current, onRetry: onRetry),
              Text(
                l10n.readerTranslationNote,
                style: context.textTheme.labelSmall,
              ),
              _TranslationActions(selection: current, onSaveQuote: onSaveQuote),
            ],
          ],
        ),
      ),
    );
  }
}

class _TranslationResult extends StatelessWidget {
  const _TranslationResult({required this.selection, required this.onRetry});

  final SelectionTranslation selection;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = selection.failure;
    if (selection.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (failure != null) {
      // "Tekrar dene" alt satırda: dar ekranda ve büyük yazıda mesajı sıkıştırmaz.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            spacing: AppSizes.spaceS,
            children: [
              Icon(Icons.error_outline, color: context.colors.error),
              Expanded(
                child: Text(
                  failure == TranslationFailure.modelDownload
                      ? l10n.readerTranslationErrorModel
                      : l10n.readerTranslationErrorTranslate,
                ),
              ),
            ],
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      );
    }
    return SelectableText(
      selection.translated ?? '',
      style: context.textTheme.bodyLarge,
    );
  }
}

class _TranslationActions extends StatelessWidget {
  const _TranslationActions({
    required this.selection,
    required this.onSaveQuote,
  });

  final SelectionTranslation selection;
  final VoidCallback onSaveQuote;

  /// Kopyalayınca pencere kapanır; bilgi mesajı pencerenin arkasında kalmasın diye.
  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final message = context.l10n.readerTranslationCopied;
    await Clipboard.setData(ClipboardData(text: text));
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final translated = selection.translated;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSizes.spaceS,
      runSpacing: AppSizes.spaceS,
      children: [
        OutlinedButton.icon(
          onPressed: onSaveQuote,
          icon: const Icon(Icons.format_quote),
          label: Text(l10n.readerQuoteSave),
        ),
        FilledButton.icon(
          onPressed: translated == null || translated.isEmpty
              ? null
              : () => _copy(context, translated),
          icon: const Icon(Icons.copy),
          label: Text(l10n.readerTranslationCopy),
        ),
      ],
    );
  }
}
