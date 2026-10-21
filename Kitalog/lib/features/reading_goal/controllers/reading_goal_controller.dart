import 'package:flutter/foundation.dart';

import '../../../core/controllers/library_controller.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../models/reading_goal_state.dart';

/// Yıllık okuma hedefi paneli: hedef, ilerleme, aylık ve türe göre dağılım.
/// Paylaşılan `LibraryController` dinlenir; her değişiklikte yeniden hesaplanır.
class ReadingGoalController {
  ReadingGoalController({
    required this._library,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _library.books.addListener(_recalculate);
    _library.goals.addListener(_recalculate);
    _recalculate();
  }

  static const int minTarget = 1;
  static const int maxTarget = 365;

  final LibraryController _library;
  final DateTime Function() _clock;

  late final ValueNotifier<ReadingGoalState> state =
      ValueNotifier<ReadingGoalState>(ReadingGoalState(year: _clock().year));

  int get _year => _clock().year;

  void _recalculate() {
    final year = _year;
    final books = _library.books.value;
    final finished = books.where((BookModel b) {
      return b.status == ReadingStatus.finished && b.finishedAt?.year == year;
    }).toList();

    final monthly = List<int>.filled(12, 0);
    final genres = <BookGenre, int>{};
    var pages = 0;
    for (final book in finished) {
      monthly[book.finishedAt!.month - 1]++;
      genres[book.genre] = (genres[book.genre] ?? 0) + 1;
      pages += book.pageCount;
    }
    // Hâlihazırda okunmakta olan kitapların o ana kadarki sayfaları da eklenir.
    for (final book in books.where((b) => b.status == ReadingStatus.reading)) {
      pages += book.currentPage;
    }

    state.value = ReadingGoalState(
      year: year,
      targetBookCount: _library.goalTargetFor(year),
      finishedCount: finished.length,
      totalPagesRead: pages,
      monthlyFinished: monthly,
      genreCounts: genres,
    );
  }

  Future<void> changeTarget(int delta) async {
    final next = (state.value.targetBookCount + delta).clamp(minTarget, maxTarget);
    await _library.setGoalTarget(_year, next);
  }

  void dispose() {
    _library.books.removeListener(_recalculate);
    _library.goals.removeListener(_recalculate);
    state.dispose();
  }
}
