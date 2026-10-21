import 'package:flutter/material.dart';

import '../models/reader_model.dart';
import 'pdf_reader_widget.dart';
import 'reader_bottom_bar_widget.dart';
import 'reader_download_widget.dart';
import 'reader_error_widget.dart';
import 'reader_page_widget.dart';

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
      ),
      ReaderStatus.ready => _TextReader(
        state: state,
        textScale: textScale,
        pageController: pageController,
        onPageChanged: onPageChanged,
        onJump: onJump,
      ),
    };
  }
}

class _TextReader extends StatelessWidget {
  const _TextReader({
    required this.state,
    required this.textScale,
    required this.pageController,
    required this.onPageChanged,
    required this.onJump,
  });

  final ReaderModel state;
  final double textScale;
  final PageController? pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: state.pageCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) => ReaderPageWidget(
              text: state.pages[index].text,
              textScale: textScale,
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
