import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/text_cleaner.dart';

void main() {
  group('Gutenberg', () {
    const raw = 'The Project Gutenberg eBook of Test\r\nLicense text\r\n'
        '*** START OF THE PROJECT GUTENBERG EBOOK TEST ***\r\n\r\n\r\n\r\n'
        'CHAPTER I\r\n\r\nIt was a dark\r\nand stormy night.\r\n\r\n'
        '*** END OF THE PROJECT GUTENBERG EBOOK TEST ***\r\nMore license';

    test('lisans başlığı ve bitiş bloğu atılır', () {
      final text = TextCleaner.stripGutenbergBoilerplate(raw);
      expect(text.startsWith('CHAPTER I'), isTrue);
      expect(text, isNot(contains('License')));
      expect(text, isNot(contains('More license')));
      expect(text, isNot(contains('\r')));
    });

    test('işaret yoksa metin olduğu gibi kalır', () {
      expect(TextCleaner.stripGutenbergBoilerplate('Sadece metin'), 'Sadece metin');
    });

    test('kısa satırlardan oluşan blok (içindekiler) satır satır korunur', () {
      const toc = 'CONTENTS\n\nCHAPTER I\nCHAPTER II\nCHAPTER III\n\nThis long paragraph line is wrapped at about seventy\ncharacters as Gutenberg does it.';
      expect(
        TextCleaner.reflowParagraphs(toc),
        'CONTENTS\n\nCHAPTER I\nCHAPTER II\nCHAPTER III\n\nThis long paragraph line is wrapped at about seventy characters as Gutenberg does it.',
      );
    });

    test('paragraflar birleştirilir, paragraf ayracı korunur', () {
      final text = TextCleaner.reflowParagraphs(TextCleaner.stripGutenbergBoilerplate(raw));
      expect(text, 'CHAPTER I\n\nIt was a dark and stormy night.');
    });
  });

  test('görünmez yumuşak tireler atılır', () {
    expect(TextCleaner.htmlToText('<p>önün\u00ADde</p>'), 'önünde');
    expect(TextCleaner.stripGutenbergBoilerplate('ka\u00ADdar'), 'kadar');
  });

  test('HTML entity çözümü (adlı ve sayısal)', () {
    expect(
      TextCleaner.decodeHtmlEntities('A &amp; B &#8220;x&#8221; &#x15F; &hellip; &bilinmez;'),
      'A & B “x” ş … &bilinmez;',
    );
  });

  test('wikitext şablon, bağlantı, biçim ve dipnotlardan temizlenir', () {
    const wikitext = '{{eser başlığı | önceki = [[A]] | sonraki = {{iç|x}} }}\n'
        "== Birinci Bölüm ==\n'''Kalın''' ve ''eğik'' [[Nutuk/1. bölüm|bağlantı]] [[Samsun]]"
        '<ref>dipnot</ref> [https://ornek.org dış bağlantı]<br/>yeni satır\n'
        '[[Kategori:Romanlar]]<!-- yorum -->';
    final text = TextCleaner.cleanWikitext(wikitext);
    expect(text, contains('Birinci Bölüm'));
    expect(text, contains('Kalın ve eğik bağlantı Samsun dış bağlantı\nyeni satır'));
    expect(text, isNot(contains('{{')));
    expect(text, isNot(contains('dipnot')));
    expect(text, isNot(contains('Kategori')));
    expect(text, isNot(contains('yorum')));
  });

  test('kapanışı eksik şablonun içeriği korunur, işaretleri atılır', () {
    expect(TextCleaner.cleanWikitext('Tarih: {{orta|23.10.335} sonra'), 'Tarih: 23.10.335 sonra');
    // Tablo temizliği kapanış parantezine ihtiyaç duyar; sıra bozulursa tablo metne sızar.
    expect(TextCleaner.cleanWikitext('{|\n| [[/A|A]]\n|}\nMetin'), 'Metin');
  });

  test('işlenmiş HTML düz metne çevrilir; gezinme, sayfa no ve düzenleme atılır', () {
    const html = '<div class="ws-noexport"><span>Önceki | Sonraki</span></div>'
        '<p>Şimdiye kadar <b>tesadüf</b> ettiğim<span class="pagenum">[5]</span> insanlar&nbsp;arasında</p>'
        '<h2>Bölüm<span class="mw-editsection">[düzenle]</span></h2>'
        '<p>İkinci<sup class="reference">[1]</sup> paragraf<br>satır</p><style>.x{}</style>';
    final text = TextCleaner.htmlToText(html);
    expect(text, 'Şimdiye kadar tesadüf ettiğim insanlar arasında\n\nBölüm\n\nİkinci paragraf\nsatır');
  });

  test('işlenmiş HTML\'de düz metin kalan bozuk şablon temizlenir', () {
    expect(TextCleaner.htmlToText('<p>hazretleri.\n{{orta|23.10.335}</p>'), 'hazretleri.\n23.10.335');
  });

  test('lisans kutusu, başlık şablonu ve dipnot listesi atılır', () {
    const html = '<div class="headertemplate"><b>ROMAN</b> Yazar</div><p>Metin.</p>'
        '<div class="licenseContainer licenseBanner"><p>koruma süresi dolmuştur</p></div>'
        '<div class="licensetpl" style="display:none"><span>Public domain</span></div>'
        '<div class="reflist"><ol class="references"><li><span class="mw-cite-backlink">↑</span> not</li></ol></div>'
        '<div class="notheme"><p><b>Kaynak:</b> metin</p><div class="licFrame-top"><p>Telif</p></div></div>';
    expect(TextCleaner.htmlToText(html), 'Metin.');
  });
}
