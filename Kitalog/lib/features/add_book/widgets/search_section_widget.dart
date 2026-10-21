import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/add_book_model.dart';
import 'book_search_bar_widget.dart';
import 'search_message_widget.dart';
import 'search_result_tile_widget.dart';

/// Arama modu: arama kutusu + (yükleniyor | hata | sonuç listesi | ipucu).
class SearchSectionWidget extends StatelessWidget {
  const SearchSectionWidget({
    super.key,
    required this.state,
    required this.onSearch,
    required this.onRetry,
    required this.onSelect,
    required this.onManual,
  });

  final AddBookModel state;
  final ValueChanged<String> onSearch;
  final VoidCallback onRetry;
  final ValueChanged<BookSearchResult> onSelect;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceM),
          child: BookSearchBarWidget(
            isLoading: state.isSearching,
            onSearch: onSearch,
          ),
        ),
        Expanded(
          child: _Body(
            state: state,
            onRetry: onRetry,
            onSelect: onSelect,
            onManual: onManual,
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onRetry,
    required this.onSelect,
    required this.onManual,
  });

  final AddBookModel state;
  final VoidCallback onRetry;
  final ValueChanged<BookSearchResult> onSelect;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return SearchMessageWidget(
        error: state.error!,
        onRetry: onRetry,
        onManual: onManual,
      );
    }
    if (state.results.isEmpty) {
      return EmptyStateView(
        icon: Icons.menu_book_outlined,
        title: context.l10n.addBookSearchEmptyTitle,
        message: context.l10n.addBookSearchEmptyMessage,
      );
    }
    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spaceS),
      itemBuilder: (context, index) {
        final result = state.results[index];
        return SearchResultTileWidget(result: result, onTap: () => onSelect(result));
      },
    );
  }
}
