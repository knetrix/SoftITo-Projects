import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../models/book_detail_actions.dart';
import '../models/book_detail_model.dart';
import 'book_header_widget.dart';
import 'loan_section_widget.dart';
import 'notes_section_widget.dart';
import 'page_counter_widget.dart';
import 'quotes_section_widget.dart';
import 'rating_review_widget.dart';
import 'status_selector_widget.dart';

/// Detay ekranının kaydırılabilir gövdesi: tüm bölümleri sıralar.
class BookDetailContentWidget extends StatelessWidget {
  const BookDetailContentWidget({
    super.key,
    required this.state,
    required this.actions,
    required this.digitalSection,
  });

  final BookDetailModel state;
  final BookDetailActions actions;

  /// Dijital sürüm bölümü kendi durumunu dinlediği için hazır widget olarak verilir.
  final Widget digitalSection;

  @override
  Widget build(BuildContext context) {
    final book = state.book!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceL),
      child: Column(
        spacing: AppSizes.spaceM,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        BookHeaderWidget(book: book),
        digitalSection,
        PageCounterWidget(book: book, onChangePage: actions.changePage, onSetPage: actions.setPage),
        StatusSelectorWidget(book: book, onChanged: actions.setStatus, onReadAgain: actions.readAgain),
        RatingReviewWidget(
          book: book,
          onRatingChanged: actions.setRating,
          onReviewSaved: actions.saveReview,
        ),
        QuotesSectionWidget(
          quotes: state.quotes,
          pageCount: book.pageCount,
          onAdd: actions.addQuote,
          onToggleFavorite: actions.toggleFavoriteQuote,
          onDelete: actions.deleteQuote,
        ),
        NotesSectionWidget(
          notes: state.notes,
          onAdd: actions.addNote,
          onDelete: actions.deleteNote,
        ),
        LoanSectionWidget(
          loan: book.loan,
          onLend: actions.lend,
          onReturn: actions.returnBook,
        ),
      ],
      ),
    );
  }
}
