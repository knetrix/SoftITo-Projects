import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/features/reader/controllers/reader_controller.dart';
import 'package:kitalog/features/reader/models/reader_model.dart';

import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/test_books.dart';
import '../../helpers/test_dependencies.dart';

/// Suç ve Ceza (Gutenberg 2554, %52 okunuyor) ve Frankenstein (84, bitti).
const _cpId = 'seed-9781435131828';
const _frankId = 'seed-9781435136168';

/// Suç ve Ceza'nın 551 sayfasına bölünebilecek uzunlukta (~175 bin karakter).
final _longText = List.generate(600, (i) => 'Paragraf $i ${'kelime ' * 40}'.trim()).join('\n\n');

Future<(ReaderController, AppDependencies)> _create({
  String bookId = _cpId,
  bool offline = false,
}) async {
  final fake = FakeDigitalSources(
    gutenbergTexts: {'2554': _longText, '84': _longText},
    offline: offline,
  );
  final deps = await createTestDependencies(const {}, fake.client);
  await deps.libraryController.load();
  final controller = ReaderController(
    library: deps.libraryController,
    digital: deps.digitalBookRepository,
    bookId: bookId,
    pageChars: 600,
  );
  return (controller, deps);
}

void main() {
  test('kitap cihazda değilse indirme bekler; indirince sayfalanır', () async {
    final (controller, _) = await _create();
    await controller.open();
    expect(controller.state.value.status, ReaderStatus.notDownloaded);

    final progress = <double>[];
    controller.state.addListener(() => progress.add(controller.state.value.downloadProgress));
    await controller.download();
    expect(controller.state.value.status, ReaderStatus.ready);
    expect(controller.state.value.pageCount, greaterThan(5));
    expect(progress, contains(1.0));
    controller.dispose();
  });

  test('okuyucunun sayfa sayısı kitabın sayfa sayısına eşittir ve sayaçtaki sayfada açılır', () async {
    final (controller, deps) = await _create();
    await controller.download();
    final book = deps.libraryController.bookById(_cpId)!;
    final state = controller.state.value;
    expect(state.pageCount, 551);
    expect(book.pageCount, 551);
    expect(state.pageIndex + 1, book.currentPage);
    controller.dispose();
  });

  test('sayaç Kitap Detay\'da değişirse okuyucu yeni sayfada açılır', () async {
    final (controller, deps) = await _create();
    await controller.download();
    await controller.goToPage(3);
    await deps.libraryController.setCurrentPage(_cpId, 120);
    final reopened = ReaderController(
      library: deps.libraryController,
      digital: deps.digitalBookRepository,
      bookId: _cpId,
    );
    await reopened.open();
    expect(reopened.state.value.pageIndex + 1, 120);
    controller.dispose();
    reopened.dispose();
  });

  test('biten kitap okuyucuda kalınan yer olsa da ilk sayfadan açılır', () async {
    final (controller, deps) = await _create(bookId: _frankId);
    expect(deps.libraryController.bookById(_frankId)!.status, ReadingStatus.finished);
    await controller.download();
    expect(controller.state.value.pageIndex, 0);
    await controller.goToPage(40);
    expect(deps.libraryController.bookById(_frankId)!.status, ReadingStatus.finished);

    final reopened = ReaderController(library: deps.libraryController, digital: deps.digitalBookRepository, bookId: _frankId);
    await reopened.open();
    expect(reopened.state.value.pageIndex, 0);
    controller.dispose();
    reopened.dispose();
  });

  test('okunacak kitap sayaçta sayfa olsa da ilk sayfadan açılır', () async {
    final (controller, deps) = await _create();
    await controller.download();
    await controller.goToPage(30);
    await deps.libraryController.setStatus(_cpId, ReadingStatus.toRead);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, greaterThan(0));

    final reopened = ReaderController(library: deps.libraryController, digital: deps.digitalBookRepository, bookId: _cpId);
    await reopened.open();
    expect(reopened.state.value.pageIndex, 0);
    controller.dispose();
    reopened.dispose();
  });

  test('sayfa değişimi konumu kaydeder ve sayfa sayacını günceller', () async {
    final (controller, deps) = await _create();
    await controller.download();
    await controller.goToPage(0);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, 1);
    await controller.goToPage(3);
    final copy = await deps.digitalBookRepository.copyOf(_cpId);
    expect(copy!.lastOffset, controller.state.value.pages[3].start);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, 4, reason: 'okuyucuda 4. sayfa');

    // Yeniden açılınca kaydedilen sayfadan devam eder (çevrimdışı).
    final reopened = ReaderController(
      library: deps.libraryController,
      digital: deps.digitalBookRepository,
      bookId: _cpId,
      pageChars: 600,
    );
    await reopened.open();
    expect(reopened.state.value.status, ReaderStatus.ready);
    expect(reopened.state.value.pageIndex, 3);
    controller.dispose();
    reopened.dispose();
  });

  test('son sayfa bitirme önerisini tetikler; sayfa sınırları korunur', () async {
    final (controller, deps) = await _create();
    await controller.download();
    await controller.goToPage(9999);
    final state = controller.state.value;
    expect(state.isLastPage, isTrue);
    expect(state.finishSuggested, isTrue);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, 551);
    controller.consumeFinishSuggestion();
    await controller.markFinished();
    expect(deps.libraryController.bookById(_cpId)!.status, ReadingStatus.finished);

    await controller.goToPage(-5);
    expect(controller.state.value.pageIndex, 0);
    await controller.nextPage();
    expect(controller.state.value.pageIndex, 1);
    await controller.previousPage();
    expect(controller.state.value.pageIndex, 0);
    controller.dispose();
  });

  test('ağ yokken indirme hata verir, dijital sürümü olmayan kitap açılamaz', () async {
    final (controller, deps) = await _create(offline: true);
    await controller.download();
    expect(controller.state.value.status, ReaderStatus.failure);
    expect(controller.state.value.error, DigitalBookFailure.network);

    final book = deps.libraryController.bookById(_cpId)!;
    await deps.libraryController.updateBook(book.copyWith(clearDigitalEdition: true));
    await controller.open();
    expect(controller.state.value.error, DigitalBookFailure.unavailable);
    controller.dispose();
  });

  group('seçilen metni alıntı olarak kaydetme', () {
    test('alıntı okuyucudaki sayfa numarasıyla kitaba eklenir; aynısı ikinci kez eklenmez', () async {
      final (controller, deps) = await _create();
      await controller.download();
      final before = deps.libraryController.quotesOf(_cpId).length;

      await controller.saveQuote('  Paragraf 3   kelime\n', 12);
      var quotes = deps.libraryController.quotesOf(_cpId);
      expect(quotes.length, before + 1);
      expect(quotes.first.text, 'Paragraf 3 kelime');
      expect(quotes.first.page, 12);
      expect(controller.state.value.quoteResult, QuoteSaveResult.saved);
      controller.consumeQuoteResult();
      expect(controller.state.value.quoteResult, isNull);

      await controller.saveQuote('Paragraf 3 kelime', 12);
      expect(deps.libraryController.quotesOf(_cpId).length, before + 1);
      expect(controller.state.value.quoteResult, QuoteSaveResult.duplicate);

      await controller.saveQuote('Paragraf 3 kelime', 13);
      expect(deps.libraryController.quotesOf(_cpId).length, before + 2, reason: 'başka sayfada aynı metin ayrı alıntıdır');
      controller.dispose();
    });

    test('boş seçim kaydedilmez', () async {
      final (controller, deps) = await _create();
      final before = deps.libraryController.quotesOf(_cpId).length;
      await controller.saveQuote(' \n\t ', 3);
      expect(deps.libraryController.quotesOf(_cpId).length, before);
      expect(controller.state.value.quoteResult, isNull);
      controller.dispose();
    });

    test('metinde satır yapısı korunur, PDF seçiminde satırlar ve bölünmüş kelimeler birleşir', () {
      expect(ReaderController.normalizeQuote('Dize bir  \r\n  Dize iki\n\n\n\nDize üç'), 'Dize bir\nDize iki\n\nDize üç');
      expect(ReaderController.normalizeQuote('Bilgi güç-\nlüdür ve\nözgürlüktür.', reflow: true), 'Bilgi güçlüdür ve özgürlüktür.');
      expect(ReaderController.normalizeQuote('Kuzey-\nGüney', reflow: true), 'Kuzey- Güney', reason: 'büyük harfle devam eden tire korunur');
    });
  });

  group('kullanıcı dosyası', () {
    Future<(ReaderController, AppDependencies, MemoryDigitalFileStorage)> userBook(
      String fileName,
      List<int> bytes, {
      int pageCount = 200,
    }) async {
      final files = MemoryDigitalFileStorage();
      final deps = await createTestDependencies(const {}, FakeDigitalSources().client, files);
      await deps.libraryController.load();
      final book = BookModel(id: 'k1', title: 'Sula', pageCount: pageCount, addedAt: DateTime(2026));
      await deps.libraryController.addBook(book);
      final result = await deps.digitalBookRepository.importFile(
        book,
        fileName: fileName,
        bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      );
      await deps.libraryController.updateBook(book.copyWith(digitalEdition: result.edition));
      final controller = ReaderController(
        library: deps.libraryController,
        digital: deps.digitalBookRepository,
        bookId: 'k1',
      );
      return (controller, deps, files);
    }

    test('PDF görüntüleyiciye verilir; sayfa sayısı, konum ve sayaç güncellenir', () async {
      final (controller, deps, _) = await userBook('sula.pdf', fakePdfBytes());
      await controller.open();
      var state = controller.state.value;
      expect(state.status, ReaderStatus.ready);
      expect(state.isPdf, isTrue);
      expect(state.pdfBytes, fakePdfBytes());

      await controller.pdfReady(50);
      await controller.pdfPageChanged(11);
      state = controller.state.value;
      expect(state.pageIndex, 10);
      expect(state.pageCount, 50);
      final copy = (await deps.digitalBookRepository.copyOf('k1'))!;
      expect(copy.charCount, 50);
      expect(copy.lastOffset, 10);
      final book = deps.libraryController.bookById('k1')!;
      expect(book.pageCount, 50, reason: 'kitabın sayfa sayısı PDF\'e eşitlenir');
      expect(book.currentPage, 11, reason: 'PDF\'in 11. sayfası');

      await controller.pdfPageChanged(50);
      expect(controller.state.value.finishSuggested, isTrue);
      expect(deps.libraryController.bookById('k1')!.currentPage, 50);

      // Yeniden açılınca kalınan sayfadan başlar.
      final again = ReaderController(library: deps.libraryController, digital: deps.digitalBookRepository, bookId: 'k1');
      await again.open();
      expect(again.state.value.pageIndex, 49);
      controller.dispose();
      again.dispose();
    });

    test('EPUB metin okuyucuda kitabın sayfa sayısı kadar sayfayla açılır', () async {
      final chapter = List.filled(600, 'kelime').join(' ');
      final epub = buildEpub(chapters: ['Birinci bölümün metni. $chapter', chapter]);
      final (controller, deps, _) = await userBook('sula.epub', epub, pageCount: 20);
      await controller.open();
      expect(controller.state.value.isPdf, isFalse);
      expect(controller.state.value.pageCount, 20);
      expect(deps.libraryController.bookById('k1')!.pageCount, 20);
      expect(controller.state.value.pages.first.text, contains('Birinci bölümün metni.'));
      controller.dispose();
    });

    test('sayfa sayısına bölünemeyecek kadar kısa metin kelime bölmez; kitap okuyucuya eşitlenir', () async {
      final (controller, deps, _) = await userBook('sula.epub', buildEpub());
      await controller.open();
      expect(controller.state.value.pages.first.text, contains('Birinci bölümün metni.'));
      expect(deps.libraryController.bookById('k1')!.pageCount, controller.state.value.pageCount);
      controller.dispose();
    });

    test('sayfa sayısı bilinmeyen kitap okuyucunun sayfa sayısını alır', () async {
      final (controller, deps, _) = await userBook('sula.epub', buildEpub(), pageCount: 0);
      await controller.open();
      final pages = controller.state.value.pageCount;
      expect(pages, greaterThan(0));
      expect(deps.libraryController.bookById('k1')!.pageCount, pages);
      controller.dispose();
    });

    test('PDF ilerlemesi sayfa sayısı eşitlenirken korunur', () async {
      final (controller, deps, _) = await userBook('sula.pdf', fakePdfBytes());
      await deps.libraryController.setCurrentPage('k1', 100);
      await controller.open();
      await controller.pdfReady(50);
      final book = deps.libraryController.bookById('k1')!;
      expect(book.pageCount, 50);
      expect(book.currentPage, 25, reason: '100/200 → %50 → 25/50');
      controller.dispose();
    });

    test('biten ve okunacak PDF ilk sayfadan açılır', () async {
      final (controller, deps, _) = await userBook('sula.pdf', fakePdfBytes());
      await controller.open();
      await controller.pdfReady(50);
      await controller.pdfPageChanged(30);
      await deps.libraryController.setStatus('k1', ReadingStatus.finished);
      for (final status in [ReadingStatus.finished, ReadingStatus.toRead]) {
        await deps.libraryController.setStatus('k1', status);
        final again = ReaderController(library: deps.libraryController, digital: deps.digitalBookRepository, bookId: 'k1');
        await again.open();
        expect(again.state.value.pageIndex, 0, reason: status.name);
        again.dispose();
      }
      controller.dispose();
    });

    test('dosya cihazdan kaybolduysa indirme değil yeniden yükleme hatası verilir', () async {
      final (pdf, _, pdfFiles) = await userBook('sula.pdf', fakePdfBytes());
      await pdfFiles.delete('k1.pdf');
      await pdf.open();
      expect(pdf.state.value.error, DigitalBookFailure.fileMissing);

      final (epub, _, epubFiles) = await userBook('sula.epub', buildEpub());
      await epubFiles.delete('k1.txt');
      await epub.open();
      expect(epub.state.value.status, ReaderStatus.failure);
      expect(epub.state.value.error, DigitalBookFailure.fileMissing);
      pdf.dispose();
      epub.dispose();
    });
  });
}
