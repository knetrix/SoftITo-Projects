import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Gutenberg ve Vikikaynak'ı taklit eden sahte HTTP istemcisi.
class FakeDigitalSources {
  FakeDigitalSources({
    this.gutenbergTexts = const {},
    this.wikitext = const {},
    this.renderedHtml = const {},
    this.offline = false,
    this.failWikisource = false,
  });

  final Map<String, String> gutenbergTexts;
  final Map<String, String> wikitext;
  final Map<String, String> renderedHtml;
  final bool offline;
  final bool failWikisource;
  final List<Uri> requests = [];

  int wikiQueryCount = 0;

  static String gutenbergBody(String body) =>
      'Header\n*** START OF THE PROJECT GUTENBERG EBOOK X ***\n$body\n*** END OF THE PROJECT GUTENBERG EBOOK X ***\nLicense';

  http.Client get client => MockClient((request) async {
    requests.add(request.url);
    if (offline) throw const SocketException('offline');
    final url = request.url;
    if (url.host == 'www.gutenberg.org') {
      final id = RegExp(r'/cache/epub/(\d+)/').firstMatch(url.path)?.group(1);
      final text = gutenbergTexts[id];
      return text == null ? http.Response('', 404) : _bytes(gutenbergBody(text));
    }
    if (url.host == 'tr.wikisource.org') {
      if (failWikisource) return http.Response('', 500);
      final params = {...url.queryParameters, if (request.method == 'POST') ...request.bodyFields};
      return _wiki(params);
    }
    return http.Response('', 404);
  });

  http.Response _wiki(Map<String, String> q) {
    if (q['action'] == 'parse') {
      final html = renderedHtml[q['page']];
      return html == null
          ? _json({'error': {'code': 'missingtitle'}})
          : _json({'parse': {'title': q['page'], 'text': html}});
    }
    wikiQueryCount++;
    final titles = (q['titles'] ?? '').split('|');
    return _json({
      'query': {
        'pages': [
          for (final t in titles)
            wikitext.containsKey(t)
                ? {
                    'title': t,
                    'revisions': [
                      {
                        'slots': {
                          'main': {'content': wikitext[t]},
                        },
                      },
                    ],
                  }
                : {'title': t, 'missing': true},
        ],
      },
    });
  }

  static http.Response _json(Object body) => _bytes(jsonEncode(body));

  static http.Response _bytes(String body) => http.Response.bytes(
    utf8.encode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
