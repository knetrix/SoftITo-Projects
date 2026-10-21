import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/digital_format.dart';
import '../controllers/reader_controller.dart';
import '../models/reader_model.dart';
import '../widgets/reader_body_widget.dart';
import '../widgets/reader_settings_sheet.dart';

/// Dijital okuyucu. Sayfa geçişleri tek yoldan yönetilir: düğmeler ve kaydırıcı
/// `PageController`'ı hareket ettirir, `onPageChanged` controller'ı günceller.
class ReaderView extends StatefulWidget {
  const ReaderView({super.key, required this.bookId});

  final String bookId;

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  ReaderController? _controller;
  PageController? _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final scope = AppScope.of(context);
    _controller = ReaderController(
      library: scope.libraryController,
      digital: scope.digitalBookRepository,
      bookId: widget.bookId,
    )..state.addListener(_onStateChanged);
    _controller!.open();
  }

  void _onStateChanged() {
    final state = _controller!.state.value;
    if (state.status == ReaderStatus.ready && !state.isPdf && _pages == null) {
      _pages = PageController(initialPage: state.pageIndex);
    }
    if (state.finishSuggested && mounted) {
      _controller!.consumeFinishSuggestion();
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.finishSuggestion),
          action: SnackBarAction(label: l10n.markFinished, onPressed: _controller!.markFinished),
        ),
      );
    }
  }

  void _jump(int index) {
    final pages = _pages;
    if (pages == null || !pages.hasClients) return;
    pages.jumpToPage(index.clamp(0, _controller!.state.value.pageCount - 1));
  }

  void _openSettings() {
    final settings = AppScope.of(context).settingsController;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ValueListenableBuilder(
        valueListenable: settings.state,
        builder: (_, value, _) => ReaderSettingsSheet(
          textScale: value.readerTextScale,
          onChanged: settings.setReaderTextScale,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = _controller!;
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.book?.title ?? context.l10n.readerTitle),
        // PDF kendi sayfa düzeniyle (yakınlaştırarak) okunur; yazı boyutu yalnızca metinde.
        actions: [
          if (controller.book?.digitalEdition?.format != DigitalFormat.pdf)
            IconButton(
              tooltip: context.l10n.readerTextSize,
              icon: const Icon(Icons.format_size),
              onPressed: _openSettings,
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([controller.state, scope.settingsController.state]),
        builder: (context, _) => ReaderBodyWidget(
          state: controller.state.value,
          textScale: scope.settingsController.state.value.readerTextScale,
          supportsOffline: controller.supportsOffline,
          pageController: _pages,
          onDownload: controller.download,
          onPageChanged: controller.goToPage,
          onJump: _jump,
          onPdfReady: controller.pdfReady,
          onPdfPageChanged: controller.pdfPageChanged,
        ),
      ),
    );
  }
}
