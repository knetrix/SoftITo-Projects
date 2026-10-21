import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state_view.dart';

class LibraryEmptyWidget extends StatelessWidget {
  const LibraryEmptyWidget({super.key, required this.isFiltered});

  /// Filtre/arama nedeniyle mi boş, yoksa kitaplık hiç boş mu?
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyStateView(
      icon: isFiltered ? Icons.search_off : Icons.collections_bookmark_outlined,
      title: isFiltered ? l10n.libraryNoResultsTitle : l10n.libraryEmptyTitle,
      message: isFiltered
          ? l10n.libraryNoResultsMessage
          : l10n.libraryEmptyMessage,
    );
  }
}
