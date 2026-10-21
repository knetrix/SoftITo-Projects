import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const cosmosSearchBody = {
  'docs': [
    {
      'title': 'Cosmos',
      'author_name': ['Carl Sagan'],
      'isbn': ['0345539435', '9780345539434'],
      'number_of_pages_median': 365,
      'cover_i': 12345,
      'subject': ['Astronomy', 'Science'],
    },
    {
      'title': 'Cosmos: A Personal Voyage',
      'author_name': ['Carl Sagan'],
    },
  ],
};

/// Open Library'yi taklit eden istemci; her istek `onRequest` ile kaydedilir.
MockClient fakeOpenLibrary({
  Map<String, dynamic> searchBody = const {'docs': []},
  Map<String, dynamic>? isbnBody,
  int searchStatus = 200,
  bool offline = false,
  List<Uri>? requests,
}) {
  return MockClient((request) async {
    requests?.add(request.url);
    if (offline) throw const SocketException('offline');
    if (request.url.path == '/search.json') {
      return http.Response.bytes(
        utf8.encode(jsonEncode(searchBody)),
        searchStatus,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
    if (request.url.path.startsWith('/isbn/')) {
      return isbnBody == null
          ? http.Response('', 404)
          : http.Response.bytes(utf8.encode(jsonEncode(isbnBody)), 200);
    }
    return http.Response('', 404);
  });
}
