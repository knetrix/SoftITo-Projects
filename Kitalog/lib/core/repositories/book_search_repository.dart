import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book_genre.dart';
import '../models/book_search_result.dart';

enum BookSearchFailure { network, server }

class BookSearchException implements Exception {
  const BookSearchException(this.failure);

  final BookSearchFailure failure;

  @override
  String toString() => 'BookSearchException($failure)';
}

/// Open Library API istemcisi (`search.json` ve `isbn/<ISBN>.json`).
class BookSearchRepository {
  BookSearchRepository({http.Client? client, this.timeout = const Duration(seconds: 10)})
    : _client = client ?? http.Client();

  static const String _host = 'openlibrary.org';
  static const String _fields =
      'title,author_name,isbn,number_of_pages_median,cover_i,subject';

  final http.Client _client;
  final Duration timeout;

  Future<List<BookSearchResult>> searchByText(String query) async {
    final json = await _getJson(
      Uri.https(_host, '/search.json', {
        'q': query,
        'limit': '20',
        'fields': _fields,
      }),
    );
    return _parseDocs(json);
  }

  Future<List<BookSearchResult>> searchByIsbn(String isbn) async {
    final json = await _getJson(
      Uri.https(_host, '/search.json', {
        'q': 'isbn:$isbn',
        'limit': '5',
        'fields': _fields,
      }),
    );
    final results = _parseDocs(json, preferIsbn: isbn);
    if (results.isNotEmpty) return results;

    // Arama sonuç vermediyse doğrudan ISBN kaydı denenir.
    final direct = await _getJson(
      Uri.https(_host, '/isbn/$isbn.json'),
      allowNotFound: true,
    );
    if (direct == null) return const [];
    final title = direct['title'] as String?;
    if (title == null || title.isEmpty) return const [];
    return [
      BookSearchResult(
        title: title,
        pageCount: direct['number_of_pages'] as int?,
        isbn: isbn,
        coverUrl: coverUrlForIsbn(isbn),
      ),
    ];
  }

  static String coverUrlForIsbn(String isbn) =>
      'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';

  static String coverUrlForId(int id) =>
      'https://covers.openlibrary.org/b/id/$id-L.jpg';

  Future<Map<String, dynamic>?> _getJson(
    Uri uri, {
    bool allowNotFound = false,
  }) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 404 && allowNotFound) return null;
      if (response.statusCode != 200) {
        throw const BookSearchException(BookSearchFailure.server);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const BookSearchException(BookSearchFailure.server);
      }
      return decoded;
    } on BookSearchException {
      rethrow;
    } on FormatException {
      throw const BookSearchException(BookSearchFailure.server);
    } on Exception {
      // TimeoutException, ClientException, SocketException vb. → ağ hatası.
      throw const BookSearchException(BookSearchFailure.network);
    }
  }

  List<BookSearchResult> _parseDocs(
    Map<String, dynamic>? json, {
    String? preferIsbn,
  }) {
    final docs = (json?['docs'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();
    final results = <BookSearchResult>[];
    for (final doc in docs) {
      final title = (doc['title'] as String?)?.trim() ?? '';
      if (title.isEmpty) continue;
      final isbns = (doc['isbn'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList();
      final isbn = preferIsbn ??
          isbns.firstWhere((e) => e.length == 13, orElse: () => '');
      final coverId = doc['cover_i'] as int?;
      results.add(
        BookSearchResult(
          title: title,
          authors: (doc['author_name'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
          pageCount: (doc['number_of_pages_median'] as num?)?.round(),
          isbn: isbn.isEmpty ? null : isbn,
          coverUrl: coverId != null
              ? coverUrlForId(coverId)
              : (isbn.isEmpty ? null : coverUrlForIsbn(isbn)),
          genre: guessGenre(
            (doc['subject'] as List<dynamic>? ?? const []).whereType<String>(),
          ),
        ),
      );
    }
    return results;
  }

  /// Open Library konu (subject) etiketlerinden tür tahmini yapar.
  static BookGenre guessGenre(Iterable<String> subjects) {
    final text = subjects.map((s) => s.toLowerCase()).join('|');
    bool has(List<String> keys) => keys.any(text.contains);
    if (has(['fantasy', 'science fiction'])) return BookGenre.sciFiFantasy;
    if (has(['biograph', 'autobiograph', 'memoir'])) return BookGenre.biography;
    if (has(['poetry', 'poems'])) return BookGenre.poetry;
    if (has(['juvenile', 'children'])) return BookGenre.children;
    if (has(['philosoph'])) return BookGenre.philosophy;
    if (has(['self-help', 'personal development', 'success'])) {
      return BookGenre.personalDevelopment;
    }
    if (has(['history'])) return BookGenre.history;
    if (has(['science', 'physics', 'astronomy', 'biology'])) {
      return BookGenre.science;
    }
    if (has(['fiction', 'novel', 'literature'])) return BookGenre.novel;
    return BookGenre.other;
  }

  void dispose() {
    _client.close();
  }
}
