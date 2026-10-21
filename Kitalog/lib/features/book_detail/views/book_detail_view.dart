import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../controllers/book_detail_controller.dart';
import '../models/book_detail_model.dart';
import '../widgets/book_detail_content_widget.dart';

class BookDetailView extends StatefulWidget {
  const BookDetailView({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  BookDetailController? _controller;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= BookDetailController(
      library: AppScope.of(context).libraryController,
      bookId: widget.bookId,
    )..state.addListener(_onStateChanged);
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

  void _showFinishSuggestion() {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.finishSuggestion),
        action: SnackBarAction(
          label: l10n.markFinished,
          onPressed: () => _controller!.setStatus(ReadingStatus.finished),
        ),
      ),
    );
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
    if (confirmed ?? false) await _controller!.deleteBook();
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
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
                  ),
          ),
        );
      },
    );
  }
}
