import 'package:flutter/foundation.dart';

import '../../../core/models/loan_model.dart';
import '../../../core/models/reading_status.dart';

/// Widget'ların controller'a doğrudan bağımlı olmadan çağırdığı eylemler.
class BookDetailActions {
  const BookDetailActions({
    required this.changePage,
    required this.setPage,
    required this.setStatus,
    required this.setRating,
    required this.saveReview,
    required this.addQuote,
    required this.toggleFavoriteQuote,
    required this.deleteQuote,
    required this.addNote,
    required this.deleteNote,
    required this.lend,
    required this.returnBook,
  });

  final void Function(int delta) changePage;
  final void Function(int page) setPage;
  final void Function(ReadingStatus status) setStatus;
  final void Function(int rating) setRating;
  final void Function(String review) saveReview;
  final void Function(String text, int? page) addQuote;
  final void Function(String quoteId) toggleFavoriteQuote;
  final void Function(String quoteId) deleteQuote;
  final void Function(String content) addNote;
  final void Function(String noteId) deleteNote;
  final void Function(LoanModel loan) lend;
  final VoidCallback returnBook;
}
