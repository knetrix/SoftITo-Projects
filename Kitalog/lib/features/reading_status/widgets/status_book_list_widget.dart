import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import 'reading_book_card_widget.dart';
import 'simple_book_card_widget.dart';
import 'status_empty_widget.dart';

/// Bir durum sekmesinin listesi (boşsa durum mesajı).
class StatusBookListWidget extends StatelessWidget {
  const StatusBookListWidget({
    super.key,
    required this.status,
    required this.books,
    required this.onBookTap,
    required this.onChangePage,
    required this.onStartReading,
  });

  final ReadingStatus status;
  final List<BookModel> books;
  final ValueChanged<BookModel> onBookTap;
  final void Function(BookModel book, int delta) onChangePage;
  final ValueChanged<BookModel> onStartReading;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return StatusEmptyWidget(status: status);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.spaceL),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spaceM),
      itemBuilder: (context, index) {
        final book = books[index];
        if (status == ReadingStatus.reading) {
          return ReadingBookCardWidget(
            book: book,
            onTap: () => onBookTap(book),
            onChangePage: (delta) => onChangePage(book, delta),
          );
        }
        return SimpleBookCardWidget(
          book: book,
          onTap: () => onBookTap(book),
          onStartReading: status == ReadingStatus.toRead
              ? () => onStartReading(book)
              : null,
        );
      },
    );
  }
}
