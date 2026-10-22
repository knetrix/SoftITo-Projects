import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/digital_format.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/finish_book_dialog.dart';
import '../controllers/reader_controller.dart';
import '../controllers/reader_translation_controller.dart';
import '../models/reader_model.dart';
import '../widgets/reader_app_bar_widget.dart';
import '../widgets/reader_body_widget.dart';
import '../widgets/reader_settings_sheet.dart';
import '../widgets/reader_translation_sheet.dart';

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
  ReaderTranslationController? _translation;
  PageController? _pages;
  bool _finishDialogOpen = false;
  bool _modelDialogOpen = false;
  bool _selectionSheetOpen = false;

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
    _translation = ReaderTranslationController(
      library: scope.libraryController,
      digital: scope.digitalBookRepository,
      translation: scope.translationRepository,
      reader: _controller!.state,
      bookId: widget.bookId,
    )..state.addListener(_onTranslationChanged);
    _translation!.init();
    _controller!.open();
  }

  void _onTranslationChanged() {
    if (_translation!.state.value.modelPromptPending && mounted) _promptModelDownload();
  }

  /// İlk çeviriden önce dil paketinin (bir kez) indirilmesi için onay alınır.
  /// Reddedilirse açık olan seçim çevirisi penceresi de kapanır.
  Future<void> _promptModelDownload() async {
    if (_modelDialogOpen) return;
    _modelDialogOpen = true;
    final l10n = context.l10n;
    final ok = await ConfirmDialog.show(
      context,
      title: l10n.readerTranslationModelTitle,
      message: l10n.readerTranslationModelMessage,
      confirmLabel: l10n.readerTranslationModelDownload,
      icon: Icons.translate,
    );
    _modelDialogOpen = false;
    if (!mounted) return;
    if (!ok && _selectionSheetOpen) Navigator.of(context).pop();
    await _translation!.confirmModelDownload(ok);
  }

  /// Seçilen metnin çevirisi alttan açılan pencerede gösterilir.
  void _translateSelection(String text, int pageNumber, {bool reflow = false}) {
    final translation = _translation!;
    translation.translateSelection(text, pageNumber, reflow: reflow);
    if (_selectionSheetOpen || translation.state.value.selection == null) return;
    _selectionSheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => ValueListenableBuilder(
        valueListenable: translation.state,
        builder: (_, value, _) => ReaderTranslationSheet(
          selection: value.selection,
          onRetry: translation.retrySelection,
          onSaveQuote: () {
            final selection = value.selection;
            Navigator.of(sheetContext).pop();
            if (selection == null) return;
            _controller!.saveQuote(selection.text, selection.pageNumber, reflow: selection.reflow);
          },
        ),
      ),
    ).whenComplete(() {
      _selectionSheetOpen = false;
      _translation?.clearSelection();
    });
  }

  void _onStateChanged() {
    final state = _controller!.state.value;
    if (state.status == ReaderStatus.ready && !state.isPdf && _pages == null) {
      _pages = PageController(initialPage: state.pageIndex);
    }
    if (state.finishSuggested && mounted) {
      _controller!.consumeFinishSuggestion();
      _confirmFinish();
    }
    final quoteResult = state.quoteResult;
    if (quoteResult != null && mounted) {
      _controller!.consumeQuoteResult();
      final l10n = context.l10n;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(switch (quoteResult) {
              QuoteSaveResult.saved => l10n.readerQuoteSaved,
              QuoteSaveResult.duplicate => l10n.readerQuoteDuplicate,
            }),
          ),
        );
    }
  }

  /// Son sayfaya ulaşılınca "Kitabı bitirdin mi?" onayı açılır (Kitap Detay ile aynı pencere).
  Future<void> _confirmFinish() async {
    if (_finishDialogOpen) return;
    _finishDialogOpen = true;
    final ok = await FinishBookDialog.show(context, reachedEnd: true);
    _finishDialogOpen = false;
    if (ok && mounted) await _controller!.markFinished();
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
    _translation?.state.removeListener(_onTranslationChanged);
    _translation?.dispose();
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = _controller!;
    final translation = _translation!;
    return Scaffold(
      appBar: ReaderAppBarWidget(
        title: controller.book?.title ?? context.l10n.readerTitle,
        isPdf: controller.book?.digitalEdition?.format == DigitalFormat.pdf,
        translation: translation.state,
        onTranslationView: translation.setView,
        onTextSize: _openSettings,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([controller.state, scope.settingsController.state, translation.state]),
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
          onSaveQuote: controller.saveQuote,
          translation: translation.state.value,
          onTranslate: translation.state.value.isAvailable ? _translateSelection : null,
          onTranslationRetry: translation.retry,
        ),
      ),
    );
  }
}
