import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'loan_cover_widget.dart';

/// Alttan açılan "Ödünç verilecek kitabı seç" paneli: yalnızca fiziksel
/// kopyası olan ve ödünçte olmayan kitaplar, başlık / yazar aramasıyla.
/// Seçilen kitap döner; vazgeçilirse `null`.
class LendBookSheet extends StatefulWidget {
  const LendBookSheet({super.key, required this.books});

  final List<BookModel> books;

  static Future<BookModel?> show(BuildContext context, {required List<BookModel> books}) {
    return showModalBottomSheet<BookModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => LendBookSheet(books: books),
    );
  }

  @override
  State<LendBookSheet> createState() => _LendBookSheetState();
}

class _LendBookSheetState extends State<LendBookSheet> {
  final ValueNotifier<String> _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<BookModel> _filter(String query) {
    final q = foldForSearch(query);
    if (q.isEmpty) return widget.books;
    return widget.books
        .where((b) => foldForSearch(b.title).contains(q) || b.authors.any((a) => foldForSearch(a).contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, 0, AppSizes.spaceL, AppSizes.spaceS),
              child: Text(l10n.loansPickBookTitle, style: context.textTheme.titleLarge),
            ),
            if (widget.books.isEmpty)
              Flexible(
                child: EmptyStateView(icon: Icons.menu_book_outlined, title: l10n.loansNoLendableTitle, message: l10n.loansNoLendableMessage),
              )
            else ...[
              _SearchField(onChanged: (v) => _query.value = v),
              Flexible(
                child: ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, query, _) => _BookList(books: _filter(query)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL, vertical: AppSizes.spaceS),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: context.l10n.librarySearchHint, prefixIcon: const Icon(Icons.search)),
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXl),
        child: Text(context.l10n.libraryNoResultsTitle, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSizes.spaceL),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: LoanCoverWidget(book: book, width: AppSizes.loanHistoryCoverWidth),
          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(book.authorsLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => Navigator.of(context).pop(book),
        );
      },
    );
  }
}
