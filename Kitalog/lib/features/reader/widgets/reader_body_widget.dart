import 'package:flutter/material.dart';

import '../models/reader_model.dart';
import '../models/reader_translation_model.dart';
import 'pdf_reader_widget.dart';
import 'reader_bottom_bar_widget.dart';
import 'reader_download_widget.dart';
import 'reader_error_widget.dart';
import 'reader_page_widget.dart';
import 'reader_translation_banner_widget.dart';

/// Seçilen metin, sayfa numarası (1'den başlar); PDF'te satırlar birleştirilir ([reflow]).
typedef ReaderSelectionAction = void Function(String text, int pageNumber, {bool reflow});

/// Okuyucu gövdesi: duruma göre indirme, hata veya sayfalı metin gösterir.
class ReaderBodyWidget extends StatelessWidget {
  const ReaderBodyWidget({
    super.key,
    required this.state,
    required this.textScale,
    required this.supportsOffline,
    required this.pageController,
    required this.onDownload,
    required this.onPageChanged,
    required this.onJump,
    required this.onPdfReady,
    required this.onPdfPageChanged,
    required this.onSaveQuote,
    required this.translation,
    required this.onTranslate,
    required this.onTranslationRetry,
  });

  final ReaderModel state;
  final double textScale;
  final bool supportsOffline;
  final PageController? pageController;
  final VoidCallback onDownload;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onJump;
  final ValueChanged<int> onPdfReady;
  final ValueChanged<int> onPdfPageChanged;
  final ReaderSelectionAction onSaveQuote;
  final ReaderTranslationModel translation;

  /// `null` ise (çeviri yok) seçim menüsünde "Çevir" gösterilmez.
  final ReaderSelectionAction? onTranslate;
  final VoidCallback onTranslationRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      ReaderStatus.loading => const Center(child: CircularProgressIndicator()),
      ReaderStatus.notDownloaded || ReaderStatus.downloading => ReaderDownloadWidget(
        isDownloading: state.status == ReaderStatus.downloading,
        progress: state.downloadProgress,
        supportsOffline: supportsOffline,
        onDownload: onDownload,
      ),
      ReaderStatus.failure => ReaderErrorWidget(error: state.error, onRetry: onDownload),
      ReaderStatus.ready when state.isPdf => PdfReaderWidget(
        bytes: state.pdfBytes!,
        sourceName: 'kitalog-pdf',
        initialPage: state.pageIndex,
        pageIndex: state.pageIndex,
        pageCount: state.pdfPageCount,
        onReady: onPdfReady,
        onPageChanged: onPdfPageChanged,
        onSaveQuote: (text, page) => onSaveQuote(text, page, reflow: true),
        onTranslate: onTranslate == null ? null : (text, page) => onTranslate!(text, page, reflow: true),
      ),
      ReaderStatus.ready => _TextReader(
        state: state,
        textScale: textScale,
        pageController: pageController,
        onPageChanged: onPageChanged,
        onJump: onJump,
        onSaveQuote: onSaveQuote,
        translation: translation,
        onTranslate: onTranslate,
        onTranslationRetry: onTranslationRetry,
      ),
    };
  }
}

/// Metin okuyucu: üstte çeviri durumu, ortada sayfalar, altta sayfa çubuğu.
class _TextReader extends StatelessWidget {
  const _TextReader({
    required this.state,
    required this.textScale,
    required this.pageController,
    required this.onPageChanged,
    required this.onJump,
    required this.onSaveQuote,
    required this.translation,
    required this.onTranslate,
    required this.onTranslationRetry,
  });

  final ReaderModel state;
  final double textScale;
  final PageController? pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onJump;
  final ReaderSelectionAction onSaveQuote;
  final ReaderTranslationModel translation;
  final ReaderSelectionAction? onTranslate;
  final VoidCallback onTranslationRetry;

  @override
  Widget build(BuildContext context) {
    final translate = onTranslate;
    return Column(
      children: [
        ReaderTranslationBannerWidget(
          translation: translation,
          pageIndex: state.pageIndex,
          onRetry: onTranslationRetry,
        ),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: state.pageCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) => ReaderPageWidget(
              text: state.pages[index].text,
              textScale: textScale,
              onSaveQuote: (text) => onSaveQuote(text, index + 1),
              view: translation.view,
              translatedLines: translation.pages[index],
              onTranslate: translate == null ? null : (text) => translate(text, index + 1),
            ),
          ),
        ),
        ReaderBottomBarWidget(
          pageIndex: state.pageIndex,
          pageCount: state.pageCount,
          onPrevious: () => onJump(state.pageIndex - 1),
          onNext: () => onJump(state.pageIndex + 1),
          onJump: onJump,
        ),
      ],
    );
  }
}
