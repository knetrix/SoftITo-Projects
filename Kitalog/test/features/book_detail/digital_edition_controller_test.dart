import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/digital_format.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/features/book_detail/controllers/book_file_picker.dart';
import 'package:kitalog/features/book_detail/controllers/digital_edition_controller.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/test_books.dart';
import '../../helpers/test_dependencies.dart';

const _cpId = 'seed-9781435131828';
const _userId = 'kullanici-1';

Future<(DigitalEditionController, AppDependencies, FakeBookFilePicker)> _create({
  String bookId = _cpId,
  FakeDigitalSources? fake,
  PickedBookFile? file,
}) async {
  final sources = fake ?? FakeDigitalSources(gutenbergTexts: {'2554': 'Suç ve Ceza metni'});
  final deps = await createTestDependencies(const {}, sources.client);
  await deps.libraryController.load();
  await deps.libraryController.addBook(
    BookModel(id: _userId, title: 'Sula', pageCount: 174, addedAt: DateTime(2026)),
  );
  final picker = FakeBookFilePicker(file);
  final controller = DigitalEditionController(
    library: deps.libraryController,
    digital: deps.digitalBookRepository,
    picker: picker,
    bookId: bookId,
  );
  return (controller, deps, picker);
}

void main() {
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
}
