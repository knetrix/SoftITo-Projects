import '../../utils/text_cleaner.dart';
import 'source_http.dart';

/// Türkçe Vikikaynak (MediaWiki API). Bir eserin kök sayfasından başlayıp alt
/// sayfalarını sayfadaki sırayla (derinlik öncelikli) toplar ve tek metin yapar.
class WikisourceSource {
  WikisourceSource(this._http, {this.host = 'tr.wikisource.org'});

  static const int batchSize = 50;
  static const int maxPages = 1500;
  static const int maxDepth = 6;

  final SourceHttp _http;
  final String host;

  Uri _api(Map<String, String> params) =>
      Uri.https(host, '/w/api.php', {'format': 'json', 'formatversion': '2', ...params});

  Future<String> fetchText(String rootTitle, {void Function(double)? onProgress}) async {
    final root = _normalize(rootTitle);
    final wikitext = <String, String>{};
    final children = <String, List<WikisourceLink>>{};
    var level = [root];
    var depth = 0;
    while (level.isNotEmpty && depth < maxDepth && wikitext.length < maxPages) {
      final fetched = await _fetchWikitext(level);
      if (depth == 0 && fetched[root] == null) {
        throw const DigitalBookException(DigitalBookFailure.notFound);
      }
      wikitext.addAll(fetched);
      final next = <String>[];
      for (final title in level) {
        final links = childLinks(title, fetched[title] ?? '');
        children[title] = links;
        for (final link in links) {
          if (!wikitext.containsKey(link.title) && !next.contains(link.title)) {
            next.add(link.title);
          }
        }
      }
      onProgress?.call((0.05 + depth * 0.1).clamp(0.0, 0.4));
      level = next;
      depth++;
    }
    final buffer = StringBuffer();
    final written = <String>{};
    // Sayfa yazıldıkça ilerleme %40'tan %100'e doğru güncellenir (gömülü sayfalar ayrı istek ister).
    void report() => onProgress?.call(0.4 + 0.6 * written.length / wikitext.length);
    await _write(root, null, wikitext, children, buffer, written, report);
    onProgress?.call(1.0);
    final text = TextCleaner.collapseBlankLines(buffer.toString()).trim();
    if (text.isEmpty) throw const DigitalBookException(DigitalBookFailure.notFound);
    return text;
  }

  Future<void> _write(
    String title,
    String? heading,
    Map<String, String> wikitext,
    Map<String, List<WikisourceLink>> children,
    StringBuffer out,
    Set<String> written,
    void Function() report,
  ) async {
    if (!written.add(title)) return;
    final source = wikitext[title] ?? '';
    final content = source.contains('<pages')
        ? await _fetchRenderedText(title)
        : TextCleaner.cleanWikitext(source);
    if (heading != null && heading.trim().isNotEmpty) out.write('\n\n${heading.trim()}\n\n');
    if (content.isNotEmpty) out.write('$content\n\n');
    report();
    for (final link in children[title] ?? const <WikisourceLink>[]) {
      await _write(link.title, link.label, wikitext, children, out, written, report);
    }
  }

  /// Taranmış kaynaktan gömülen (`<pages index=…>`) sayfalar işlenmiş HTML'den okunur.
  Future<String> _fetchRenderedText(String title) async {
    final json = await _http.getJson(_api({'action': 'parse', 'page': title, 'prop': 'text'}));
    final parse = json['parse'];
    final html = parse is Map<String, dynamic> ? parse['text'] : null;
    if (html is! String) throw const DigitalBookException(DigitalBookFailure.server);
    return TextCleaner.htmlToText(html);
  }

  Future<Map<String, String>> _fetchWikitext(List<String> titles) async {
    final result = <String, String>{};
    for (var i = 0; i < titles.length; i += batchSize) {
      final batch = titles.sublist(i, (i + batchSize).clamp(0, titles.length));
      final json = await _http.postJson(_api(const {}), {
        'action': 'query',
        'format': 'json',
        'formatversion': '2',
        'prop': 'revisions',
        'rvprop': 'content',
        'rvslots': 'main',
        'redirects': '1',
        'titles': batch.join('|'),
      });
      final query = json['query'] as Map<String, dynamic>? ?? const {};
      // API başlığı normalleştirdiyse veya yönlendirdiyse istenen başlığa geri eşlenir.
      final aliases = <String, String>{};
      for (final key in ['normalized', 'redirects']) {
        for (final m in (query[key] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>()) {
          aliases[m['to'] as String] = aliases[m['from'] as String] ?? m['from'] as String;
        }
      }
      for (final page in (query['pages'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>()) {
        if (page['missing'] == true) continue;
        final revisions = page['revisions'] as List<dynamic>? ?? const [];
        if (revisions.isEmpty) continue;
        final slots = (revisions.first as Map<String, dynamic>)['slots'] as Map<String, dynamic>?;
        final content = (slots?['main'] as Map<String, dynamic>?)?['content'];
        if (content is! String) continue;
        final title = page['title'] as String;
        result[aliases[title] ?? title] = content;
      }
    }
    return result;
  }

  /// Sayfanın wikitext'indeki, kendi alt sayfası olan bağlantıları sırayla döner.
  static List<WikisourceLink> childLinks(String pageTitle, String wikitext) {
    final links = <WikisourceLink>[];
    final seen = <String>{};
    final pattern = RegExp(r'\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]');
    for (final m in pattern.allMatches(wikitext)) {
      final target = resolve(pageTitle, m.group(1)!.trim());
      if (!target.startsWith('$pageTitle/') || !seen.add(target)) continue;
      final label = TextCleaner.cleanWikitext(m.group(2) ?? target.split('/').last);
      links.add(WikisourceLink(target, label));
    }
    return links;
  }

  /// Göreli bağlantıları (`/Alt`, `../Kardeş`) tam başlığa çevirir.
  static String resolve(String pageTitle, String target) {
    var base = pageTitle;
    var rest = target;
    while (rest.startsWith('../')) {
      final cut = base.lastIndexOf('/');
      base = cut > 0 ? base.substring(0, cut) : base;
      rest = rest.substring(3);
    }
    if (rest.startsWith('/')) return _normalize('$base$rest'.replaceAll(RegExp(r'/+$'), ''));
    if (target.startsWith('../')) return _normalize('$base/$rest');
    return _normalize(rest);
  }

  static String _normalize(String title) => title.replaceAll('_', ' ').trim();
}

/// Bir sayfanın alt sayfasına verdiği bağlantı ve görünen adı (bölüm başlığı).
class WikisourceLink {
  const WikisourceLink(this.title, this.label);

  final String title;
  final String label;
}
