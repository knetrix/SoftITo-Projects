import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/reading_progress_bar.dart';
import 'book_card_layout_widget.dart';
import 'quick_page_counter_widget.dart';

/// "Okunuyor" kartı: ilerleme yüzdesi ve hızlı sayfa sayacı.
class ReadingBookCardWidget extends StatelessWidget {
  const ReadingBookCardWidget({
    super.key,
    required this.book,
    required this.onTap,
    required this.onChangePage,
  });

  final BookModel book;
  final VoidCallback onTap;
  final ValueChanged<int> onChangePage;

  @override
  Widget build(BuildContext context) {
    return BookCardLayoutWidget(
      book: book,
      onTap: onTap,
      child: Column(
        children: [
          ReadingProgressBar(
            progress: book.progress,
            currentPage: book.currentPage,
            pageCount: book.pageCount,
          ),
          const SizedBox(height: AppSizes.spaceS),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: QuickPageCounterWidget(
                currentPage: book.currentPage,
                onChange: onChangePage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
