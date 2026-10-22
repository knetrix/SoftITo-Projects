import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/extensions/context_extensions.dart';
import 'reader_bottom_bar_widget.dart';

/// Kullanıcının PDF dosyasını orijinal sayfa düzeniyle gösterir; sayfa geçişleri
/// ve kaydırıcı görüntüleyicinin denetleyicisi üzerinden yapılır. Seçilen metin,
/// seçim menüsündeki "Alıntı olarak kaydet" ile [onSaveQuote]'a, "Çevir" ile
/// [onTranslate]'e verilir (PDF kopyalamaya izin vermiyorsa düğmeler
/// gösterilmez; [onTranslate] `null` ise "Çevir" gösterilmez).
class PdfReaderWidget extends StatefulWidget {
  const PdfReaderWidget({
    super.key,
    required this.bytes,
    required this.sourceName,
    required this.initialPage,
    required this.pageIndex,
    required this.pageCount,
    required this.onReady,
    required this.onPageChanged,
    required this.onSaveQuote,
    this.onTranslate,
  });

  final Uint8List bytes;
  final String sourceName;

  /// 0'dan başlayan sayfa sırası.
  final int initialPage;
  final int pageIndex;
  final int pageCount;
  final ValueChanged<int> onReady;

  /// 1'den başlayan sayfa numarası.
  final ValueChanged<int> onPageChanged;

  /// Seçilen metin ve seçimin başladığı (1'den başlayan) sayfa numarası.
  final void Function(String text, int pageNumber) onSaveQuote;
  final void Function(String text, int pageNumber)? onTranslate;

  @override
  State<PdfReaderWidget> createState() => _PdfReaderWidgetState();
}

class _PdfReaderWidgetState extends State<PdfReaderWidget> {
  final PdfViewerController _pdf = PdfViewerController();

  void _jump(int index) {
    if (!_pdf.isReady) return;
    _pdf.goToPage(pageNumber: index.clamp(0, _pdf.pageCount - 1) + 1);
  }

  ContextMenuButtonItem _item(
    PdfViewerContextMenuBuilderParams params,
    String label,
    void Function(String text, int pageNumber) action,
  ) {
    final selection = params.textSelectionDelegate;
    return ContextMenuButtonItem(
      label: label,
      onPressed: () async {
        params.dismissContextMenu();
        final ranges = await selection.getSelectedTextRanges();
        final text = await selection.getSelectedText();
        await selection.clearTextSelection();
        final page = ranges.isNotEmpty ? ranges.first.pageNumber : widget.pageIndex + 1;
        action(text, page);
      },
    );
  }

  void _addMenuItems(PdfViewerContextMenuBuilderParams params, List<ContextMenuButtonItem> items) {
    final selection = params.textSelectionDelegate;
    if (!selection.isCopyAllowed || !selection.hasSelectedText) return;
    final onTranslate = widget.onTranslate;
    items.insertAll(0, [
      if (onTranslate != null) _item(params, context.l10n.readerTranslateSelection, onTranslate),
      _item(params, context.l10n.readerQuoteSave, widget.onSaveQuote),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PdfViewer.data(
            widget.bytes,
            sourceName: widget.sourceName,
            controller: _pdf,
            initialPageNumber: widget.initialPage + 1,
            params: PdfViewerParams(
              onViewerReady: (document, _) => widget.onReady(document.pages.length),
              onPageChanged: (page) {
                if (page != null) widget.onPageChanged(page);
              },
              customizeContextMenuItems: _addMenuItems,
            ),
          ),
        ),
        if (widget.pageCount > 0)
          ReaderBottomBarWidget(
            pageIndex: widget.pageIndex,
            pageCount: widget.pageCount,
            onPrevious: () => _jump(widget.pageIndex - 1),
            onNext: () => _jump(widget.pageIndex + 1),
            onJump: _jump,
          ),
      ],
    );
  }
}
