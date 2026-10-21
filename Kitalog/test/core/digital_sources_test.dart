import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kitalog/core/repositories/digital_sources/gutenberg_source.dart';
import 'package:kitalog/core/repositories/digital_sources/source_http.dart';
import 'package:kitalog/core/repositories/digital_sources/wikisource_source.dart';

import '../helpers/fake_digital_sources.dart';

Matcher _failure(DigitalBookFailure f) =>
    throwsA(isA<DigitalBookException>().having((e) => e.failure, 'failure', f));

void main() {
  test('429 yanıtında bekleyip yeniden dener, sınır aşılınca sunucu hatası verir', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return calls < 3 ? http.Response('slow', 429) : http.Response('tamam', 200);
    });
    final ok = SourceHttp(client: client, retryDelay: Duration.zero, minInterval: Duration.zero);
    expect(await ok.getText(Uri.parse('https://x.org')), 'tamam');
    expect(calls, 3);

    final always = SourceHttp(
      client: MockClient((_) async => http.Response('', 429)),
      retryDelay: Duration.zero,
      minInterval: Duration.zero,
    );
    await expectLater(always.getText(Uri.parse('https://x.org')), _failure(DigitalBookFailure.server));
  });

  test('istekler arasında en kısa bekleme süresine uyulur', () async {
    final times = <DateTime>[];
    final client = MockClient((_) async {
      times.add(DateTime.now());
      return http.Response('ok', 200);
    });
    final paced = SourceHttp(client: client, minInterval: const Duration(milliseconds: 120));
    for (var i = 0; i < 3; i++) {
      await paced.getText(Uri.parse('https://x.org'));
    }
    for (var i = 1; i < times.length; i++) {
      expect(times[i].difference(times[i - 1]).inMilliseconds, greaterThanOrEqualTo(110));
    }
  });

  test('istek başlıkları yalnızca ASCII karakter içerir', () {
    // İletişim URL'si olmayan istemciyi Wikimedia dakikada 10 istekle sınırlar.
    expect(SourceHttp.headers['User-Agent'], contains('https://'));
    for (final value in SourceHttp.headers.values) {
      expect(value.codeUnits.every((c) => c < 128), isTrue, reason: value);
    }
  });

  group('Gutenberg', () {
    test('metni indirir ve lisans bloklarını atar', () async {
      final fake = FakeDigitalSources(gutenbergTexts: {'84': 'Frankenstein metni'});
      final source = GutenbergSource(SourceHttp(client: fake.client, minInterval: Duration.zero));
      expect(await source.fetchText('84'), 'Frankenstein metni');
      expect(fake.requests.single.toString(), 'https://www.gutenberg.org/cache/epub/84/pg84.txt');
    });

    test('olmayan kitap notFound, ağ yokken network hatası verir', () async {
      final missing = GutenbergSource(SourceHttp(client: FakeDigitalSources().client, minInterval: Duration.zero));
      await expectLater(missing.fetchText('1'), _failure(DigitalBookFailure.notFound));
      final offline = GutenbergSource(SourceHttp(client: FakeDigitalSources(offline: true).client, minInterval: Duration.zero));
      await expectLater(offline.fetchText('1'), _failure(DigitalBookFailure.network));
    });
  });

  group('Vikikaynak', () {
    const book = {
      'Eser': "{{Eser başlık|başlık=Eser}}\n{|\n| [[/1. bölüm|Birinci bölüm]]\n|-\n| [[/2. bölüm|İkinci bölüm]]\n|}",
      'Eser/1. bölüm': '{{eser başlığı|önceki=[[Eser|İçindekiler]]|sonraki=[[/A|Alt A]]}}\n{|\n| [[/A|Alt A]]\n|-\n| [[/B|Alt B]]\n|}',
      'Eser/1. bölüm/A': '{{eser|önceki=[[Eser/1. bölüm]]|sonraki=[[Eser/1. bölüm/B|Alt B]]}}\nA kısmının metni.',
      'Eser/1. bölüm/B': "B kısmının ''metni''.",
      'Eser/2. bölüm': '{{eser|önceki=[[Eser/1. bölüm/B]]}}\nİkinci bölümün metni.',
    };

    test('alt sayfaları sayfadaki sırayla, başlıklarıyla birleştirir', () async {
      final fake = FakeDigitalSources(wikitext: book);
      final text = await WikisourceSource(SourceHttp(client: fake.client, minInterval: Duration.zero)).fetchText('Eser');
      final order = [
        'Birinci bölüm',
        'Alt A',
        'A kısmının metni.',
        'Alt B',
        'B kısmının metni.',
        'İkinci bölüm',
        'İkinci bölümün metni.',
      ];
      var last = -1;
      for (final part in order) {
        final index = text.indexOf(part, last + 1);
        expect(index, greaterThan(last), reason: part);
        last = index;
      }
      expect(text, isNot(contains('{{')));
      // Seviye başına toplu istek: kök, bölümler, kısımlar.
      expect(fake.wikiQueryCount, 3);
    });

    test('50\'den fazla alt sayfa birden çok toplu isteğe bölünür', () async {
      final pages = <String, String>{
        'Uzun': [for (var i = 0; i < 60; i++) '[[/K$i|K$i]]'].join(' '),
        for (var i = 0; i < 60; i++) 'Uzun/K$i': 'metin $i',
      };
      final fake = FakeDigitalSources(wikitext: pages);
      final text = await WikisourceSource(SourceHttp(client: fake.client, minInterval: Duration.zero)).fetchText('Uzun');
      expect(text, contains('metin 59'));
      expect(fake.wikiQueryCount, 3);
    });

    test('taranmış kaynaktan gömülü sayfa işlenmiş HTML\'den okunur', () async {
      final fake = FakeDigitalSources(
        wikitext: {'Roman': '{{eser başlığı}}\n<pages index="Roman.djvu" from=1 to=9 />'},
        renderedHtml: {'Roman': '<div class="ws-noexport">gezinme</div><p>Romanın ilk cümlesi.</p>'},
      );
      final text = await WikisourceSource(SourceHttp(client: fake.client, minInterval: Duration.zero)).fetchText('Roman');
      expect(text, 'Romanın ilk cümlesi.');
    });

    test('olmayan eser notFound verir', () async {
      final source = WikisourceSource(SourceHttp(client: FakeDigitalSources().client, minInterval: Duration.zero));
      await expectLater(source.fetchText('Yok'), _failure(DigitalBookFailure.notFound));
    });

    test('göreli bağlantılar çözülür; kardeş ve üst bağlantılar alt sayfa sayılmaz', () {
      expect(WikisourceSource.resolve('Nutuk', '/1. bölüm'), 'Nutuk/1. bölüm');
      expect(WikisourceSource.resolve('Nutuk/1. bölüm', '/A_b/'), 'Nutuk/1. bölüm/A b');
      expect(WikisourceSource.resolve('Kitap/Bölüm 1', '../Bölüm 2'), 'Kitap/Bölüm 2');
      expect(WikisourceSource.resolve('Kitap/Bölüm 1', 'Başka Eser'), 'Başka Eser');
      final links = WikisourceSource.childLinks(
        'Kitap/Bölüm 1',
        '[[../Bölüm 2]] [[Kitap]] [[/Kısım|Kısım adı]] [[/Kısım]] [[Kitap/Bölüm 1/Son]]',
      );
      expect(links.map((l) => l.title), ['Kitap/Bölüm 1/Kısım', 'Kitap/Bölüm 1/Son']);
      expect(links.first.label, 'Kısım adı');
    });
  });
}
