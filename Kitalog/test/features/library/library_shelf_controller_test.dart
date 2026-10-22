import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/utils/search_utils.dart';
import 'package:kitalog/features/library/controllers/library_shelf_controller.dart';
import 'package:kitalog/features/library/models/library_shelf_model.dart';

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

  test('tür, biçim ve arama filtreleri birlikte çalışır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = LibraryShelfController(library: deps.libraryController);

    controller.toggleGenre((genre: BookGenre.novel, customGenreId: null));
    expect(controller.state.value.books.every((b) => b.genre == BookGenre.novel), isTrue);
    expect(controller.state.value.books, isNotEmpty);

    controller.toggleFormat(BookFormatFilter.physical);
    expect(controller.state.value.books.every((b) => b.genre == BookGenre.novel && b.isOwned), isTrue);
    expect(controller.state.value.books, isNotEmpty);

    controller.setQuery('SABAHATTİN');
    expect(controller.state.value.books.map((b) => b.title), contains('Kürk Mantolu Madonna'));
    controller.setQuery('yok böyle kitap');
    expect(controller.state.value.books, isEmpty);
    expect(controller.state.value.isLibraryEmpty, isFalse);

    controller.setQuery('');
    controller.clearFilters();
    expect(controller.state.value.isFiltered, isFalse);
    expect(controller.state.value.books.length, deps.libraryController.books.value.length);
    controller.dispose();
  });

  test('aynı grupta çoklu seçim "veya", gruplar arası "ve" ile birleşir; ikinci dokunuş kaldırır', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final all = deps.libraryController.books.value;
    final controller = LibraryShelfController(library: deps.libraryController);
    const novel = (genre: BookGenre.novel, customGenreId: null);
    const poetry = (genre: BookGenre.poetry, customGenreId: null);

    controller.toggleGenre(novel);
    controller.toggleGenre(poetry);
    expect(controller.state.value.activeFilterCount, 2);
    final novelOrPoetry = all.where((b) => b.genre == BookGenre.novel || b.genre == BookGenre.poetry);
    expect(controller.state.value.books.length, novelOrPoetry.length);

    controller.toggleFormat(BookFormatFilter.physical);
    controller.toggleFormat(BookFormatFilter.digital);
    expect(
      controller.state.value.books.map((b) => b.id).toSet(),
      novelOrPoetry.where((b) => b.isOwned || b.hasDigitalEdition).map((b) => b.id).toSet(),
    );

    controller.toggleGenre(poetry);
    expect(controller.state.value.genres, {novel});
    expect(controller.state.value.activeFilterCount, 3);
    controller.dispose();
  });

  test('biçim filtreleri yalnızca fiziksel ve dijital; ödünçte filtresi yok', () async {
    expect(BookFormatFilter.values, [BookFormatFilter.physical, BookFormatFilter.digital]);
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final all = deps.libraryController.books.value;
    final controller = LibraryShelfController(library: deps.libraryController);

    controller.toggleFormat(BookFormatFilter.physical);
    expect(controller.state.value.books.every((b) => b.isOwned), isTrue);
    expect(controller.state.value.books.length, all.where((b) => b.isOwned).length);

    controller.toggleFormat(BookFormatFilter.physical);
    controller.toggleFormat(BookFormatFilter.digital);
    expect(controller.state.value.books.length, all.where((b) => b.hasDigitalEdition).length);

    // Yalnızca dijital (fiziksel kopyası olmayan) kitaplar: dijital + "okunacak" ile ayrılmaz,
    // ama fiziksel filtresi onları dışarıda bırakır.
    final digitalOnly = all.where((b) => !b.isOwned).map((b) => b.id);
    controller.toggleFormat(BookFormatFilter.digital);
    controller.toggleFormat(BookFormatFilter.physical);
    expect(controller.state.value.books.map((b) => b.id), isNot(contains(digitalOnly.first)));
    controller.dispose();
  });

  test('filtre durumu JSON\'a yazılıp geri okunur', () {
    const model = LibraryShelfModel(
      query: 'a',
      formats: {BookFormatFilter.digital, BookFormatFilter.physical},
      genres: {(genre: BookGenre.other, customGenreId: 'g1'), (genre: BookGenre.novel, customGenreId: null)},
    );
    final back = LibraryShelfModel.fromJson(model.toJson());
    expect(back.query, 'a');
    expect(back.formats, model.formats);
    expect(back.genres, model.genres);
    expect(back.activeFilterCount, 4);
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

  test('kullanıcı kategorisine göre süzülür; "Diğer" filtresine kategorili kitap girmez', () async {
    final deps = await createTestDependencies();
    final library = deps.libraryController;
    await library.load();
    final mizah = await library.addCustomGenre('Mizah');
    await library.addBook(BookModel(id: 'k1', title: 'Gülmece', customGenreId: mizah.id, addedAt: DateTime(2026)));
    await library.addBook(BookModel(id: 'k2', title: 'Belirsiz', addedAt: DateTime(2026)));
    final controller = LibraryShelfController(library: library);
    expect(controller.state.value.customGenres.map((g) => g.name), ['Mizah']);

    controller.toggleGenre((genre: BookGenre.other, customGenreId: mizah.id));
    expect(controller.state.value.books.map((b) => b.id), ['k1']);
    expect(controller.state.value.isFiltered, isTrue);

    controller.clearFilters();
    controller.toggleGenre((genre: BookGenre.other, customGenreId: null));
    final ids = controller.state.value.books.map((b) => b.id);
    expect(ids, contains('k2'));
    expect(ids, isNot(contains('k1')));

    await library.addCustomGenre('Polisiye');
    expect(controller.state.value.customGenres.length, 2, reason: 'yeni kategori filtre çiplerine anında gelir');
    controller.dispose();
  });
}
