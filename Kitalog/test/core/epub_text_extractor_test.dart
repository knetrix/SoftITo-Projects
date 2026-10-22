import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/core/utils/epub_text_extractor.dart';

import '../helpers/test_books.dart';

Matcher _failure(DigitalBookFailure f) =>
    throwsA(isA<DigitalBookException>().having((e) => e.failure, 'failure', f));

void main() {
  test('bölümler spine sırasıyla, başlıklarıyla ve head olmadan çıkarılır', () {
    final text = EpubTextExtractor.extract(buildEpub(chapters: ['İlk.', 'İkinci.', 'Üçüncü.']));
    expect(text, 'Bölüm 1\n\nİlk.\n\nBölüm 2\n\nİkinci.\n\nBölüm 3\n\nÜçüncü.');
    expect(text, isNot(contains('Başlık')), reason: '<head><title> metne girmemeli');
  });

  test('dosyadaki basılı sayfa listesi okunur (EPUB 3 nav, EPUB 2 NCX); yoksa null', () {
    expect(EpubTextExtractor.read(buildEpub(navPages: 37)).pageCount, 37);
    expect(EpubTextExtractor.read(buildEpub(ncxPages: 12)).pageCount, 12);
    expect(EpubTextExtractor.read(buildEpub()).pageCount, isNull);
    expect(EpubTextExtractor.read(buildEpub(navPages: 37)).text, isNot(contains('37')),
        reason: 'spine dışındaki nav metne girmez');
  });

  test('içerik şifreliyse (DRM) korumalı hatası verir; yalnızca font gizleme engel değildir', () {
    expect(() => EpubTextExtractor.extract(buildEpub(encrypted: true)), _failure(DigitalBookFailure.protectedFile));
    expect(EpubTextExtractor.extract(buildEpub(fontObfuscationOnly: true)), contains('Birinci bölümün metni.'));
  });

  test('zip olmayan veya paket dosyası eksik EPUB geçersiz sayılır', () {
    expect(() => EpubTextExtractor.extract(Uint8List.fromList([1, 2, 3])), _failure(DigitalBookFailure.invalidFile));
    expect(() => EpubTextExtractor.extract(buildEpub(chapters: const [])), _failure(DigitalBookFailure.invalidFile));
  });
}
