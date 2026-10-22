import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/repositories/translation/translation_engine.dart';
import 'package:kitalog/features/reader/controllers/reader_controller.dart';
import 'package:kitalog/features/reader/controllers/reader_translation_controller.dart';
import 'package:kitalog/features/reader/models/reader_translation_model.dart';

import '../../helpers/fake_digital_sources.dart';
import '../../helpers/fake_translation_engine.dart';
import '../../helpers/test_books.dart';
import '../../helpers/test_dependencies.dart';

/// Frankenstein (Gutenberg 84, İngilizce, bitti → ilk sayfadan açılır).
const _frankId = 'seed-9781435136168';
const _userId = 'kullanici-1';

final _text = List.generate(
  300,
  (i) => 'Paragraph $i ${'word ' * 40}'.trim(),
).join('\n\n');

typedef _Setup = ({
  ReaderController reader,
  ReaderTranslationController translation,
  AppDependencies deps,
  FakeTranslationEngine engine,
});

Future<_Setup> _create({
  FakeTranslationEngine? engine,
  String bookId = _frankId,
}) async {
  final fake = engine ?? FakeTranslationEngine();
  final sources = FakeDigitalSources(gutenbergTexts: {'84': _text});
  final deps = await createTestDependencies(
    const {},
    sources.client,
    null,
    null,
    fake,
  );
  await deps.libraryController.load();
  final reader = ReaderController(
    library: deps.libraryController,
    digital: deps.digitalBookRepository,
    bookId: bookId,
    pageChars: 600,
  );
  final translation = ReaderTranslationController(
    library: deps.libraryController,
    digital: deps.digitalBookRepository,
    translation: deps.translationRepository,
    reader: reader.state,
    bookId: bookId,
  );
  return (reader: reader, translation: translation, deps: deps, engine: fake);
}

Future<_Setup> _ready({FakeTranslationEngine? engine}) async {
  final setup = await _create(engine: engine);
  setup.translation.init();
  await setup.reader.download();
  await pumpEventQueue();
  return setup;
}

void _dispose(_Setup s) {
  s.translation.dispose();
  s.reader.dispose();
}

void main() {
  test('İngilizce kitapta çeviri sunulur ve hedef Türkçedir', () async {
    final s = await _ready();
    final state = s.translation.state.value;
    expect(state.isAvailable, isTrue);
    expect(state.sourceLanguage, 'en');
    expect(state.targetLanguage, 'tr');
    expect(state.view, TranslationView.original);
    expect(
      s.engine.translated,
      isEmpty,
      reason: 'orijinal görünümde hiçbir şey çevrilmez',
    );
    _dispose(s);
  });

  test('çeviri görünümü gösterilen sayfayı satır satır ve sonraki sayfayı önceden çevirir', () async {
    final s = await _ready();
    await s.translation.setView(TranslationView.translation);
    await pumpEventQueue();
    final state = s.translation.state.value;
    final page = s.reader.state.value.pages[0].text.split('\n');
    expect(state.pages[0], hasLength(page.length));
    expect(state.pages[0]!.first, '[tr] ${page.first.trim()}');
    expect(
      state.pages.containsKey(1),
      isTrue,
      reason: 'kaydırmada beklememek için',
    );
    expect(state.status, TranslationStatus.idle);
    _dispose(s);
  });

  test(
    'sayfa değişince yeni sayfa çevrilir; orijinale dönünce çeviri durur',
    () async {
      final s = await _ready();
      await s.translation.setView(TranslationView.both);
      await pumpEventQueue();
      await s.reader.goToPage(5);
      await pumpEventQueue();
      expect(s.translation.state.value.pages.keys, containsAll([0, 1, 5, 6]));

      await s.translation.setView(TranslationView.original);
      final calls = s.engine.translated.length;
      await s.reader.goToPage(9);
      await pumpEventQueue();
      expect(s.engine.translated.length, calls);
      _dispose(s);
    },
  );

  test(
    'dil paketi yoksa onay istenir; reddedilirse görünüm orijinale döner',
    () async {
      final s = await _ready(engine: FakeTranslationEngine(downloaded: {}));
      await s.translation.setView(TranslationView.translation);
      expect(s.translation.state.value.modelPromptPending, isTrue);
      expect(s.engine.translated, isEmpty);

      await s.translation.confirmModelDownload(false);
      expect(s.translation.state.value.modelPromptPending, isFalse);
      expect(s.translation.state.value.view, TranslationView.original);
      expect(s.engine.downloads, isEmpty);
      _dispose(s);
    },
  );

  test('onaylanınca iki dil paketi indirilir ve sayfa çevrilir', () async {
    final s = await _ready(engine: FakeTranslationEngine(downloaded: {}));
    await s.translation.setView(TranslationView.translation);
    await s.translation.confirmModelDownload(true);
    await pumpEventQueue();
    expect(s.engine.downloads, unorderedEquals(['en', 'tr']));
    expect(s.translation.state.value.pages.containsKey(0), isTrue);

    // Paketler artık cihazda: ikinci kez sorulmaz.
    await s.translation.setView(TranslationView.original);
    await s.translation.setView(TranslationView.both);
    expect(s.translation.state.value.modelPromptPending, isFalse);
    _dispose(s);
  });

  test('dil paketi indirilemezse hata gösterilir; tekrar dene onay sormadan indirir', () async {
    final engine = FakeTranslationEngine(downloaded: {})..failDownload = true;
    final s = await _ready(engine: engine);
    await s.translation.setView(TranslationView.translation);
    await s.translation.confirmModelDownload(true);
    expect(s.translation.state.value.status, TranslationStatus.failure);
    expect(s.translation.state.value.failure, TranslationFailure.modelDownload);

    engine.failDownload = false;
    await s.translation.retry();
    await pumpEventQueue();
    expect(s.translation.state.value.modelPromptPending, isFalse);
    expect(s.translation.state.value.failure, isNull);
    expect(s.translation.state.value.pages.containsKey(0), isTrue);
    _dispose(s);
  });

  test('onayı sistem soruyorsa (iOS) uygulama onay istemeden indirir ve çevirir', () async {
    final engine = FakeTranslationEngine(
      downloaded: {},
      systemConfirmsDownload: true,
    );
    final s = await _ready(engine: engine);
    await s.translation.setView(TranslationView.translation);
    await pumpEventQueue();
    expect(s.translation.state.value.modelPromptPending, isFalse);
    expect(s.engine.downloads, unorderedEquals(['en', 'tr']));
    expect(s.translation.state.value.pages.containsKey(0), isTrue);
    _dispose(s);
  });

  test('sistem penceresinde vazgeçilirse görünüm orijinale döner, seçim kapanır', () async {
    final engine = FakeTranslationEngine(
      downloaded: {},
      systemConfirmsDownload: true,
    )..declineDownload = true;
    final s = await _ready(engine: engine);
    await s.translation.setView(TranslationView.both);
    expect(s.translation.state.value.view, TranslationView.original);
    expect(s.translation.state.value.status, TranslationStatus.idle);
    expect(s.translation.state.value.failure, isNull);

    await s.translation.translateSelection('Hello', 1);
    expect(s.translation.state.value.selection, isNull);
    expect(s.engine.translated, isEmpty);
    _dispose(s);
  });

  test('çeviri hatası gösterilir ve tekrar denenebilir', () async {
    final engine = FakeTranslationEngine()..failTranslate = true;
    final s = await _ready(engine: engine);
    await s.translation.setView(TranslationView.translation);
    expect(s.translation.state.value.failure, TranslationFailure.translate);

    engine.failTranslate = false;
    await s.translation.retry();
    await pumpEventQueue();
    expect(s.translation.state.value.status, TranslationStatus.idle);
    expect(s.translation.state.value.pages.containsKey(0), isTrue);
    _dispose(s);
  });

  test(
    'seçilen metin çevrilir; PDF seçiminde satırlar birleştirilir',
    () async {
      final s = await _ready();
      await s.translation.translateSelection('  Hello\n  world ', 3);
      var selection = s.translation.state.value.selection!;
      expect(selection.translated, '[tr] Hello\n[tr] world');
      expect(selection.pageNumber, 3);
      expect(selection.isLoading, isFalse);

      await s.translation.translateSelection(
        'Hel-\nlo there\nfriend',
        7,
        reflow: true,
      );
      selection = s.translation.state.value.selection!;
      expect(selection.text, 'Hello there friend');
      expect(selection.translated, '[tr] Hello there friend');
      expect(selection.reflow, isTrue);

      s.translation.clearSelection();
      expect(s.translation.state.value.selection, isNull);
      _dispose(s);
    },
  );

  test('seçim çevirisi hata verirse tekrar denenebilir', () async {
    final engine = FakeTranslationEngine()..failTranslate = true;
    final s = await _ready(engine: engine);
    await s.translation.translateSelection('Hello', 1);
    expect(
      s.translation.state.value.selection!.failure,
      TranslationFailure.translate,
    );

    engine.failTranslate = false;
    await s.translation.retrySelection();
    expect(s.translation.state.value.selection!.translated, '[tr] Hello');
    expect(s.translation.state.value.selection!.failure, isNull);
    _dispose(s);
  });

  test('desteklenmeyen platformda çeviri sunulmaz', () async {
    final s = await _ready(engine: FakeTranslationEngine(supported: false));
    expect(s.translation.state.value.isAvailable, isFalse);
    await s.translation.setView(TranslationView.translation);
    await s.translation.translateSelection('Hello', 1);
    expect(s.translation.state.value.view, TranslationView.original);
    expect(s.translation.state.value.selection, isNull);
    _dispose(s);
  });

  test('dili bilinmeyen yüklenmiş kitapta dil metinden tanınır ve kitaba kaydedilir', () async {
    final s = await _create(bookId: _userId);
    await s.deps.libraryController.addBook(
      BookModel(
        id: _userId,
        title: 'Sula',
        pageCount: 10,
        addedAt: DateTime(2026),
      ),
    );
    final book = s.deps.libraryController.bookById(_userId)!;
    final imported = await s.deps.digitalBookRepository.importFile(
      book,
      fileName: 'sula.epub',
      bytes: buildEpub(chapters: ['Çok güzel bir gün doğuyordu. ' * 60]),
    );
    await s.deps.libraryController.updateBook(
      book.copyWith(digitalEdition: imported.edition),
    );
    expect(imported.edition.languageCode, '');

    s.translation.init();
    await s.reader.open();
    await pumpEventQueue();
    expect(s.translation.state.value.sourceLanguage, 'tr');
    expect(s.translation.state.value.targetLanguage, 'en');
    expect(
      s.deps.libraryController.bookById(_userId)!.digitalEdition!.languageCode,
      'tr',
    );
    _dispose(s);
  });
}
