import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/quote_model.dart';
import 'quote_dialog.dart';
import 'quote_tile_widget.dart';
import 'section_card_widget.dart';

/// Alıntı listesi (favoriler önce) ve alıntı ekleme.
class QuotesSectionWidget extends StatelessWidget {
  const QuotesSectionWidget({
    super.key,
    required this.quotes,
    required this.pageCount,
    required this.onAdd,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final List<QuoteModel> quotes;
  final int pageCount;
  final void Function(String text, int? page) onAdd;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<String> onDelete;

  List<QuoteModel> get _sorted {
    final favorites = quotes.where((q) => q.isFavorite);
    final others = quotes.where((q) => !q.isFavorite);
    return [...favorites, ...others];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _sorted;
    return SectionCardWidget(
      title: l10n.quotesSectionTitle,
      trailing: IconButton(
        tooltip: l10n.quoteAdd,
        icon: const Icon(Icons.add_comment_outlined),
        onPressed: () async {
          final input = await QuoteDialog.show(context, pageCount: pageCount);
          if (input != null) onAdd(input.text, input.page);
        },
      ),
      child: items.isEmpty
          ? Text(l10n.quotesEmpty, style: context.textTheme.bodyMedium)
          : Column(
              children: [
                for (final quote in items) ...[
                  QuoteTileWidget(
                    key: ValueKey(quote.id),
                    quote: quote,
                    onToggleFavorite: () => onToggleFavorite(quote.id),
                    onDelete: () => onDelete(quote.id),
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                ],
              ],
            ),
    );
  }
}
