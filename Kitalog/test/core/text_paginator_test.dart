import 'package:flutter_test/flutter_test.dart';
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

  test('konum ↔ sayfa ve ilerleme dönüşümleri', () {
    final pages = TextPaginator.paginate(text, targetChars: 600);
    expect(TextPaginator.pageIndexForOffset(pages, 0), 0);
    expect(TextPaginator.pageIndexForOffset(pages, pages[2].start + 5), 2);
    expect(TextPaginator.pageIndexForOffset(pages, text.length * 10), pages.length - 1);
    expect(TextPaginator.progressAfterPage(pages, pages.length - 1, text.length), 1.0);
    final mid = TextPaginator.progressAfterPage(pages, 1, text.length);
    expect(mid, closeTo(pages[2].start / text.length, 1e-9));
    expect(TextPaginator.progressAfterPage(const [], 0, 10), 0);
  });

  test('ilerleme basılı sayfa sayısına çevrilir ve sınırlanır', () {
    expect(TextPaginator.printedPageFor(0.5, 300), 150);
    expect(TextPaginator.printedPageFor(1.5, 300), 300);
    expect(TextPaginator.printedPageFor(-1, 300), 0);
    expect(TextPaginator.printedPageFor(0.5, 0), 0);
  });
}
