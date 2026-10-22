import 'package:flutter/material.dart';

import '../../../core/models/book_model.dart';
import '../../../core/widgets/reading_progress_bar.dart';
import 'book_card_layout_widget.dart';

/// "Okunuyor" kartı: ilerleme çubuğu, sayfa ve yüzde. Sayfa, karta dokununca
/// açılan Kitap Detay'daki Okuma İlerlemesi'nden değiştirilir.
class ReadingBookCardWidget extends StatelessWidget {
  const ReadingBookCardWidget({super.key, required this.book, required this.onTap});

  final BookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BookCardLayoutWidget(
      book: book,
      onTap: onTap,
      child: ReadingProgressBar(
        progress: book.progress,
        currentPage: book.currentPage,
        pageCount: book.pageCount,
      ),
    );
  }
}
