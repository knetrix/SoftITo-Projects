import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/models/view_status.dart';
import 'package:kitalog/features/add_book/controllers/add_book_controller.dart';
import 'package:kitalog/features/add_book/models/add_book_model.dart';

import '../../helpers/fake_open_library.dart';
import '../../helpers/test_dependencies.dart';

Future<(AddBookController, dynamic)> _create({
  Map<String, dynamic> searchBody = const {'docs': []},
  bool offline = false,
  int status = 200,
}) async {
  final deps = await createTestDependencies(
    const {},
    fakeOpenLibrary(searchBody: searchBody, offline: offline, searchStatus: status),
  );
  await deps.libraryController.load();
  final controller = AddBookController(
    library: deps.libraryController,
    search: deps.bookSearchRepository,
  );
  return (controller, deps);
}

void main() {
  test('boş ve geçersiz ISBN aramaları hata anahtarı verir', () async {
    final (controller, _) = await _create();
    await controller.search('   ');
    expect(controller.state.value.error, AddBookError.emptyQuery);
    await controller.search('9780375508326');
    expect(controller.state.value.error, AddBookError.invalidIsbn);
    expect(controller.state.value.results, isEmpty);
    controller.dispose();
  });

  test('başarılı arama sonuçları listeler', () async {
    final (controller, _) = await _create(searchBody: cosmosSearchBody);
    await controller.search('cosmos');
    expect(controller.state.value.searchStatus, ViewStatus.success);
    expect(controller.state.value.results.length, 2);
    expect(controller.state.value.error, isNull);
    controller.dispose();
  });

  test('sonuç yok → notFound, ağ yok → network, 500 → server', () async {
    var (controller, _) = await _create();
    await controller.search('olmayan kitap');
    expect(controller.state.value.error, AddBookError.notFound);

    (controller, _) = await _create(offline: true);
    await controller.search('cosmos');
    expect(controller.state.value.error, AddBookError.network);
    expect(controller.state.value.searchStatus, ViewStatus.failure);

    (controller, _) = await _create(status: 500);
    await controller.search('cosmos');
    expect(controller.state.value.error, AddBookError.server);
  });

  test('retry son aramayı tekrarlar', () async {
    final (controller, _) = await _create(searchBody: cosmosSearchBody);
    await controller.search('cosmos');
    await controller.retry();
    expect(controller.state.value.results.length, 2);
    controller.dispose();
  });

  test('sonuç seçilince manuel forma geçilir ve ön doldurma sürümü artar', () async {
    final (controller, _) = await _create(searchBody: cosmosSearchBody);
    await controller.search('cosmos');
    final before = controller.state.value.prefillVersion;
    controller.selectResult(controller.state.value.results.first);
    expect(controller.state.value.mode, AddBookMode.manual);
    expect(controller.state.value.prefill?.title, 'Cosmos');
    expect(controller.state.value.prefillVersion, before + 1);
    controller.dispose();
  });

  test('save kitabı kitaplığa ekler; bitti durumunda sayfa ve tarih set edilir', () async {
    final (controller, deps) = await _create();
    final before = deps.libraryController.books.value.length as int;
    await controller.save(
      const BookDraft(
        title: '  Yeni Kitap ',
        authors: ['Yazar'],
        pageCount: 120,
        genre: BookGenre.poetry,
        status: ReadingStatus.finished,
        coverUrl: '',
      ),
    );
    expect(controller.state.value.saved, isTrue);
    final books = deps.libraryController.books.value;
    expect(books.length, before + 1);
    final added = books.first;
    expect(added.title, 'Yeni Kitap');
    expect(added.currentPage, 120);
    expect(added.finishedAt, isNotNull);
    expect(added.coverUrl, isNull);
    controller.dispose();
  });

  test('aynı ISBN ikinci kez eklenemez', () async {
    final (controller, _) = await _create();
    await controller.save(
      const BookDraft(title: 'Cosmos', pageCount: 365, isbn: '9780375508325'),
    );
    expect(controller.state.value.error, AddBookError.duplicate);
    expect(controller.state.value.saved, isFalse);
    controller.dispose();
  });
}
