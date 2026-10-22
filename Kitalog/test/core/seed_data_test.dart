import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/models/reading_status.dart';

bool _validIsbn13(String isbn) {
  if (isbn.length != 13) return false;
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(isbn[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - sum % 10) % 10 == int.parse(isbn[12]);
}

void main() {
  final seed = SeedData.build(DateTime(2026, 10, 21));

  test('en az 30 kitap, benzersiz geçerli ISBN-13 ve kapak URL\'i', () {
    expect(seed.books.length, greaterThanOrEqualTo(30));
    final isbns = seed.books.map((b) => b.isbn!).toList();
    expect(isbns.toSet().length, isbns.length);
    for (final book in seed.books) {
      expect(_validIsbn13(book.isbn!), isTrue, reason: book.title);
      expect(
        book.coverUrl,
        'https://covers.openlibrary.org/b/isbn/${book.isbn}-L.jpg',
      );
    }
  });

  test('her türden en az 2 kitap vardır', () {
    for (final genre in BookGenre.values) {
      expect(seed.books.where((b) => b.genre == genre).length, greaterThanOrEqualTo(2),
          reason: genre.name);
    }
  });

  test('3 okuma durumuna dağılır; okunanlarda puan, okunanlarda ilerleme', () {
    for (final status in ReadingStatus.values) {
      expect(seed.books.where((b) => b.status == status), isNotEmpty);
    }
    for (final b in seed.books.where((b) => b.status == ReadingStatus.finished)) {
      expect(b.rating, isNotNull);
      expect(b.review, isNotEmpty);
      expect(b.progress, 1.0);
      expect(b.finishedAt!.year, 2026);
    }
    final percents = seed.books
        .where((b) => b.status == ReadingStatus.reading)
        .map((b) => b.progressPercent)
        .toSet();
    expect(percents.length, greaterThan(3));
  });

  test('en az 3 ödünç, 15 alıntı, birkaç not ve 24 kitaplık hedef', () {
    expect(seed.books.where((b) => b.isLent).length, greaterThanOrEqualTo(3));
    expect(seed.quotes.length, greaterThanOrEqualTo(15));
    expect(seed.quotes.every((q) => q.page != null), isTrue);
    expect(seed.notes, isNotEmpty);
    expect(seed.goal.targetBookCount, 24);
    final ids = seed.books.map((b) => b.id).toSet();
    expect(seed.quotes.every((q) => ids.contains(q.bookId)), isTrue);
    expect(seed.notes.every((n) => ids.contains(n.bookId)), isTrue);
    // Örnek ödünç geçmişi: fiziksel kopyası olan, şu an ödünçte olmayan kitaplarda; biri geç iade.
    final byId = {for (final b in seed.books) b.id: b};
    expect(seed.loanHistory.length, greaterThanOrEqualTo(3));
    expect(seed.loanHistory.map((r) => r.id).toSet().length, seed.loanHistory.length);
    for (final r in seed.loanHistory) {
      expect(byId[r.bookId]?.isOwned, isTrue, reason: r.bookId);
      expect(byId[r.bookId]!.isLent, isFalse, reason: r.bookId);
      expect(r.returnedAt.isAfter(r.lentAt), isTrue);
    }
    expect(seed.loanHistory.where((r) => r.wasLate), isNotEmpty);
  });

  test('biten kitap tarihleri gelecekte değil (Ocak ayında da)', () {
    final january = SeedData.build(DateTime(2026, 1, 15));
    for (final b in january.books.where((b) => b.finishedAt != null)) {
      expect(b.finishedAt!.isAfter(DateTime(2026, 1, 15)), isFalse);
    }
  });

  test('her örnek kitap telifi bitmiş bir dijital sürüme sahiptir', () {
    for (final book in seed.books) {
      final edition = book.digitalEdition;
      expect(edition, isNotNull, reason: book.title);
      expect(edition!.sourceId, isNotEmpty);
      if (edition.source == DigitalSource.gutenberg) {
        expect(int.tryParse(edition.sourceId), isNotNull, reason: book.title);
        expect(edition.languageCode, 'en');
      } else {
        expect(edition.languageCode, 'tr');
      }
    }
    final ids = seed.books.map((b) => b.digitalEdition!.sourceId).toList();
    expect(ids.toSet().length, ids.length, reason: 'aynı metin iki kez kullanılmamalı');
  });

  test('Türk ve dünya edebiyatından karışık: Vikikaynak ve Gutenberg', () {
    final sources = seed.books.map((b) => b.digitalEdition!.source).toSet();
    expect(sources, {DigitalSource.gutenberg, DigitalSource.wikisource});
    final turkish = seed.books.where((b) => b.digitalEdition!.source == DigitalSource.wikisource);
    expect(turkish.map((b) => b.title), containsAll(['Kürk Mantolu Madonna', 'Nutuk']));
  });

  test('örnek kitap kimlikleri seed önekini taşır', () {
    expect(seed.books.every((b) => SeedData.isSeedId(b.id)), isTrue);
    expect(SeedData.version, greaterThanOrEqualTo(2));
  });
}
