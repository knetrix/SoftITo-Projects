import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/features/reading_status/controllers/reading_status_controller.dart';

import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';

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

  test('kitap başka ekrandan (ör. Kitap Detay) bitirilince "Bitti" listesine geçer', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = ReadingStatusController(library: deps.libraryController);
    expect(controller.state.value.reading.any((b) => b.id == _cpId), isTrue);
    await deps.libraryController.setStatus(_cpId, ReadingStatus.finished);
    expect(controller.state.value.finished.first.id, _cpId, reason: 'en son biten başta');
    expect(controller.state.value.reading.any((b) => b.id == _cpId), isFalse);
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
