import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/utils/reading_text_cleaner.dart';

// Örnekler seed kitaplarının gerçek Gutenberg / Vikikaynak metinlerinden kısaltılmıştır.
const _prose =
    'I am already far north of London, and as I walk in the streets of Petersburgh,\n'
    'I feel a cold northern breeze play upon my cheeks, which braces my nerves and\n'
    'fills me with delight. Do you understand this feeling?';

String _firstParagraph(String text) => text.split('\n\n').first;

void main() {
  group('cleanGutenbergMarkup', () {
    test('italik, kalın, kelime içi ve eşleşmeyen alt çizgiler kaldırılır', () {
      const raw =
          'She read _Pride and Prejudice_ and _Un_important\nnews on 1_st_ May.\n'
          '=Omit needless words.= The term _mc_2 here; 15,000_l._ a year.';
      expect(
        ReadingTextCleaner.cleanGutenbergMarkup(raw),
        'She read Pride and Prejudice and Unimportant\nnews on 1st May.\n'
        'Omit needless words. The term mc2 here; 15,000l. a year.',
      );
    });

    test('paragraflara yayılan italik ve boşluk doldurma çizgileri', () {
      const raw =
          '_“We are, dear Sirs,\n“Faithfully yours.”_\n\nSigned: ________';
      expect(
        ReadingTextCleaner.cleanGutenbergMarkup(raw),
        '“We are, dear Sirs,\n“Faithfully yours.”\n\nSigned: ________',
      );
    });

    test('görsel, dipnot ve transkripsiyon notları silinir; metin içi köşeli ifadeler kalır', () {
      const raw =
          '[Illustration: Franklin at the Court of Louis XVI\n\n    "He was feasted."]\n\n'
          'The Usher[1] said [i.e. Wu Yuan] in 1772 [1758].\n\n'
          '[1] A footnote that explains.\n\n'
          '[Transcriber’s Note: spelling kept.]\n\nEnd.';
      expect(
        ReadingTextCleaner.cleanGutenbergMarkup(raw),
        'The Usher said [i.e. Wu Yuan] in 1772 [1758].\n\nEnd.',
      );
    });

    test('sayfa işaretleri, alt simgeler ve sahne ayracı', () {
      const raw =
          'them.” {4} This doctrine {356a}\nC_{2}HCl_{3}O\n\n*       *       *       *';
      expect(
        ReadingTextCleaner.cleanGutenbergMarkup(raw),
        'them.” This doctrine\nC₂HCl₃O\n\n* * *',
      );
    });

    test('TRANSCRIBER’S NOTE bölümü başlığıyla birlikte atılır', () {
      const longNote =
          'The punctuation and spelling from the original text have been faithfully '
          'preserved. Only obvious typographical errors have been corrected.';
      final text = ReadingTextCleaner.cleanGutenbergMarkup(
        "TRANSCRIBER'S NOTE\n\n$longNote\n\nPREFACE\n\n$_prose",
      );
      expect(text, startsWith('PREFACE'));
    });
  });

  group('stripFrontMatter', () {
    test('Frankenstein: başlık sayfası ve içindekiler atılır, Letter 1 ile başlar', () {
      const raw =
          'Frankenstein;\n\nor, the Modern Prometheus\n\nby Mary Wollstonecraft (Godwin) Shelley\n\n'
          ' CONTENTS\n\n Letter 1\n Letter 2\n Letter 3\n Letter 4\n Chapter 1\n Chapter 2\n\n'
          'Letter 1\n\n_To Mrs. Saville, England._\n\nSt. Petersburgh, Dec. 11th, 17—.\n\n$_prose\n\n'
          'Letter 2\n\n$_prose\n\nChapter 1\n\n$_prose\n\n$_prose\n\n$_prose';
      final text = ReadingTextCleaner.stripFrontMatter(
        ReadingTextCleaner.cleanGutenbergMarkup(raw),
      );
      expect(text, startsWith('Letter 1\n\nTo Mrs. Saville, England.'));
      expect(text, isNot(contains('CONTENTS')));
    });

    test('Alice: başlık satırları içindekilerde de geçse ilk bölümden başlar', () {
      const raw =
          "Alice’s Adventures in Wonderland\n\nby Lewis Carroll\n\nTHE MILLENNIUM FULCRUM EDITION 3.0\n\n"
          'Contents\n\n CHAPTER I.     Down the Rabbit-Hole\n CHAPTER II.    The Pool of Tears\n'
          ' CHAPTER III.   A Caucus-Race and a Long Tale\n\n'
          'CHAPTER I.\nDown the Rabbit-Hole\n\n$_prose\n\n$_prose\n\nCHAPTER II.\nThe Pool of Tears\n\n'
          '$_prose\n\n$_prose\n\n$_prose\n\n$_prose';
      final text = ReadingTextCleaner.stripFrontMatter(raw);
      expect(_firstParagraph(text), 'CHAPTER I.\nDown the Rabbit-Hole');
    });

    test('ayrıntılı içindekiler (girdi + özet) gövde sanılmaz', () {
      const summary =
          'Causes of Variability. Effects of Habit. Correlation of Growth. Inheritance. '
          'Character of Domestic Varieties. Difficulty of distinguishing between Varieties.';
      const raw =
          'ON THE ORIGIN OF SPECIES.\n\nBY CHARLES DARWIN.\n\nCONTENTS.\n\nINTRODUCTION.\n'
          'CHAPTER I. VARIATION UNDER DOMESTICATION.\nCHAPTER II. VARIATION UNDER NATURE.\n\n'
          'DETAILED CONTENTS.\n\nINTRODUCTION.\n\nCHAPTER I. VARIATION UNDER DOMESTICATION.\n\n$summary\n\n'
          'CHAPTER II. VARIATION UNDER NATURE.\n\n$summary\n\n'
          'INTRODUCTION.\n\n$_prose\n\n$_prose\n\n$_prose\n\nCHAPTER I. VARIATION UNDER DOMESTICATION.\n\n'
          '$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose';
      final text = ReadingTextCleaner.stripFrontMatter(raw);
      expect(text, startsWith('INTRODUCTION.\n\nI am already far north'));
    });

    test('sayfa numaralı içindekiler ve görsel listesi atlanır; "PAGE" sütun başlığı girdi değildir', () {
      const raw =
          'AUTOBIOGRAPHY\n\nOF\n\nBENJAMIN FRANKLIN\n\nCONTENTS\n\n'
          '                                     PAGE\nIntroduction                   vii\n\n'
          '      I. Ancestry and Early Life in Boston      3\n     II. Beginning Life as a Printer     21\n\n'
          'ILLUSTRATIONS\n\n                                     PAGE\nPortrait of Franklin           vii\n\n'
          '"I was employed to carry the papers thro\' the streets\n  to the customers"        36\n\n'
          'INTRODUCTION\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose';
      expect(
        _firstParagraph(ReadingTextCleaner.stripFrontMatter(raw)),
        'INTRODUCTION',
      );
    });

    test('içinde "Gutenberg" geçen önsöz başlığı ve içindekiler meta not sayılmaz', () {
      const raw =
          'Sun Tzŭ\non\nThe Art of War\n\nBY\nLIONEL GILES, M.A.\n\n1910\n\nContents\n\n'
          ' Preface to the Project Gutenberg Etext\n Preface by Lionel Giles\n INTRODUCTION\n'
          ' Chapter I. Laying plans\n Chapter II. Waging War\n Chapter III. Attack by Stratagem\n'
          ' Chapter IV. Tactical Dispositions\n\n'
          'Preface to the Project Gutenberg Etext\n\n$_prose\n\n$_prose\n\n$_prose\n\n'
          'Preface by Lionel Giles\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose';
      expect(
        _firstParagraph(ReadingTextCleaner.stripFrontMatter(raw)),
        'Preface to the Project Gutenberg Etext',
      );
    });

    test('içindekiler yoksa başlık sayfası atılır (Kürk Mantolu Madonna)', () {
      const body =
          'Simdiye kadar tesadüf ettiğim insanlardan bir tanesi benim üzerimde belki en büyük '
          'tesiri yapmıştır. Aradan aylar geçtiği halde bir türlü bu tesirden kurtulamadım.';
      const raw =
          "KÜRK MANTOLU MADONNA\n\nSabahattin Ali\n\n'KÜRK MANTOLU MADONNA'\n\nBüyük hikâye\n\n"
          'ISTANBUL\nREMZİ KİTABEVİ\n93 Ankara Caddesi 93\n\nGÜVEN BASIMEVİ — İSTANBUL, 1943\n\n'
          '$body\n\n$body\n\n$body\n\n$body\n\n$body';
      expect(
        ReadingTextCleaner.stripFrontMatter(raw),
        startsWith('Simdiye kadar'),
      );
    });

    test('baştaki bölüm başlıkları ve ilk cümle korunur (Nutuk)', () {
      const raw =
          "Harb-i Umumî'de Anadolu'nun durumu ve halâs çareleri\n\n"
          'Samsun\'a çıktığım gün umumî vaziyet ve manzara\n\n'
          '1335 senesi Mayıs’ının on dokuzuncu günü Samsun’a çıktım. Vaziyet ve manzara-i umumiye:\n\n'
          'Osmanlı Devleti’nin dahil bulunduğu grup, Harb-i Umumî’de mağlûp olmuş, Osmanlı ordusu her '
          'tarafta zedelenmiş, şerâiti ağır bir mütarekenâme imzalanmış.\n\nSon paragraf.';
      expect(ReadingTextCleaner.stripFrontMatter(raw), raw);
    });

    test('şiir dizeleri başlık sayfası sanılmaz (Leaves of Grass)', () {
      const raw =
          'LEAVES OF GRASS\n\nBy Walt Whitman\n\n'
          '     Come, said my soul,\n     Such verses for my Body let us write, (for we are one,)\n'
          '     That should I after return,\n     Or, long, long hence, in other spheres,\n'
          '     There to some group of mates the chants resuming,\n'
          '     (Tallying Earth’s soil, trees, winds, tumultuous waves,)\n     Ever with pleas’d smile I may keep on,\n\n'
          'BOOK I.  INSCRIPTIONS\n\nOne’s-Self I Sing\n\n  One’s-self I sing, a simple separate person,';
      expect(ReadingTextCleaner.stripFrontMatter(raw), raw);
    });

    test('eski kopyada tek satıra birleşmiş içindekiler de atlanır', () {
      const raw =
          'THE WONDERFUL WIZARD OF OZ\n\nby L. Frank Baum\n\nContents\n\n'
          'Introduction Chapter I. The Cyclone Chapter II. The Council with the Munchkins '
          'Chapter III. How Dorothy Saved the Scarecrow Chapter IV. The Road Through the Forest\n\n'
          'Introduction\n\n$_prose\n\n$_prose\n\nChapter I. The Cyclone\n\n$_prose\n\n$_prose\n\n$_prose\n\n$_prose';
      expect(
        _firstParagraph(ReadingTextCleaner.stripFrontMatter(raw)),
        'Introduction',
      );
    });

    test('kural metnin çoğunu silecekse metin olduğu gibi bırakılır', () {
      // Kısa satırlardan oluşan uzun bir açılış (ör. oyun kişileri) başlık sayfası sanılabilir.
      final raw = [
        for (var i = 1; i <= 12; i++) 'Kişi $i',
        _prose,
      ].join('\n\n');
      expect(ReadingTextCleaner.stripFrontMatter(raw), raw);
    });
  });
}
