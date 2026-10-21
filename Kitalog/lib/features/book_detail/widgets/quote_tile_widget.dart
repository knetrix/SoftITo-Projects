import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/quote_model.dart';

class QuoteTileWidget extends StatelessWidget {
  const QuoteTileWidget({
    super.key,
    required this.quote,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final QuoteModel quote;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.colors.primary, width: 3),
        ),
        color: context.colors.surfaceContainerHigh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“${quote.text}”',
            style: context.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          _QuoteActions(
            quote: quote,
            onToggleFavorite: onToggleFavorite,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class _QuoteActions extends StatelessWidget {
  const _QuoteActions({
    required this.quote,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final QuoteModel quote;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        if (quote.page != null)
          Text(l10n.quotePageLabel(quote.page!), style: context.textTheme.bodySmall),
        const Spacer(),
        IconButton(
          tooltip: quote.isFavorite ? l10n.quoteUnfavorite : l10n.quoteFavorite,
          onPressed: onToggleFavorite,
          icon: Icon(
            quote.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: quote.isFavorite ? AppColors.genreNovel : null,
          ),
        ),
        IconButton(
          tooltip: l10n.quoteDelete,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
