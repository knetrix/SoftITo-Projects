import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/finish_book_dialog.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/book_detail_controller.dart';
import '../controllers/book_file_picker.dart';
import '../controllers/digital_edition_controller.dart';
import '../models/book_detail_model.dart';
import '../widgets/book_detail_content_widget.dart';
import '../widgets/digital_edition_section_widget.dart';

class BookDetailView extends StatefulWidget {
  const BookDetailView({super.key, required this.bookId, this.filePicker});

  final String bookId;

  /// Testlerde sahte dosya seçici vermek için.
  final BookFilePicker? filePicker;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  BookDetailController? _controller;
  DigitalEditionController? _digital;
  bool _closing = false;
  bool _finishDialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final scope = AppScope.of(context);
    _controller = BookDetailController(
      library: scope.libraryController,
      bookId: widget.bookId,
      digital: scope.digitalBookRepository,
    )..state.addListener(_onStateChanged);
    _digital = DigitalEditionController(
      library: scope.libraryController,
      digital: scope.digitalBookRepository,
      translation: scope.translationRepository,
      picker: widget.filePicker ?? const PlatformBookFilePicker(),
      bookId: widget.bookId,
    )..load();
  }

  void _onStateChanged() {
    final state = _controller!.state.value;
    if (!mounted) return;
    if (state.finishSuggested) {
      _controller!.consumeFinishSuggestion();
      _showFinishSuggestion();
    }
    if (state.isMissing && !_closing) {
      _closing = true;
      Navigator.of(context).maybePop();
    }
  }

  /// Son sayfaya ulaşılınca "Bitti olarak işaretle" düğmesinin açtığı onay
  /// kendiliğinden açılır; aynı anda yalnızca bir pencere gösterilir.
  Future<void> _showFinishSuggestion() async {
    if (_finishDialogOpen) return;
    _finishDialogOpen = true;
    final ok = await FinishBookDialog.show(context, reachedEnd: true);
    _finishDialogOpen = false;
    if (ok && mounted) await _controller!.setStatus(ReadingStatus.finished);
  }

  Future<void> _confirmDelete(String title) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBookTitle),
        content: Text(l10n.deleteBookMessage(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      // Cihazdaki dijital kopya da silinir; aksi halde dosya sahipsiz kalır.
      await _digital!.deleteCopy();
      await _controller!.deleteBook();
    }
  }

  /// Okuyucudan dönünce kalınan yer ve indirme durumu yenilenir.
  Future<void> _openReader() async {
    await Navigator.of(context).pushNamed(AppRoutes.reader, arguments: widget.bookId);
    await _digital?.load();
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    _digital?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ValueListenableBuilder<BookDetailModel>(
      valueListenable: controller.state,
      builder: (context, state, _) {
        final book = state.book;
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.bookDetailTitle),
            actions: [
              if (book != null)
                IconButton(
                  tooltip: context.l10n.deleteBook,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(book.title),
                ),
            ],
          ),
          body: SafeArea(
            child: book == null
                ? EmptyStateView(
                    icon: Icons.menu_book_outlined,
                    title: context.l10n.bookNotFound,
                  )
                : BookDetailContentWidget(
                    state: state,
                    actions: controller.actions,
                    digitalSection: DigitalEditionSectionWidget(
                      book: book,
                      state: _digital!.state,
                      actions: _digital!.actions,
                      onRead: _openReader,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
