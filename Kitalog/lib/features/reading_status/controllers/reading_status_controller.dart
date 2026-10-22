import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../models/reading_status_model.dart';

/// Kitapları okuma durumuna göre gruplar; okunacak kitabı okumaya başlatır.
class ReadingStatusController {
  ReadingStatusController({required this._library}) {
    _library.books.addListener(_regroup);
    _regroup();
  }

  final LibraryController _library;
  final ValueNotifier<ReadingStatusModel> state =
      ValueNotifier<ReadingStatusModel>(const ReadingStatusModel());

  void _regroup() {
    final books = _library.books.value;
    List<BookModel> by(ReadingStatus s) =>
        books.where((b) => b.status == s).toList();

    final reading = by(ReadingStatus.reading)
      ..sort((a, b) => b.progress.compareTo(a.progress));
    final finished = by(ReadingStatus.finished)
      ..sort(
        (a, b) => (b.finishedAt ?? b.addedAt).compareTo(a.finishedAt ?? a.addedAt),
      );
    state.value = state.value.copyWith(
      reading: reading,
      toRead: by(ReadingStatus.toRead),
      finished: finished,
    );
  }

  Future<void> startReading(String bookId) {
    return _library.setStatus(bookId, ReadingStatus.reading);
  }

  void dispose() {
    _library.books.removeListener(_regroup);
    state.dispose();
  }
}
