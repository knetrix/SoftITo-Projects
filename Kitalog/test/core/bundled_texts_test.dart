import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/data/bundled_texts.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/models/digital_edition_model.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/repositories/digital_book_repository.dart';
import 'package:kitalog/core/repositories/digital_sources/gutenberg_source.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/core/repositories/digital_sources/wikisource_source.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/utils/text_cleaner.dart';

import '../helpers/fake_digital_sources.dart';
import '../helpers/test_dependencies.dart';

const _nutukId = 'seed-9786051211879';
String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Nutuk paketlenmiştir, Gutenberg kitapları paketlenmez', () {
    const nutuk = DigitalEditionModel(source: DigitalSource.wikisource, sourceId: 'Nutuk', languageCode: 'tr');
    const frank = DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '84', languageCode: 'en');
    expect(BundledTexts.assetFor(nutuk), 'assets/books/nutuk.txt');
    expect(BundledTexts.assetFor(frank), isNull);
  });

  test('paketlenen Nutuk metni tam, temiz ve seed alıntılarını birebir içerir', () async {
    final text = await rootBundle.loadString('assets/books/nutuk.txt');
    expect(text.length, greaterThan(1000000));
    for (final residue in ['{{', '[[', '{|', '<div', '­', 'Public domain']) {
      expect(text.contains(residue), isFalse, reason: residue);
    }
    final quotes = SeedData.build(DateTime(2026, 10, 22)).quotes.where((q) => q.bookId == _nutukId);
    expect(quotes, isNotEmpty);
    for (final quote in quotes) {
      expect(_norm(text).contains(_norm(quote.text)), isTrue, reason: quote.text);
    }
  });

  test('Nutuk ağ olmadan anında indirilir (paketten) ve okunur', () async {
    final fake = FakeDigitalSources(offline: true);
    final deps = await createTestDependencies(const {}, fake.client);
    await deps.libraryController.load();
    final book = deps.libraryController.bookById(_nutukId)!;
    final copy = await deps.digitalBookRepository.download(book);
    final asset = await rootBundle.loadString('assets/books/nutuk.txt');
    expect(copy.charCount, TextCleaner.reflowParagraphs(asset).length);
    expect(await deps.digitalBookRepository.readText(_nutukId), TextCleaner.reflowParagraphs(asset));
    expect(fake.requests, isEmpty, reason: 'paketlenmiş metin için ağa çıkılmamalı');
  });

  test('paket okunamazsa kaynağından indirilir', () async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final fake = FakeDigitalSources(wikitext: {'Nutuk': 'Kaynaktan gelen Nutuk metni.'});
    final http = SourceHttp(client: fake.client, minInterval: Duration.zero);
    final repo = DigitalBookRepository(
      storage: await testStorage(),
      files: MemoryDigitalFileStorage(),
      gutenberg: GutenbergSource(http),
      wikisource: WikisourceSource(http),
      loadAsset: (_) async => throw Exception('asset yok'),
    );
    await repo.download(deps.libraryController.bookById(_nutukId)!);
    expect(await repo.readText(_nutukId), 'Kaynaktan gelen Nutuk metni.');
  });
}
