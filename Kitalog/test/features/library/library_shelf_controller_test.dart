import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/utils/search_utils.dart';
import 'package:kitalog/features/library/controllers/library_shelf_controller.dart';

import '../../helpers/test_dependencies.dart';

void main() {
  test('foldForSearch Türkçe harfleri ve büyük/küçük harfi eşitler', () {
    expect(foldForSearch('  İÇİMİZDEKİ ŞEYTAN '), 'icimizdeki seytan');
    expect(foldForSearch('Işık'), 'isik');
    expect(foldForSearch('Nâzım Hikmet'), 'nazim hikmet');
  });

  test('başlangıçta tüm kitapları listeler', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = LibraryShelfController(library: deps.libraryController);
    expect(controller.state.value.books.length, deps.libraryController.books.value.length);
    expect(controller.state.value.isFiltered, isFalse);
    controller.dispose();
  });

  test('tür, durum ve arama filtreleri birlikte çalışır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = LibraryShelfController(library: deps.libraryController);

    controller.setGenre(BookGenre.novel);
    expect(controller.state.value.books.every((b) => b.genre == BookGenre.novel), isTrue);
    expect(controller.state.value.books, isNotEmpty);

    controller.setStatus(ReadingStatus.finished);
    expect(
      controller.state.value.books.every(
        (b) => b.genre == BookGenre.novel && b.status == ReadingStatus.finished,
      ),
      isTrue,
    );

    controller.setQuery('SABAHATTİN');
    expect(controller.state.value.books.map((b) => b.title), contains('Kürk Mantolu Madonna'));
    controller.setQuery('yok böyle kitap');
    expect(controller.state.value.books, isEmpty);
    expect(controller.state.value.isLibraryEmpty, isFalse);

    controller.setQuery('');
    controller.setGenre(null);
    controller.setStatus(null);
    expect(controller.state.value.isFiltered, isFalse);
    controller.dispose();
  });

  test('paylaşılan kitap listesi değişince süzülmüş liste güncellenir', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final controller = LibraryShelfController(library: library);
    controller.setQuery('dracula');
    expect(controller.state.value.books.length, 1);
    await library.deleteBook(controller.state.value.books.first.id);
    expect(controller.state.value.books, isEmpty);
    expect(controller.state.value.totalCount, library.books.value.length);
    controller.dispose();
  });
}
