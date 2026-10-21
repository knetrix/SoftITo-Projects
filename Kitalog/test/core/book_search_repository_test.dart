import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/repositories/book_search_repository.dart';

import '../helpers/fake_open_library.dart';

void main() {
  test('metin araması sonuçları ayrıştırır, kapak ve tür çıkarır', () async {
    final requests = <Uri>[];
    final repo = BookSearchRepository(
      client: fakeOpenLibrary(searchBody: cosmosSearchBody, requests: requests),
    );
    final results = await repo.searchByText('cosmos');
    expect(requests.single.queryParameters['q'], 'cosmos');
    expect(results.length, 2);
    final first = results.first;
    expect(first.title, 'Cosmos');
    expect(first.authors, ['Carl Sagan']);
    expect(first.pageCount, 365);
    expect(first.isbn, '9780345539434');
    expect(first.coverUrl, 'https://covers.openlibrary.org/b/id/12345-L.jpg');
    expect(first.genre, BookGenre.science);
    expect(results.last.coverUrl, isNull);
  });

  test('ISBN araması isbn: sorgusu kullanır ve kapak adresini ISBN\'den üretir', () async {
    final requests = <Uri>[];
    final repo = BookSearchRepository(
      client: fakeOpenLibrary(
        searchBody: {
          'docs': [
            {'title': 'Cosmos', 'author_name': ['Carl Sagan']},
          ],
        },
        requests: requests,
      ),
    );
    final results = await repo.searchByIsbn('9780375508325');
    expect(requests.single.queryParameters['q'], 'isbn:9780375508325');
    expect(results.single.isbn, '9780375508325');
    expect(
      results.single.coverUrl,
      'https://covers.openlibrary.org/b/isbn/9780375508325-L.jpg',
    );
  });

  test('ISBN aramada sonuç yoksa /isbn/<ISBN>.json denenir', () async {
    final repo = BookSearchRepository(
      client: fakeOpenLibrary(isbnBody: {'title': 'Doğrudan Kayıt', 'number_of_pages': 99}),
    );
    final results = await repo.searchByIsbn('9780375508325');
    expect(results.single.title, 'Doğrudan Kayıt');
    expect(results.single.pageCount, 99);
    final none = await BookSearchRepository(client: fakeOpenLibrary()).searchByIsbn('9780375508325');
    expect(none, isEmpty);
  });

  test('ağ ve sunucu hataları BookSearchException olarak yükselir', () async {
    final offline = BookSearchRepository(client: fakeOpenLibrary(offline: true));
    await expectLater(
      offline.searchByText('x'),
      throwsA(
        isA<BookSearchException>().having((e) => e.failure, 'failure', BookSearchFailure.network),
      ),
    );
    final broken = BookSearchRepository(client: fakeOpenLibrary(searchStatus: 500));
    await expectLater(
      broken.searchByText('x'),
      throwsA(
        isA<BookSearchException>().having((e) => e.failure, 'failure', BookSearchFailure.server),
      ),
    );
  });

  test('guessGenre konu etiketlerinden tür tahmin eder', () {
    expect(BookSearchRepository.guessGenre(['Fantasy fiction']), BookGenre.sciFiFantasy);
    expect(BookSearchRepository.guessGenre(['Biography']), BookGenre.biography);
    expect(BookSearchRepository.guessGenre(['Juvenile literature']), BookGenre.children);
    expect(BookSearchRepository.guessGenre(['Turkish fiction']), BookGenre.novel);
    expect(BookSearchRepository.guessGenre(const []), BookGenre.other);
  });
}
