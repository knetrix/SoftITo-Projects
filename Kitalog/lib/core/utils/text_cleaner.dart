/// Dijital kaynaklardan gelen ham metni okunabilir düz metne çeviren saf fonksiyonlar.
abstract final class TextCleaner {
  static final RegExp _gutenbergStart = RegExp(
    r'^\*\*\*\s*START OF (THE|THIS) PROJECT GUTENBERG.*$',
    caseSensitive: false,
    multiLine: true,
  );
  static final RegExp _gutenbergEnd = RegExp(
    r'^\*\*\*\s*END OF (THE|THIS) PROJECT GUTENBERG.*$',
    caseSensitive: false,
    multiLine: true,
  );

  static const Map<String, String> _namedEntities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'shy': '',
    'hellip': '…',
    'mdash': '—',
    'ndash': '–',
    'lsquo': '‘',
    'rsquo': '’',
    'ldquo': '“',
    'rdquo': '”',
    'laquo': '«',
    'raquo': '»',
  };

  /// Satır sonlarını `\n`'e çevirir ve görünmez yumuşak tireleri (U+00AD) atar;
  /// aksi halde arama ve alıntı eşleştirmesi bozulur.
  static String normalizeNewlines(String text) => text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\u00AD', '');

  /// Gutenberg'in lisans başlığını ve bitiş bloğunu atar.
  static String stripGutenbergBoilerplate(String raw) {
    var text = normalizeNewlines(raw);
    final start = _gutenbergStart.firstMatch(text);
    if (start != null) text = text.substring(start.end);
    final end = _gutenbergEnd.firstMatch(text);
    if (end != null) text = text.substring(0, end.start);
    return collapseBlankLines(text).trim();
  }

  /// En az 3 satırı olan ve tüm satırları bu uzunluğun altında kalan bloklar
  /// (içindekiler, liste, dize) birleştirilmez; Gutenberg düzyazı satırları ~70 karakterdir.
  static const int shortLineLimit = 45;

  /// Tek satır sonlarıyla bölünmüş paragrafları birleştirir; boş satırlar
  /// paragraf ayracı olarak korunur. Şiir kitaplarında çağrılmaz.
  static String reflowParagraphs(String text) {
    final paragraphs = collapseBlankLines(normalizeNewlines(text)).split('\n\n');
    return paragraphs
        .map((p) {
          final lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
          final isList = lines.length >= 3 && lines.every((l) => l.length < shortLineLimit);
          return lines.join(isList ? '\n' : ' ');
        })
        .where((p) => p.isNotEmpty)
        .join('\n\n');
  }

  /// Üç ve daha fazla ardışık satır sonunu paragraf ayracına indirir.
  static String collapseBlankLines(String text) {
    return text
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  static String decodeHtmlEntities(String text) {
    return text.replaceAllMapped(
      RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);'),
      (m) {
        final code = m.group(1)!;
        if (code.startsWith('#x') || code.startsWith('#X')) {
          final value = int.tryParse(code.substring(2), radix: 16);
          return value == null ? m.group(0)! : String.fromCharCode(value);
        }
        if (code.startsWith('#')) {
          final value = int.tryParse(code.substring(1));
          return value == null ? m.group(0)! : String.fromCharCode(value);
        }
        return _namedEntities[code] ?? m.group(0)!;
      },
    );
  }

  /// Vikikaynak wikitext'ini düz metne çevirir.
  static String cleanWikitext(String wikitext) {
    var text = normalizeNewlines(wikitext);
    text = text.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<ref[^>]*/>'), '');
    text = text.replaceAll(RegExp(r'<ref[^>]*>.*?</ref>', dotAll: true), '');
    // İç içe şablonlar içten dışa doğru temizlenir.
    final template = RegExp(r'\{\{[^{}]*\}\}', dotAll: true);
    while (template.hasMatch(text)) {
      text = text.replaceAll(template, '');
    }
    text = text.replaceAll(RegExp(r'\{\|.*?\|\}', dotAll: true), '');
    // Kaynakta kapanışı eksik şablonlar (ör. `{{orta|23.10.335}`) içerikleri korunarak temizlenir.
    text = text.replaceAll(RegExp(r'\{\{[^|{}\n]*\|'), '').replaceAll(RegExp(r'\}+'), '');
    text = text.replaceAll(
      RegExp(r'\[\[(Kategori|Category|Dosya|File|Resim|Image):[^\]]*\]\]', caseSensitive: false),
      '',
    );
    text = text.replaceAllMapped(RegExp(r'\[\[[^\]|]*\|([^\]]*)\]\]'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'\[\[([^\]]*)\]\]'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'\[https?://\S+\s+([^\]]*)\]'), (m) => m.group(1)!);
    text = text.replaceAll(RegExp(r"'{2,}"), '');
    text = text.replaceAllMapped(
      RegExp(r'^=+\s*(.*?)\s*=+\s*$', multiLine: true),
      (m) => '\n${m.group(1)!}\n',
    );
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll(RegExp(r'^[:;*#]+\s*', multiLine: true), '');
    return collapseBlankLines(decodeHtmlEntities(text)).trim();
  }

  /// Kaynakta kapanışı eksik kaldığı için ayrıştırıcının düz metin olarak bıraktığı
  /// şablonları (ör. `{{orta|23.10.335}`) içerikleri korunarak temizler.
  static String stripBrokenTemplates(String text) => text.replaceAllMapped(
    RegExp(r'\{\{[^|{}\n]*\|([^{}\n]*)\}{1,2}'),
    (m) => m.group(1)!,
  );

  /// MediaWiki'nin işlediği HTML'i düz metne çevirir; gezinme kutuları,
  /// düzenleme bağlantıları, sayfa numaraları ve dipnot işaretleri atılır.
  static String htmlToText(String html) {
    var text = normalizeNewlines(html);
    text = text.replaceAll(RegExp(r'<(style|script)[^>]*>.*?</\1>', dotAll: true, caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    // Gezinme/başlık kutuları, lisans kutusu, sayfa numaraları ve dipnotlar okuma metnine ait değildir.
    for (final cls in [
      'ws-noexport',
      'headertemplate',
      'mw-editsection',
      'pagenum',
      'ws-pagenum',
      'reference',
      'references',
      'reflist',
      'mw-references-wrap',
      'mw-cite-backlink',
      'licenseContainer',
      'licFrame-top',
      'licensetpl',
      'notheme',
    ]) {
      text = _removeElementsWithClass(text, cls);
    }
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(
      RegExp(r'</?(p|div|li|tr|h[1-6]|blockquote|table|dd|dt)[^>]*>', caseSensitive: false),
      '\n\n',
    );
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = decodeHtmlEntities(text);
    text = stripBrokenTemplates(text);
    text = text.split('\n').map((l) => l.replaceAll(RegExp(r'[ \t]+'), ' ').trim()).join('\n');
    return collapseBlankLines(text).trim();
  }

  /// Belirtilen sınıfı taşıyan elemanları (aynı etiketin iç içe kullanımı dahil) siler.
  static String _removeElementsWithClass(String html, String cls) {
    final open = RegExp(
      '<(\\w+)\\b[^>]*class="[^"]*\\b${RegExp.escape(cls)}\\b[^"]*"[^>]*>',
      caseSensitive: false,
    );
    var text = html;
    var match = open.firstMatch(text);
    while (match != null) {
      final tag = match.group(1)!.toLowerCase();
      final end = _matchingCloseIndex(text, tag, match.end);
      text = text.substring(0, match.start) + text.substring(end);
      match = open.firstMatch(text);
    }
    return text;
  }

  static int _matchingCloseIndex(String html, String tag, int from) {
    final pattern = RegExp('<(/?)$tag\\b[^>]*>', caseSensitive: false);
    var depth = 1;
    for (final m in pattern.allMatches(html, from)) {
      final isClose = m.group(1) == '/';
      final selfClosing = m.group(0)!.endsWith('/>');
      if (isClose) {
        depth--;
      } else if (!selfClosing) {
        depth++;
      }
      if (depth == 0) return m.end;
    }
    return html.length;
  }
}
