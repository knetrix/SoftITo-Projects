import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/book_cover_image.dart';
import '../../../core/widgets/genre_chip.dart';

/// Kapak ve künye: başlık, yazar, tür etiketi, ISBN, sayfa sayısı.
class BookHeaderWidget extends StatelessWidget {
  const BookHeaderWidget({super.key, required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: AspectRatio(
            aspectRatio: AppSizes.coverAspectRatio,
            child: BookCoverImage(
              title: book.title,
              genre: book.genre,
              custom: context.customGenreOf(book),
              coverUrl: book.coverUrl,
              borderRadius: AppSizes.radiusM,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spaceL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: context.textTheme.titleLarge),
              const SizedBox(height: AppSizes.spaceXs),
              Text(
                book.authors.isEmpty ? l10n.authorUnknown : book.authorsLabel,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.spaceM),
              GenreChip(genre: book.genre, custom: context.customGenreOf(book)),
              const SizedBox(height: AppSizes.spaceM),
              BookMetaInfoWidget(book: book),
            ],
          ),
        ),
      ],
    );
  }
}

class BookMetaInfoWidget extends StatelessWidget {
  const BookMetaInfoWidget({super.key, required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isbn = book.isbn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.bookPageCount(book.pageCount), style: context.textTheme.bodySmall),
        if (isbn != null) Text(l10n.bookIsbn(isbn), style: context.textTheme.bodySmall),
        Text(
          book.isOwned ? l10n.bookOwned : l10n.bookNotOwned,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}
