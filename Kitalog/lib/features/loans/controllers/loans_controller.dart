import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/loan_model.dart';
import '../models/loans_model.dart';

/// Ödünç Takibi: ödünçteki kitapları aciliyetine göre sıralar, iade geçmişini
/// kitaplarıyla eşleştirir; ödünç verme, düzenleme ve iade almayı paylaşılan
/// `LibraryController`'a iletir (veri kopyalanmaz, dinlenir).
class LoansController {
  LoansController({required this._library, DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    _library.books.addListener(_recompute);
    _library.loanHistory.addListener(_recompute);
    _recompute();
  }

  final LibraryController _library;
  final DateTime Function() _clock;
  final ValueNotifier<LoansModel> state = ValueNotifier<LoansModel>(const LoansModel());

  /// Kartlardaki "kaç gün" hesapları sayımlarla aynı saatten yapılsın diye.
  DateTime now() => _clock();

  /// Gecikenler (en çok geciken başta), sonra iade günü yaklaşanlar, en sonda
  /// iade tarihi olmayanlar (en uzun süredir ödünçte olan başta).
  static int compareUrgency(BookModel a, BookModel b) {
    final dueA = a.loan!.dueAt;
    final dueB = b.loan!.dueAt;
    if (dueA != null && dueB != null) return dueA.compareTo(dueB);
    if (dueA != null) return -1;
    if (dueB != null) return 1;
    return a.loan!.lentAt.compareTo(b.loan!.lentAt);
  }

  void _recompute() {
    final now = _clock();
    final books = _library.books.value;
    final active = books.where((b) => b.isLent).toList()..sort(compareUrgency);
    final history = [
      for (final record in _library.loanHistory.value)
        if (_library.bookById(record.bookId) case final book?) (record: record, book: book),
    ]..sort((a, b) => b.record.returnedAt.compareTo(a.record.returnedAt));
    final days = [for (final b in active) b.loan!.daysUntilDue(now)];
    state.value = LoansModel(
      active: active,
      history: history,
      lendable: books.where((b) => b.isOwned && !b.isLent).toList(),
      overdueCount: days.where((d) => d != null && d < 0).length,
      dueSoonCount: days.where((d) => d != null && d >= 0 && d <= LoansModel.dueSoonDays).length,
    );
  }

  Future<void> lend(String bookId, LoanModel loan) => _library.lendBook(bookId, loan);

  /// Ödünçteki kitabın bilgisini (kime, iade tarihi) günceller.
  Future<void> updateLoan(String bookId, LoanModel loan) => _library.lendBook(bookId, loan);

  Future<void> markReturned(String bookId) => _library.returnBook(bookId);

  void dispose() {
    _library.books.removeListener(_recompute);
    _library.loanHistory.removeListener(_recompute);
    state.dispose();
  }
}
