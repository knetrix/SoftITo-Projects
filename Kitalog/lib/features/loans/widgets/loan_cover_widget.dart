import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/book_cover_image.dart';

/// Ödünç kartlarındaki küçük kapak.
class LoanCoverWidget extends StatelessWidget {
  const LoanCoverWidget({super.key, required this.book, this.width = AppSizes.loanCoverWidth});

  final BookModel book;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: AppSizes.coverAspectRatio,
        child: BookCoverImage(
          title: book.title,
          genre: book.genre,
          custom: context.customGenreOf(book),
          coverUrl: book.coverUrl,
        ),
      ),
    );
  }
}
