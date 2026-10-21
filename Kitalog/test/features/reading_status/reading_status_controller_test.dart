import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/reading_status/controllers/reading_status_controller.dart';

import '../../helpers/test_dependencies.dart';

const _duneId = 'seed-9780340839935';

void main() {
  test('kitapları üç duruma gruplar; okunanlar ilerlemeye göre sıralanır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingStatusController(library: deps.libraryController);
    final state = controller.state.value;
    expect(state.reading.every((b) => b.status == ReadingStatus.reading), isTrue);
    expect(state.toRead.every((b) => b.status == ReadingStatus.toRead), isTrue);
    expect(state.finished.every((b) => b.status == ReadingStatus.finished), isTrue);
    expect(
      state.reading.length + state.toRead.length + state.finished.length,
      deps.libraryController.books.value.length,
    );
    final progress = state.reading.map((b) => b.progress).toList();
    expect([...progress]..sort((a, b) => b.compareTo(a)), progress);
    controller.dispose();
  });

  test('changePage ilerlemeyi günceller ve sınırlar', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingStatusController(library: deps.libraryController);
    final before = deps.libraryController.bookById(_duneId)!.currentPage;
    await controller.changePage(_duneId, 1);
    expect(deps.libraryController.bookById(_duneId)!.currentPage, before + 1);
    await controller.changePage(_duneId, -100000);
    expect(deps.libraryController.bookById(_duneId)!.currentPage, 0);
    controller.dispose();
  });

  test('son sayfa bitirme önerisini tetikler, markFinished bitirir', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingStatusController(library: deps.libraryController);
    await controller.changePage(_duneId, 100000);
    expect(controller.state.value.finishSuggestedBookId, _duneId);
    controller.consumeFinishSuggestion();
    expect(controller.state.value.finishSuggestedBookId, isNull);
    await controller.markFinished(_duneId);
    expect(controller.state.value.finished.any((b) => b.id == _duneId), isTrue);
    expect(controller.state.value.reading.any((b) => b.id == _duneId), isFalse);
    controller.dispose();
  });

  test('startReading okunacak kitabı okunuyor listesine taşır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingStatusController(library: deps.libraryController);
    final id = controller.state.value.toRead.first.id;
    await controller.startReading(id);
    expect(controller.state.value.reading.any((b) => b.id == id), isTrue);
    expect(controller.state.value.toRead.any((b) => b.id == id), isFalse);
    controller.dispose();
  });
}
