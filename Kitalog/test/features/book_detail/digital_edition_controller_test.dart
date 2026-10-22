import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/digital_format.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/core/repositories/translation_repository.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/utils/text_paginator.dart';
import 'package:kitalog/features/book_detail/controllers/book_file_picker.dart';
import 'package:kitalog/features/book_detail/controllers/digital_edition_controller.dart';
import 'package:kitalog/features/reader/controllers/reader_controller.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/fake_translation_engine.dart';
import '../../helpers/test_books.dart';
import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';
const _userId = 'kullanici-1';

Future<(DigitalEditionController, AppDependencies, FakeBookFilePicker)> _create({
  String bookId = _cpId,
  FakeDigitalSources? fake,
  PickedBookFile? file,
  int pageCount = 174,
  int pdfPages = 0,
  FakeTranslationEngine? engine,
  String pdfText = '',
  DigitalFileStorage? files,
}) async {
  final sources = fake ?? FakeDigitalSources(gutenbergTexts: {'2554': 'Suç ve Ceza metni'});
  final deps = await createTestDependencies(
    const {},
    sources.client,
    files,
    (_) async => pdfPages,
    engine,
    (_) async => pdfText,
  );
  await deps.libraryController.load();
  await deps.libraryController.addBook(
    BookModel(id: _userId, title: 'Sula', pageCount: pageCount, addedAt: DateTime(2026)),
  );
  final picker = FakeBookFilePicker(file);
  final controller = DigitalEditionController(
    library: deps.libraryController,
    digital: deps.digitalBookRepository,
    translation: deps.translationRepository,
    picker: picker,
    bookId: bookId,
  );
  return (controller, deps, picker);
}

/// Yaklaşık [pages] × 875 karakterlik tek bölümlü EPUB metni.
List<String> _chapters(int pages) => [
  'Birinci bölümün metni. ${List.filled(pages * 125, 'kelime').join(' ')}',
];

void main() {
  group('dosya yüklenince Okuma İlerlemesi dosyanın sayfa sayısına eşitlenir', () {
    test('500 sayfalık kitaba 120 sayfalık PDF: sayaç 120 olur, ilerleme yüzdesi korunur', () async {
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()),
        pageCount: 500,
        pdfPages: 120,
      );
      await deps.libraryController.setCurrentPage(_userId, 250);
      await controller.importFile();
      final book = deps.libraryController.bookById(_userId)!;
      expect(book.pageCount, 120);
      expect(book.currentPage, 60, reason: '250/500 → %50 → 60/120');
      expect((await deps.digitalBookRepository.copyOf(_userId))!.charCount, 120);
      controller.dispose();
    });

    test('PDF sayfa sayısı okunamazsa sayfa sayısı değişmez (okuyucu ilk açılışta eşitler)', () async {
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()),
        pageCount: 500,
      );
      await controller.importFile();
      expect(deps.libraryController.bookById(_userId)!.pageCount, 500);
      controller.dispose();
    });

    test('EPUB basılı sayfa listesi içeriyorsa sayaç o sayıya eşitlenir', () async {
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.epub', bytes: buildEpub(chapters: _chapters(40), navPages: 64)),
        pageCount: 500,
      );
      await controller.importFile();
      expect(deps.libraryController.bookById(_userId)!.pageCount, 64);
      controller.dispose();
    });

    test('sayfa listesi olmayan EPUB okuyucunun sayfa sayısını alır; okuyucu ile aynıdır', () async {
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.epub', bytes: buildEpub(chapters: _chapters(40))),
        pageCount: 500,
      );
      await controller.importFile();
      final pages = deps.libraryController.bookById(_userId)!.pageCount;
      final text = (await deps.digitalBookRepository.readText(_userId))!;
      expect(pages, TextPaginator.paginate(text).length);
      expect(pages, isNot(500));

      final reader = ReaderController(
        library: deps.libraryController,
        digital: deps.digitalBookRepository,
        bookId: _userId,
      );
      await reader.open();
      expect(reader.state.value.pageCount, pages);
      expect(deps.libraryController.bookById(_userId)!.pageCount, pages);
      reader.dispose();
      controller.dispose();
    });

    test('başka dosya yüklenince sayaç yeni dosyaya göre yeniden eşitlenir', () async {
      final (controller, deps, picker) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'a.epub', bytes: buildEpub(chapters: _chapters(40), navPages: 64)),
        pageCount: 500,
      );
      await controller.importFile();
      picker.file = PickedBookFile(name: 'b.epub', bytes: buildEpub(chapters: _chapters(40), ncxPages: 90));
      await controller.importFile();
      expect(deps.libraryController.bookById(_userId)!.pageCount, 90);
      controller.dispose();
    });
  });

  test('telifi bitmiş kitap indirilir ve cihazdan silinir', () async {
    final (controller, deps, _) = await _create();
    await controller.load();
    expect(controller.state.value.isDownloaded, isFalse);
    await controller.download();
    expect(controller.state.value.isDownloaded, isTrue);
    expect(await deps.digitalBookRepository.readText(_cpId), 'Suç ve Ceza metni');

    await controller.deleteCopy();
    expect(controller.state.value.isDownloaded, isFalse);
    expect(deps.libraryController.bookById(_cpId)!.hasDigitalEdition, isTrue,
        reason: 'telifi bitmiş kitabın kaynağı korunur, yeniden indirilebilir');
    controller.dispose();
  });

  test('indirme hatası state\'e anahtar olarak yazılır', () async {
    final (controller, _, _) = await _create(fake: FakeDigitalSources(offline: true));
    await controller.download();
    expect(controller.state.value.error, DigitalBookFailure.network);
    controller.dispose();
  });

  test('kullanıcı EPUB yükler: kitaba bağlanır ve metin okunur', () async {
    final (controller, deps, _) = await _create(
      bookId: _userId,
      file: PickedBookFile(name: 'sula.epub', bytes: buildEpub()),
    );
    await controller.importFile();
    final book = deps.libraryController.bookById(_userId)!;
    expect(book.digitalEdition?.source, DigitalSource.localFile);
    expect(book.digitalEdition?.sourceId, 'sula.epub');
    expect(book.digitalEdition?.format, DigitalFormat.text);
    expect(controller.state.value.isDownloaded, isTrue);
    expect(await deps.digitalBookRepository.readText(_userId), contains('Birinci bölümün metni.'));
    controller.dispose();
  });

  test('kullanıcı PDF yükler; silince dosya bağlantısı da kalkar', () async {
    final (controller, deps, _) = await _create(
      bookId: _userId,
      file: PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()),
    );
    await controller.importFile();
    expect(deps.libraryController.bookById(_userId)!.digitalEdition?.format, DigitalFormat.pdf);
    expect(await deps.digitalBookRepository.readPdf(_userId), fakePdfBytes());

    await controller.deleteCopy();
    expect(deps.libraryController.bookById(_userId)!.hasDigitalEdition, isFalse);
    expect(await deps.digitalBookRepository.copyOf(_userId), isNull);
    controller.dispose();
  });

  test('seçimden vazgeçilirse hiçbir şey değişmez; geçersiz dosyada hata gösterilir', () async {
    final (cancel, deps, picker) = await _create(bookId: _userId);
    await cancel.importFile();
    expect(picker.calls, 1);
    expect(deps.libraryController.bookById(_userId)!.hasDigitalEdition, isFalse);
    expect(cancel.state.value.error, isNull);

    picker.file = PickedBookFile(name: 'notlar.txt', bytes: fakePdfBytes().sublist(4));
    await cancel.importFile();
    expect(cancel.state.value.error, DigitalBookFailure.unsupportedFile);
    expect(cancel.state.value.isImporting, isFalse);
    cancel.dispose();
  });

  group('yüklenen dosyanın dili okuyucudaki çeviri için otomatik tanınır', () {
    test('İngilizce EPUB → en, Türkçe EPUB → tr', () async {
      final (english, deps, picker) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'book.epub', bytes: buildEpub(chapters: ['It was a bright cold day in April. ' * 20])),
        engine: FakeTranslationEngine(),
      );
      await english.importFile();
      expect(deps.libraryController.bookById(_userId)!.digitalEdition!.languageCode, 'en');

      picker.file = PickedBookFile(name: 'kitap.epub', bytes: buildEpub(chapters: ['Nisan ayında güneşli bir gündü.']));
      await english.importFile();
      expect(deps.libraryController.bookById(_userId)!.digitalEdition!.languageCode, 'tr');
      english.dispose();
    });

    test('PDF\'te dil sayfalardan okunan metinden tanınır', () async {
      final engine = FakeTranslationEngine();
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()),
        engine: engine,
        pdfText: 'Bir varmış bir yokmuş, evvel zaman içinde…',
      );
      await controller.importFile();
      expect(deps.libraryController.bookById(_userId)!.digitalEdition!.languageCode, 'tr');
      expect(engine.identified.single, startsWith('Bir varmış'));
      controller.dispose();
    });

    test('dil tanınamazsa (ör. taranmış PDF) boş kalır', () async {
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'sula.pdf', bytes: fakePdfBytes()),
        engine: FakeTranslationEngine(),
      );
      await controller.importFile();
      expect(deps.libraryController.bookById(_userId)!.digitalEdition!.languageCode, '');
      controller.dispose();
    });

    test('dosya değişince veya silinince kitabın çeviri önbelleği temizlenir', () async {
      final files = MemoryDigitalFileStorage();
      final (controller, deps, _) = await _create(
        bookId: _userId,
        file: PickedBookFile(name: 'book.epub', bytes: buildEpub(chapters: ['Hello there.'])),
        engine: FakeTranslationEngine(),
        files: files,
      );
      final cacheName = TranslationRepository.cacheFileName(_userId, 'en', 'tr');
      Future<void> translate() =>
          deps.translationRepository.translateLines(_userId, ['Hello there.'], from: 'en', to: 'tr');

      await controller.importFile();
      await translate();
      expect(await files.read(cacheName), isNotNull);

      await controller.importFile();
      expect(await files.read(cacheName), isNull, reason: 'yeni dosya yüklendi');

      await translate();
      await controller.deleteCopy();
      expect(await files.read(cacheName), isNull, reason: 'dijital kopya silindi');
      controller.dispose();
    });
  });
}
