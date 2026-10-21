import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/reading_status_controller.dart';
import '../models/reading_status_model.dart';
import '../widgets/status_book_list_widget.dart';

/// Sekme 2: Okunuyor / Okunacak / Bitti. AppBar ana kabuktadır.
class ReadingStatusView extends StatefulWidget {
  const ReadingStatusView({super.key});

  @override
  State<ReadingStatusView> createState() => _ReadingStatusViewState();
}

class _ReadingStatusViewState extends State<ReadingStatusView> {
  ReadingStatusController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= ReadingStatusController(
      library: AppScope.of(context).libraryController,
    )..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final bookId = _controller!.state.value.finishSuggestedBookId;
    if (bookId == null || !mounted) return;
    _controller!.consumeFinishSuggestion();
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.finishSuggestion),
        action: SnackBarAction(
          label: l10n.markFinished,
          onPressed: () => _controller!.markFinished(bookId),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _openDetail(BookModel book) {
    Navigator.of(context).pushNamed(AppRoutes.bookDetail, arguments: book.id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return DefaultTabController(
      length: ReadingStatus.values.length,
      child: ValueListenableBuilder<ReadingStatusModel>(
        valueListenable: controller.state,
        builder: (context, state, _) => Column(
          children: [
            TabBar(
              tabs: [
                for (final status in _tabOrder)
                  Tab(
                    text: context.l10n.readingTabLabel(
                      status.label(context.l10n),
                      state.booksFor(status).length,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final status in _tabOrder)
                    StatusBookListWidget(
                      status: status,
                      books: state.booksFor(status),
                      onBookTap: _openDetail,
                      onChangePage: (book, delta) =>
                          controller.changePage(book.id, delta),
                      onStartReading: (book) => controller.startReading(book.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<ReadingStatus> _tabOrder = [
    ReadingStatus.reading,
    ReadingStatus.toRead,
    ReadingStatus.finished,
  ];
}
