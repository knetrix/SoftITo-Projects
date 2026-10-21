import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/reading_goal/controllers/reading_goal_controller.dart';
import 'package:kitalog/features/reading_goal/models/reading_goal_state.dart';

import '../../helpers/test_dependencies.dart';

void main() {
  test('başlangıç state\'i seed verisinden hesaplanır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingGoalController(library: deps.libraryController);
    final goal = controller.state.value;
    final books = deps.libraryController.books.value;
    final finished = books.where((b) => b.status == ReadingStatus.finished).toList();

    expect(goal.year, DateTime.now().year);
    expect(goal.targetBookCount, 24);
    expect(goal.finishedCount, finished.length);
    expect(goal.monthlyFinished.length, 12);
    expect(goal.monthlyFinished.fold<int>(0, (a, b) => a + b), finished.length);
    expect(goal.genreCounts.values.fold<int>(0, (a, b) => a + b), finished.length);
    final expectedPages = finished.fold<int>(0, (a, b) => a + b.pageCount) +
        books
            .where((b) => b.status == ReadingStatus.reading)
            .fold<int>(0, (a, b) => a + b.currentPage);
    expect(goal.totalPagesRead, expectedPages);
    expect(goal.progress, closeTo(finished.length / 24, 1e-9));
    expect(goal.remaining, 24 - finished.length);
    controller.dispose();
  });

  test('changeTarget hedefi 1 ile 365 arasında sınırlar ve kalıcı yazar', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingGoalController(library: deps.libraryController);
    await controller.changeTarget(1);
    expect(controller.state.value.targetBookCount, 25);
    expect(deps.libraryController.goalTargetFor(DateTime.now().year), 25);
    await controller.changeTarget(-1000);
    expect(controller.state.value.targetBookCount, ReadingGoalController.minTarget);
    await controller.changeTarget(1000);
    expect(controller.state.value.targetBookCount, ReadingGoalController.maxTarget);
    controller.dispose();
  });

  test('kitap bitirilince sayılar otomatik güncellenir', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingGoalController(library: deps.libraryController);
    final before = controller.state.value.finishedCount;
    final book = deps.libraryController.books.value.firstWhere(
      (b) => b.status == ReadingStatus.toRead && b.genre == BookGenre.philosophy,
    );
    await deps.libraryController.setStatus(book.id, ReadingStatus.finished);
    final goal = controller.state.value;
    expect(goal.finishedCount, before + 1);
    expect(goal.genreCounts[BookGenre.philosophy], isNotNull);
    expect(goal.monthlyFinished[DateTime.now().month - 1], greaterThan(0));
    controller.dispose();
  });

  test('ReadingGoalState sınır durumları: hedef 0 iken ilerleme 0, tamamlanma', () {
    const empty = ReadingGoalState(year: 2026, targetBookCount: 0);
    expect(empty.progress, 0);
    expect(empty.remaining, 0);
    const done = ReadingGoalState(year: 2026, targetBookCount: 5, finishedCount: 7);
    expect(done.progress, 1.0);
    expect(done.remaining, 0);
    expect(done.isCompleted, isTrue);
    expect(ReadingGoalState.fromJson(done.toJson()).toJson(), done.toJson());
  });

  test('hiç kitap yokken boş dağılım ve sıfır sayfa', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    for (final b in deps.libraryController.books.value.toList()) {
      await deps.libraryController.deleteBook(b.id);
    }
    final controller = ReadingGoalController(library: deps.libraryController);
    expect(controller.state.value.finishedCount, 0);
    expect(controller.state.value.totalPagesRead, 0);
    expect(controller.state.value.genreCounts, isEmpty);
    expect(controller.state.value.maxMonthly, 0);
    controller.dispose();
  });
}
