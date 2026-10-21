import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/book_cover_image.dart';

/// Kitap kartlarının ortak iskeleti: kapak + başlık/yazar + özel içerik (`child`).
class BookCardLayoutWidget extends StatelessWidget {
  const BookCardLayoutWidget({
    super.key,
    required this.book,
    required this.onTap,
    required this.child,
  });

  final BookModel book;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppSizes.shelfCoverWidth,
                child: AspectRatio(
                  aspectRatio: AppSizes.coverAspectRatio,
                  child: BookCoverImage(
                    title: book.title,
                    genre: book.genre,
                    coverUrl: book.coverUrl,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(child: _Info(book: book, child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.book, required this.child});

  final BookModel book;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium,
        ),
        Text(book.authorsLabel, style: context.textTheme.bodySmall),
        const SizedBox(height: AppSizes.spaceS),
        child,
      ],
    );
  }
}
