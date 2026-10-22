import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/reader_translation_model.dart';
import 'reader_page_text_widget.dart';

/// Tek bir okuma sayfası. Yazı boyutu `TextScaler` ile uygulanır; sayfa kendi
/// içinde kaydırılabildiği için büyük yazıda (ve çeviri alt alta gösterilince)
/// taşma olmaz. Seçilen metin, seçim menüsündeki "Alıntı olarak kaydet" ile
/// [onSaveQuote]'a, "Çevir" ile [onTranslate]'e verilir ([onTranslate] `null`
/// ise çeviri düğmesi gösterilmez).
class ReaderPageWidget extends StatefulWidget {
  const ReaderPageWidget({
    super.key,
    required this.text,
    required this.textScale,
    required this.onSaveQuote,
    this.view = TranslationView.original,
    this.translatedLines,
    this.onTranslate,
  });

  final String text;
  final double textScale;
  final ValueChanged<String> onSaveQuote;
  final TranslationView view;
  final List<String>? translatedLines;
  final ValueChanged<String>? onTranslate;

  @override
  State<ReaderPageWidget> createState() => _ReaderPageWidgetState();
}

class _ReaderPageWidgetState extends State<ReaderPageWidget> {
  /// Yalnızca menü düğmesinin okuduğu yerel seçim; arayüzü yeniden çizmez.
  String _selected = '';

  ContextMenuButtonItem _item(SelectableRegionState region, String label, ValueChanged<String> action) {
    final selected = _selected;
    return ContextMenuButtonItem(
      label: label,
      onPressed: () {
        region.hideToolbar();
        region.clearSelection();
        action(selected);
      },
    );
  }

  Widget _buildMenu(BuildContext context, SelectableRegionState region) {
    final hasSelection = _selected.trim().isNotEmpty;
    final onTranslate = widget.onTranslate;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: region.contextMenuAnchors,
      buttonItems: [
        // "Çevir" kısa olduğu için önde; dar ekranda "Diğer" altına düşmez.
        if (hasSelection && onTranslate != null)
          _item(region, context.l10n.readerTranslateSelection, onTranslate),
        if (hasSelection) _item(region, context.l10n.readerQuoteSave, widget.onSaveQuote),
        ...region.contextMenuButtonItems,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(media.textScaler.scale(1) * widget.textScale),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceXl,
          AppSizes.spaceL,
          AppSizes.spaceXl,
          AppSizes.spaceXl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.readerMaxWidth),
            child: SelectionArea(
              onSelectionChanged: (content) => _selected = content?.plainText ?? '',
              contextMenuBuilder: _buildMenu,
              child: ReaderPageTextWidget(
                text: widget.text,
                view: widget.view,
                translatedLines: widget.translatedLines,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
