import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/repositories/translation/translation_engine.dart';
import 'package:kitalog/core/repositories/translation_repository.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';

import '../helpers/fake_translation_engine.dart';

void main() {
  late FakeTranslationEngine engine;
  late MemoryDigitalFileStorage files;
  late TranslationRepository repository;

  setUp(() {
    engine = FakeTranslationEngine();
    files = MemoryDigitalFileStorage();
    repository = TranslationRepository(engine: engine, files: files);
  });

  test('çeviri yalnızca İngilizce ↔ Türkçe', () {
    expect(TranslationRepository.targetFor('en'), 'tr');
    expect(TranslationRepository.targetFor('tr'), 'en');
    expect(TranslationRepository.targetFor('fr'), isNull);
    expect(TranslationRepository.targetFor(''), isNull);
  });

  test(
    'satırlar çevrilir; boş satırlar boş kalır ve satır sayısı korunur',
    () async {
      final lines = await repository.translateLines(
        'k1',
        ['Hello', '', '  World  '],
        from: 'en',
        to: 'tr',
      );
      expect(lines, ['[tr] Hello', '', '[tr] World']);
      expect(engine.translated, ['Hello', 'World']);
    },
  );

  test(
    'çevrilen satır önbellekten gelir; önbellek dosyada kalıcıdır',
    () async {
      await repository.translateLines(
        'k1',
        ['Hello', 'World'],
        from: 'en',
        to: 'tr',
      );
      await repository.translateLines(
        'k1',
        ['World', 'Again'],
        from: 'en',
        to: 'tr',
      );
      expect(engine.translated, [
        'Hello',
        'World',
        'Again',
      ], reason: '"World" ikinci kez çevrilmez');

      // Uygulama yeniden açılınca (yeni repository) önbellek dosyadan okunur.
      final reopened = TranslationRepository(engine: engine, files: files);
      final lines = await reopened.translateLines(
        'k1',
        ['Hello'],
        from: 'en',
        to: 'tr',
      );
      expect(lines, ['[tr] Hello']);
      expect(engine.translated.length, 3);
      expect(
        await files.read(TranslationRepository.cacheFileName('k1', 'en', 'tr')),
        isNotNull,
      );
    },
  );

  test('önbellek kitaba ve dil yönüne özeldir', () async {
    await repository.translateLines('k1', ['Merhaba'], from: 'tr', to: 'en');
    await repository.translateLines('k2', ['Merhaba'], from: 'tr', to: 'en');
    expect(engine.translated, ['Merhaba', 'Merhaba']);
  });

  test('seçilen metin satır yapısı korunarak çevrilir', () async {
    expect(
      await repository.translateText('k1', 'Bir\nİki', from: 'tr', to: 'en'),
      '[en] Bir\n[en] İki',
    );
  });

  test('clearCache kitabın önbelleğini siler', () async {
    await repository.translateLines('k1', ['Hello'], from: 'en', to: 'tr');
    await repository.clearCache('k1');
    expect(
      await files.read(TranslationRepository.cacheFileName('k1', 'en', 'tr')),
      isNull,
    );
    await repository.translateLines('k1', ['Hello'], from: 'en', to: 'tr');
    expect(engine.translated, ['Hello', 'Hello']);
  });

  test('bozuk önbellek yok sayılır', () async {
    await files.write(
      TranslationRepository.cacheFileName('k1', 'en', 'tr'),
      '{bozuk',
    );
    expect(
      await repository.translateLines('k1', ['Hello'], from: 'en', to: 'tr'),
      ['[tr] Hello'],
    );
  });

  test('çeviri yarıda hata verirse o ana kadar çevrilenler saklanır', () async {
    await repository.translateLines('k1', ['Hello'], from: 'en', to: 'tr');
    engine.failTranslate = true;
    await expectLater(
      repository.translateLines('k1', ['Hello', 'World'], from: 'en', to: 'tr'),
      throwsA(isA<TranslationException>()),
    );
    engine.failTranslate = false;
    await repository.translateLines(
      'k1',
      ['Hello', 'World'],
      from: 'en',
      to: 'tr',
    );
    expect(engine.translated, ['Hello', 'World']);
  });

  test('yalnızca eksik dil paketleri indirilir', () async {
    final engine = FakeTranslationEngine(downloaded: {'en'});
    final repository = TranslationRepository(engine: engine, files: files);
    expect(await repository.needsModelDownload('en', 'tr'), isTrue);
    await repository.downloadModels('en', 'tr');
    expect(engine.downloads, ['tr']);
    expect(await repository.needsModelDownload('en', 'tr'), isFalse);
  });

  test('desteklenmeyen platformda dil tanınmaz', () async {
    final repository = TranslationRepository(
      engine: const UnsupportedTranslationEngine(),
      files: files,
    );
    expect(repository.isSupported, isFalse);
    expect(await repository.detectLanguage('Hello world'), '');
  });
}
