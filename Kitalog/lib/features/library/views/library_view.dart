import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/library_shelf_controller.dart';
import '../models/library_shelf_model.dart';
import '../widgets/book_shelf_grid_widget.dart';
import '../widgets/library_empty_widget.dart';
import '../widgets/library_filter_bar_widget.dart';

/// Sekme 1: Kitaplığım (raf görünümü). AppBar ana kabuktadır.
class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  LibraryShelfController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= LibraryShelfController(
      library: AppScope.of(context).libraryController,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addBook),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.libraryAddBook),
      ),
      body: ValueListenableBuilder<LibraryShelfModel>(
        valueListenable: controller.state,
        builder: (context, state, _) => Column(
          children: [
            LibraryFilterBarWidget(
              genre: state.genre,
              status: state.status,
              onQueryChanged: controller.setQuery,
              onGenreChanged: controller.setGenre,
              onStatusChanged: controller.setStatus,
            ),
            Expanded(
              child: state.books.isEmpty
                  ? LibraryEmptyWidget(isFiltered: !state.isLibraryEmpty)
                  : BookShelfGridWidget(
                      books: state.books,
                      onBookTap: (book) => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.bookDetail, arguments: book.id),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
