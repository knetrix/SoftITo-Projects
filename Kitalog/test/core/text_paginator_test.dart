import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/utils/text_paginator.dart';

void main() {
  final paragraph = List.filled(30, 'kelime').join(' ');
  final text = List.generate(20, (i) => 'P$i $paragraph.').join('\n\n');

  test('sayfalar paragraf sınırında bölünür ve tüm metni kapsar', () {
    final pages = TextPaginator.paginate(text, targetChars: 600);
    expect(pages.length, greaterThan(3));
    for (final page in pages) {
      expect(page.text.length, lessThanOrEqualTo(600 * 1.3));
      expect(page.text.startsWith('P'), isTrue, reason: 'paragraf başından başlamalı');
      expect(text.substring(page.start).startsWith(page.text), isTrue);
    }
    expect(pages.map((p) => p.text).join('\n\n'), text);
  });

  test('paragrafı olmayan uzun metin boşlukta bölünür', () {
    final long = List.filled(500, 'abc').join(' ');
    final pages = TextPaginator.paginate(long, targetChars: 200);
    expect(pages.length, greaterThan(5));
    expect(pages.every((p) => !p.text.startsWith(' ')), isTrue);
  });

  test('boş metin tek boş sayfa döner', () {
    final pages = TextPaginator.paginate('   ');
    expect(pages.length, 1);
    expect(pages.single.text, '');
  });

  test('konum → sayfa dönüşümü', () {
    final pages = TextPaginator.paginate(text, targetChars: 600);
    expect(TextPaginator.pageIndexForOffset(pages, 0), 0);
    expect(TextPaginator.pageIndexForOffset(pages, pages[2].start + 5), 2);
    expect(
      TextPaginator.pageIndexForOffset(pages, text.length * 10),
      pages.length - 1,
    );
  });

  group('paginateInto', () {
    test('tam istenen sayıda sayfa üretir ve tüm metni sırayla kapsar', () {
      for (final count in [1, 2, 7, 20, 55, 300]) {
        final pages = TextPaginator.paginateInto(text, count);
        expect(pages.length, count, reason: '\$count sayfa');
        for (var i = 1; i < pages.length; i++) {
          expect(pages[i].start, greaterThan(pages[i - 1].start));
        }
        expect(
          pages
              .map((p) => p.text)
              .where((t) => t.isNotEmpty)
              .join(' ')
              .replaceAll(RegExp(r'\s+'), ' '),
          text.replaceAll(RegExp(r'\s+'), ' '),
        );
      }
    });

    test('sayfalar mümkünse paragraf başından başlar ve dengeli dağılır', () {
      final pages = TextPaginator.paginateInto(text, 10);
      final average = text.length / 10;
      for (final page in pages) {
        expect(page.text.startsWith('P'), isTrue);
        expect(page.text.length, lessThan(average * 1.7));
      }
    });

    test('paragrafsız ve sayfa sayısından kısa metinde de sayı korunur', () {
      final long = List.filled(500, 'abc').join(' ');
      final pages = TextPaginator.paginateInto(long, 37);
      expect(pages.length, 37);
      expect(
        pages.every((p) => !p.text.startsWith(' ') && p.text.isNotEmpty),
        isTrue,
      );
      expect(TextPaginator.paginateInto('kısa', 12).length, 12);
      expect(TextPaginator.paginateInto('', 5).length, 5);
    });

    test('sayfa sayısı yoksa varsayılan sayfalamaya düşer', () {
      expect(
        TextPaginator.paginateInto(text, 0).length,
        TextPaginator.paginate(text).length,
      );
    });

    test('tüm örnek kitaplarda okuyucu sayfası = kitabın sayfa sayısı', () {
      final book = List.generate(4000, (i) => 'P$i $paragraph.').join('\n\n');
      for (final b in SeedData.build(DateTime(2026, 10, 21)).books) {
        expect(
          TextPaginator.paginateInto(book, b.pageCount).length,
          b.pageCount,
          reason: b.title,
        );
      }
    });
  });
}
