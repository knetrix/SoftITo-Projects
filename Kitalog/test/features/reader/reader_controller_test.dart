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

final _longText = List.generate(40, (i) => 'Paragraf $i ${'kelime ' * 40}'.trim()).join('\n\n');

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

  test('ilk açılışta kitabın sayfa sayacındaki ilerlemeden başlar', () async {
    final (controller, _) = await _create();
    await controller.download();
    final state = controller.state.value;
    final ratio = state.pageIndex / state.pageCount;
    expect(ratio, closeTo(0.52, 0.1));
    controller.dispose();
  });

  test('biten kitap baştan açılır', () async {
    final (controller, deps) = await _create(bookId: _frankId);
    expect(deps.libraryController.bookById(_frankId)!.status, ReadingStatus.finished);
    await controller.download();
    expect(controller.state.value.pageIndex, 0);
    controller.dispose();
  });

  test('sayfa değişimi konumu kaydeder ve sayfa sayacını günceller', () async {
    final (controller, deps) = await _create();
    await controller.download();
    await controller.goToPage(0);
    expect(deps.libraryController.bookById(_cpId)!.currentPage, 0);
    await controller.goToPage(3);
    final copy = await deps.digitalBookRepository.copyOf(_cpId);
    expect(copy!.lastOffset, controller.state.value.pages[3].start);
    final page = deps.libraryController.bookById(_cpId)!.currentPage;
    expect(page, greaterThan(0));
    expect(page, lessThan(551));

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

  group('kullanıcı dosyası', () {
    Future<(ReaderController, AppDependencies, MemoryDigitalFileStorage)> userBook(
      String fileName,
      List<int> bytes,
    ) async {
      final files = MemoryDigitalFileStorage();
      final deps = await createTestDependencies(const {}, FakeDigitalSources().client, files);
      await deps.libraryController.load();
      final book = BookModel(id: 'k1', title: 'Sula', pageCount: 200, addedAt: DateTime(2026));
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
      expect(deps.libraryController.bookById('k1')!.currentPage, 40, reason: '10/50 × 200 basılı sayfa');

      await controller.pdfPageChanged(50);
      expect(controller.state.value.finishSuggested, isTrue);
      expect(deps.libraryController.bookById('k1')!.currentPage, 200);

      // Yeniden açılınca kalınan sayfadan başlar.
      final again = ReaderController(library: deps.libraryController, digital: deps.digitalBookRepository, bookId: 'k1');
      await again.open();
      expect(again.state.value.pageIndex, 49);
      controller.dispose();
      again.dispose();
    });

    test('EPUB metin okuyucuda açılır', () async {
      final (controller, _, _) = await userBook('sula.epub', buildEpub());
      await controller.open();
      expect(controller.state.value.isPdf, isFalse);
      expect(controller.state.value.pages.first.text, contains('Birinci bölümün metni.'));
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
