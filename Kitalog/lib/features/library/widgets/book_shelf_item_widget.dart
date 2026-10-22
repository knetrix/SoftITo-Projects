import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/book_cover_image.dart';
import 'book_badges_widget.dart';

/// Rafta tek bir kitap: kapak, biçim rozetleri (Fiziksel / Ödünçte / Dijital), başlık ve yazar.
class BookShelfItemWidget extends StatelessWidget {
  const BookShelfItemWidget({super.key, required this.book, required this.onTap});

  final BookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ShelfCover(book: book)),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelLarge,
          ),
          Text(
            book.authorsLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ShelfCover extends StatelessWidget {
  const _ShelfCover({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BookCoverImage(
          title: book.title,
          genre: book.genre,
          custom: context.customGenreOf(book),
          coverUrl: book.coverUrl,
        ),
        Positioned(
          top: AppSizes.spaceS,
          right: AppSizes.spaceS,
          child: BookBadgesWidget(book: book),
        ),
      ],
    );
  }
}
