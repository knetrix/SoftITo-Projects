import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/models/book_model.dart';
import 'book_shelf_item_widget.dart';

class BookShelfGridWidget extends StatelessWidget {
  const BookShelfGridWidget({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  final List<BookModel> books;
  final ValueChanged<BookModel> onBookTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceL,
        AppSizes.spaceS,
        AppSizes.spaceL,
        96,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppSizes.gridMaxCrossAxisExtent,
        childAspectRatio: 0.52,
        crossAxisSpacing: AppSizes.spaceM,
        mainAxisSpacing: AppSizes.spaceL,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookShelfItemWidget(book: book, onTap: () => onBookTap(book));
      },
    );
  }
}
