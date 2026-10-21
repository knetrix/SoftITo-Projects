import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/digital_edition_model.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/repositories/digital_book_repository.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/core/constants/storage_keys.dart';
import 'package:kitalog/core/models/digital_copy_model.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/utils/reading_text_cleaner.dart';
import 'package:kitalog/core/utils/text_cleaner.dart';

import 'dart:typed_data';

import 'package:kitalog/core/models/digital_format.dart';
import 'package:kitalog/core/models/digital_source.dart' show DigitalSource;

import '../helpers/fake_digital_sources.dart';
import '../helpers/test_books.dart';
import '../helpers/test_dependencies.dart';

BookModel _book({
  String id = 'b1',
  BookGenre genre = BookGenre.novel,
  bool digital = true,
}) {
  return BookModel(
    id: id,
    title: 'Test',
    pageCount: 100,
    genre: genre,
    addedAt: DateTime(2026),
    digitalEdition: digital
        ? const DigitalEditionModel(
            source: DigitalSource.gutenberg,
            sourceId: '7',
            languageCode: 'en',
          )
        : null,
  );
}

class _FailingStorage extends MemoryDigitalFileStorage {
  @override
  Future<void> write(String fileName, String text) async =>
      throw Exception('disk dolu');
}

Future<DigitalBookRepository> _repo(
  FakeDigitalSources fake, {
  DigitalFileStorage? files,
}) async {
  final deps = await createTestDependencies(const {}, fake.client, files);
  return deps.digitalBookRepository;
}

Matcher _failure(DigitalBookFailure f) =>
    throwsA(isA<DigitalBookException>().having((e) => e.failure, 'failure', f));

void main() {
  const prose = 'Birinci satır\ndevamı.\n\nİkinci paragraf.';

  test('indirir, düzyazıyı birleştirir, kaydeder ve okur', () async {
    final repo = await _repo(FakeDigitalSources(gutenbergTexts: {'7': prose}));
    final progress = <double>[];
    final copy = await repo.download(_book(), onProgress: progress.add);
    expect(copy.fileName, 'b1.txt');
    expect(progress.last, 1.0);
    expect(
      await repo.readText('b1'),
      'Birinci satır devamı.\n\nİkinci paragraf.',
    );
    expect((await repo.getCopies()).single.charCount, copy.charCount);
    expect(repo.supportsOffline, isFalse, reason: 'testte bellek içi depolama');
  });

  test('şiirde satır sonları korunur', () async {
    final repo = await _repo(FakeDigitalSources(gutenbergTexts: {'7': prose}));
    await repo.download(_book(genre: BookGenre.poetry));
    expect(await repo.readText('b1'), prose);
  });

  group('okuma metni temizliği', () {
    const body =
        'Letter 1\n\nYou will rejoice to hear that no disaster has accompanied the commencement of\n'
        'an enterprise which you have regarded with such _evil_ forebodings.[1] I arrived\n'
        'here yesterday, and my first task is to assure my dear sister of my welfare.';
    const raw =
        'Frankenstein;\n\nby Mary Shelley\n\nCONTENTS\n\n Letter 1\n Letter 2\n Chapter 1\n\n$body';
    const cleaned =
        'Letter 1\n\nYou will rejoice to hear that no disaster has accompanied the commencement of '
        'an enterprise which you have regarded with such evil forebodings. I arrived '
        'here yesterday, and my first task is to assure my dear sister of my welfare.';

    test(
      'indirilen metinde biçim işaretleri ve kitap başı temizlenir',
      () async {
        final repo = await _repo(
          FakeDigitalSources(gutenbergTexts: {'7': raw}),
        );
        final copy = await repo.download(_book());
        expect(await repo.readText('b1'), cleaned);
        expect(copy.textVersion, ReadingTextCleaner.version);
      },
    );

    Future<(DigitalBookRepository, MemoryDigitalFileStorage)> oldCopy(
      FakeDigitalSources fake,
    ) async {
      // Temizlik kuralları gelmeden önce kaydedilmiş kopya (textVersion yok).
      final old = TextCleaner.reflowParagraphs(raw);
      final files = MemoryDigitalFileStorage();
      await files.write('b1.txt', old);
      final copy = DigitalCopyModel(
        bookId: 'b1',
        fileName: 'b1.txt',
        charCount: old.length,
        downloadedAt: DateTime(2026),
        lastOffset: old.length ~/ 2,
      );
      final deps = await createTestDependencies(
        {
          StorageKeys.digital: jsonEncode([
            copy.toJson()..remove('textVersion'),
          ]),
        },
        fake.client,
        files,
      );
      return (deps.digitalBookRepository, files);
    }

    test('eski kopya açılırken çevrimiçiyse kaynağından yeniden temizlenir; ilerleme oranı korunur', () async {
      final (repo, files) = await oldCopy(
        FakeDigitalSources(gutenbergTexts: {'7': raw}),
      );
      expect(
        await repo.readText('b1'),
        contains('CONTENTS'),
        reason: 'kitap verilmezse dokunulmaz',
      );
      expect(await repo.readText('b1', book: _book()), cleaned);
      expect(await files.read('b1.txt'), cleaned);
      final copy = (await repo.copyOf('b1'))!;
      expect(copy.textVersion, ReadingTextCleaner.version);
      expect(copy.charCount, cleaned.length);
      expect(copy.progress, closeTo(0.5, 0.01));
    });

    test('eski kopya çevrimdışıyken cihazdaki metinden temizlenir', () async {
      final fake = FakeDigitalSources(offline: true);
      final (repo, _) = await oldCopy(fake);
      expect(await repo.readText('b1', book: _book()), cleaned);
      fake.requests.clear();
      expect(await repo.readText('b1', book: _book()), cleaned);
      expect(
        fake.requests,
        isEmpty,
        reason: 'güncel kopya yeniden temizlenmez',
      );
    });
  });

  test(
    'kalınan yer kaydedilir, sınırlanır ve yeniden indirmede korunur',
    () async {
      final repo = await _repo(
        FakeDigitalSources(gutenbergTexts: {'7': prose}),
      );
      final copy = await repo.download(_book());
      await repo.savePosition('b1', 10);
      expect((await repo.copyOf('b1'))!.lastOffset, 10);
      await repo.savePosition('b1', 99999);
      expect((await repo.copyOf('b1'))!.lastOffset, copy.charCount);
      await repo.download(_book());
      expect((await repo.copyOf('b1'))!.lastOffset, copy.charCount);
    },
  );

  test(
    'silme dosyayı ve kaydı kaldırır; kaybolan dosyada kayıt temizlenir',
    () async {
      final files = MemoryDigitalFileStorage();
      final repo = await _repo(
        FakeDigitalSources(gutenbergTexts: {'7': prose}),
        files: files,
      );
      await repo.download(_book());
      await repo.delete('b1');
      expect(await repo.copyOf('b1'), isNull);
      expect(await repo.readText('b1'), isNull);

      await repo.download(_book());
      await files.delete('b1.txt');
      expect(await repo.readText('b1'), isNull);
      expect(await repo.copyOf('b1'), isNull);
    },
  );

  test(
    'dijital sürümü olmayan kitap, ağ ve depolama hataları ayrı bildirilir',
    () async {
      final repo = await _repo(
        FakeDigitalSources(gutenbergTexts: {'7': prose}),
      );
      await expectLater(
        repo.download(_book(digital: false)),
        _failure(DigitalBookFailure.unavailable),
      );
      final offline = await _repo(FakeDigitalSources(offline: true));
      await expectLater(
        offline.download(_book()),
        _failure(DigitalBookFailure.network),
      );
      final full = await _repo(
        FakeDigitalSources(gutenbergTexts: {'7': prose}),
        files: _FailingStorage(),
      );
      await expectLater(
        full.download(_book()),
        _failure(DigitalBookFailure.storage),
      );
      expect(await full.copyOf('b1'), isNull);
    },
  );

  test(
    'EPUB içe aktarılır: metin saklanır, kaynak kullanıcı dosyasıdır',
    () async {
      final repo = await _repo(FakeDigitalSources());
      final result = await repo.importFile(
        _book(digital: false),
        fileName: 'kitap.epub',
        bytes: buildEpub(),
      );
      expect(result.edition.source, DigitalSource.localFile);
      expect(result.edition.format, DigitalFormat.text);
      expect(result.copy.byteSize, greaterThan(0));
      expect(await repo.readText('b1'), contains('İkinci bölümün metni.'));
      expect(await repo.readPdf('b1'), isNull);
    },
  );

  test('PDF içe aktarılır, sayfa sayısı ve konum saklanır; EPUB ile değiştirilebilir', () async {
    final repo = await _repo(FakeDigitalSources());
    final result = await repo.importFile(
      _book(digital: false),
      fileName: 'kitap.pdf',
      bytes: fakePdfBytes(),
    );
    expect(result.edition.format, DigitalFormat.pdf);
    expect(result.copy.charCount, 0);
    expect(await repo.readPdf('b1'), fakePdfBytes());
    expect(await repo.readText('b1'), isNull);
    await repo.updateLength('b1', 120);
    await repo.savePosition('b1', 30);
    final copy = (await repo.copyOf('b1'))!;
    expect(copy.charCount, 120);
    expect(copy.progress, 0.25);

    await repo.importFile(
      _book(digital: false),
      fileName: 'kitap.epub',
      bytes: buildEpub(),
    );
    expect(await repo.readPdf('b1'), isNull);
    expect((await repo.copyOf('b1'))!.format, DigitalFormat.text);
  });

  test(
    'desteklenmeyen, bozuk ve çok büyük dosyalar ayrı hatalarla reddedilir',
    () async {
      final repo = await _repo(FakeDigitalSources());
      final book = _book(digital: false);
      final text = Uint8List.fromList('düz metin'.codeUnits);
      await expectLater(
        repo.importFile(book, fileName: 'a.txt', bytes: text),
        _failure(DigitalBookFailure.unsupportedFile),
      );
      await expectLater(
        repo.importFile(book, fileName: 'a.pdf', bytes: text),
        _failure(DigitalBookFailure.invalidFile),
      );
      await expectLater(
        repo.importFile(
          book,
          fileName: 'a.pdf',
          bytes: Uint8List(DigitalBookRepository.maxImportBytes + 1),
        ),
        _failure(DigitalBookFailure.tooLarge),
      );
      expect(await repo.copyOf('b1'), isNull);
    },
  );

  test('kullanıcı dosyası yeniden indirilemez', () async {
    final repo = await _repo(FakeDigitalSources());
    final result = await repo.importFile(
      _book(digital: false),
      fileName: 'k.epub',
      bytes: buildEpub(),
    );
    final linked = _book(digital: false)
        .copyWith(digitalEdition: result.edition);
    await expectLater(
      repo.download(linked),
      _failure(DigitalBookFailure.fileMissing),
    );
  });
}
