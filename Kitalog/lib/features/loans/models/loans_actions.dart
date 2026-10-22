import 'package:flutter/foundation.dart';

import '../../../core/models/book_model.dart';

/// Ödünç listelerinin controller'a doğrudan bağımlı olmadan çağırdığı eylemler.
class LoansActions {
  const LoansActions({required this.openBook, required this.editLoan, required this.markReturned});

  final ValueChanged<BookModel> openBook;
  final ValueChanged<BookModel> editLoan;
  final ValueChanged<BookModel> markReturned;
}
