import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/widgets/genre_chip.dart';
import '../../../core/widgets/rating_stars.dart';
import 'book_card_layout_widget.dart';

/// "Okunacak" ve "Bitti" listelerinin kartı.
class SimpleBookCardWidget extends StatelessWidget {
  const SimpleBookCardWidget({
    super.key,
    required this.book,
    required this.onTap,
    this.onStartReading,
  });

  final BookModel book;
  final VoidCallback onTap;

  /// Yalnızca "Okunacak" kartlarında verilir.
  final VoidCallback? onStartReading;

  @override
  Widget build(BuildContext context) {
    return BookCardLayoutWidget(
      book: book,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GenreChip(genre: book.genre, custom: context.customGenreOf(book)),
          const SizedBox(height: AppSizes.spaceS),
          if (book.status == ReadingStatus.finished)
            _FinishedInfo(book: book)
          else
            Text(
              context.l10n.bookPageCount(book.pageCount),
              style: context.textTheme.bodySmall,
            ),
          if (onStartReading != null) ...[
            const SizedBox(height: AppSizes.spaceS),
            FilledButton.tonal(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: onStartReading,
              child: Text(context.l10n.startReading),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinishedInfo extends StatelessWidget {
  const _FinishedInfo({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final finishedAt = book.finishedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RatingStars(rating: book.rating, size: AppSizes.iconS + 2),
        if (finishedAt != null)
          Text(
            context.l10n.finishedAtLabel(context.formatDate(finishedAt)),
            style: context.textTheme.bodySmall,
          ),
      ],
    );
  }
}
