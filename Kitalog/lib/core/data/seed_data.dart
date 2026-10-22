import '../models/book_genre.dart';
import '../models/book_model.dart';
import '../models/digital_edition_model.dart';
import '../models/digital_source.dart';
import '../models/loan_model.dart';
import '../models/loan_record_model.dart';
import '../models/note_model.dart';
import '../models/quote_model.dart';
import '../models/reading_goal_model.dart';
import '../models/reading_status.dart';

class SeedBundle {
  const SeedBundle({
    required this.books,
    required this.quotes,
    required this.notes,
    required this.goal,
    this.loanHistory = const [],
  });

  final List<BookModel> books;
  final List<QuoteModel> quotes;
  final List<NoteModel> notes;
  final ReadingGoalModel goal;

  /// İadesi alınmış örnek ödünç kayıtları (Ödünç Takibi > Geçmiş).
  final List<LoanRecordModel> loanHistory;
}

/// İlk açılışta (veya seed sürümü değiştiğinde) yüklenen örnek veriler.
///
/// Tüm kitaplar telifi bitmiş eserlerdir ve dijital olarak okunabilir:
/// Türkçe eserler Vikikaynak'tan, dünya klasikleri Project Gutenberg'den gelir.
/// ISBN'ler, baskı başlıkları, sayfa sayıları ve kapaklar Open Library'de;
/// Gutenberg numaraları ve Vikikaynak sayfaları kaynaklarında doğrulanmıştır.
/// Alıntılar dijital metinde birebir aranarak doğrulanmıştır; sayfa numarası,
/// alıntının metindeki konumunun basılı sayfa sayısına oranlanmasıyla bulunmuştur.
abstract final class SeedData {
  /// Seed değiştiğinde artırılır; eski örnek kitaplar yenileriyle değiştirilir.
  static const int version = 2;

  /// Örnek kitapların kimlik öneki; kullanıcının eklediği kitaplardan ayırır.
  static const String idPrefix = 'seed-';

  static const String _coverBase = 'https://covers.openlibrary.org/b/isbn';

  static String coverUrl(String isbn) => '$_coverBase/$isbn-L.jpg';

  static bool isSeedId(String id) => id.startsWith(idPrefix);

  static SeedBundle build(DateTime now) {
    final year = now.year;
    // Biten kitapların tarihi bu yılın başından bugüne yayılır (gelecek tarih yok).
    DateTime finished(int month, int day) {
      final m = month > now.month ? now.month : month;
      final d = (m == now.month && day > now.day) ? now.day : day;
      return DateTime(year, m, d < 1 ? 1 : d);
    }

    final books = <BookModel>[
      for (final s in _specs)
        _bookFrom(s, now: now, finishedAt: finished(s.month, s.day)),
    ];

    final quotes = <QuoteModel>[
      for (var i = 0; i < _quotes.length; i++)
        QuoteModel(
          id: '${idPrefix}quote-$i',
          bookId: '$idPrefix${_quotes[i].isbn}',
          text: _quotes[i].text,
          page: _quotes[i].page,
          isFavorite: _quotes[i].favorite,
          createdAt: now.subtract(Duration(days: 3 + i * 4)),
        ),
    ];

    final notes = <NoteModel>[
      for (var i = 0; i < _notes.length; i++)
        NoteModel(
          id: '${idPrefix}note-$i',
          bookId: '$idPrefix${_notes[i].isbn}',
          content: _notes[i].text,
          createdAt: now.subtract(Duration(days: 5 + i * 9)),
          updatedAt: now.subtract(Duration(days: 5 + i * 9)),
        ),
    ];

    DateTime daysAgo(int days) => now.subtract(Duration(days: days));
    final loanHistory = <LoanRecordModel>[
      for (var i = 0; i < _returnedLoans.length; i++)
        LoanRecordModel(
          id: '${idPrefix}loan-$i',
          bookId: '$idPrefix${_returnedLoans[i].isbn}',
          borrowerName: _returnedLoans[i].borrower,
          lentAt: daysAgo(_returnedLoans[i].lentDaysAgo),
          dueAt: _returnedLoans[i].dueDaysAgo == null ? null : daysAgo(_returnedLoans[i].dueDaysAgo!),
          returnedAt: daysAgo(_returnedLoans[i].returnedDaysAgo),
        ),
    ];

    return SeedBundle(
      books: books,
      quotes: quotes,
      notes: notes,
      goal: ReadingGoalModel(year: year, targetBookCount: 24),
      loanHistory: loanHistory,
    );
  }

  static BookModel _bookFrom(
    _BookSpec s, {
    required DateTime now,
    required DateTime finishedAt,
  }) {
    final isFinished = s.status == ReadingStatus.finished;
    final isReading = s.status == ReadingStatus.reading;
    return BookModel(
      id: '$idPrefix${s.isbn}',
      isbn: s.isbn,
      title: s.title,
      authors: [s.author],
      coverUrl: coverUrl(s.isbn),
      pageCount: s.pages,
      currentPage: isFinished
          ? s.pages
          : isReading
          ? (s.pages * s.percent / 100).round()
          : 0,
      genre: s.genre,
      status: s.status,
      rating: isFinished ? s.rating : null,
      review: isFinished ? s.review : null,
      isOwned: s.owned,
      loan: s.lendTo == null
          ? null
          : LoanModel(
              borrowerName: s.lendTo!,
              lentAt: now.subtract(Duration(days: s.lentDaysAgo)),
              dueAt: now.add(Duration(days: s.dueInDays)),
            ),
      startedAt: isFinished
          ? finishedAt.subtract(const Duration(days: 14))
          : isReading
          ? now.subtract(Duration(days: 7 + s.percent ~/ 5))
          : null,
      finishedAt: isFinished ? finishedAt : null,
      addedAt: now.subtract(Duration(days: 60 + s.pages % 90)),
      digitalEdition: s.edition,
    );
  }

  static const List<_BookSpec> _specs = [
    _BookSpec('9780140817591', 'Pride and Prejudice', 'Jane Austen', 352, BookGenre.novel, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '1342', languageCode: 'en'), month: 1, day: 14, rating: 5, review: 'Elizabeth ile Darcy arasındaki önyargıların çözülüşü hâlâ çok keyifli; ironik dili harika.', lendTo: 'Elif', lentDaysAgo: 12, dueInDays: 18),
    _BookSpec('9781435136168', 'Frankenstein', 'Mary Shelley', 207, BookGenre.sciFiFantasy, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '84', languageCode: 'en'), month: 2, day: 9, rating: 4, review: 'Yaratığın yalnızlığı beklediğimden çok daha dokunaklıydı.'),
    _BookSpec('9780253204271', 'The Time Machine', 'H. G. Wells', 218, BookGenre.sciFiFantasy, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '35', languageCode: 'en'), month: 3, day: 3, rating: 4, review: 'Kısa ama fikir yüklü; Eloi ve Morlock ayrımı hâlâ güncel.'),
    _BookSpec('9781979064927', 'Alice\'s Adventures in Wonderland', 'Lewis Carroll', 190, BookGenre.children, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '11', languageCode: 'en'), month: 3, day: 27, rating: 5, review: 'Kelime oyunları ve absürt mantığıyla her yaşta keyif veriyor.', lendTo: 'Murat', lentDaysAgo: 45, dueInDays: -15),
    _BookSpec('9781631060663', 'Peter Pan', 'J. M. Barrie', 160, BookGenre.children, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '16', languageCode: 'en'), month: 4, day: 19, rating: 4, review: 'Büyümek üzerine sandığımdan çok daha hüzünlü bir kitap.'),
    _BookSpec('9781770832381', 'The Wonderful Wizard of Oz', 'L. Frank Baum', 164, BookGenre.children, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '55', languageCode: 'en'), month: 5, day: 8, rating: 4, review: 'Sarı tuğlalı yol macerası sade ve sıcak bir dille anlatılmış.'),
    _BookSpec('9781495491184', 'The Art of War', 'Sun Tzu', 66, BookGenre.other, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '132', languageCode: 'en'), month: 5, day: 30, rating: 4, review: 'Strateji üzerine kısa ve yoğun notlar; iş hayatına da uyarlanabiliyor.', lendTo: 'Zeynep', lentDaysAgo: 20, dueInDays: 10),
    _BookSpec('9781557423603', 'As a Man Thinketh', 'James Allen', 52, BookGenre.personalDevelopment, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '4507', languageCode: 'en'), month: 6, day: 21, rating: 5, review: 'Bir oturuşta biten, düşüncenin gücü üzerine sade bir kitap.'),
    _BookSpec('9780312257378', 'Narrative of the Life of Frederick Douglass', 'Frederick Douglass', 188, BookGenre.biography, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '23', languageCode: 'en'), month: 7, day: 12, rating: 5, review: 'Okuma yazmanın özgürlükle bağını bu kadar güçlü anlatan az kitap var.'),
    _BookSpec('9786058105973', 'Kürk Mantolu Madonna', 'Sabahattin Ali', 176, BookGenre.novel, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.wikisource, sourceId: 'Kürk Mantolu Madonna', languageCode: 'tr'), month: 8, day: 4, rating: 5, review: 'Raif Efendi\'nin defteri insanı derinden sarsıyor; 1943 baskısının dili de ayrı bir tat veriyor.', lendTo: 'Can', lentDaysAgo: 8, dueInDays: 22),
    _BookSpec('9780857088468', 'Meditations', 'Marcus Aurelius', 192, BookGenre.philosophy, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '2680', languageCode: 'en'), month: 9, day: 1, rating: 4, review: 'Her gün birkaç sayfa okunacak türden; sakinleştirici bir rehber.'),
    _BookSpec('9780451528254', 'The Story of My Life', 'Helen Keller', 240, BookGenre.biography, ReadingStatus.finished, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '2397', languageCode: 'en'), month: 10, day: 6, rating: 5, review: '"Su" kelimesini öğrendiği sahne unutulmaz.'),
    _BookSpec('9781435131828', 'Crime and Punishment', 'Fyodor Dostoyevsky', 551, BookGenre.novel, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '2554', languageCode: 'en'), percent: 52),
    _BookSpec('9786051211879', 'Nutuk', 'Mustafa Kemal Atatürk', 589, BookGenre.history, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.wikisource, sourceId: 'Nutuk', languageCode: 'tr'), percent: 30),
    _BookSpec('9781515338413', 'Moby Dick', 'Herman Melville', 664, BookGenre.novel, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '2701', languageCode: 'en'), percent: 18),
    _BookSpec('9780674637528', 'On the Origin of Species', 'Charles Darwin', 540, BookGenre.science, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '1228', languageCode: 'en'), percent: 41),
    _BookSpec('9780808509677', 'Leaves of Grass', 'Walt Whitman', 490, BookGenre.poetry, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '1322', languageCode: 'en'), percent: 65),
    _BookSpec('9780199537099', 'Thus Spoke Zarathustra', 'Friedrich Nietzsche', 384, BookGenre.philosophy, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '1998', languageCode: 'en'), percent: 23),
    _BookSpec('9780192801760', 'Self-Help', 'Samuel Smiles', 432, BookGenre.personalDevelopment, ReadingStatus.reading, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '935', languageCode: 'en'), percent: 70),
    _BookSpec('9781561385157', 'Dracula', 'Bram Stoker', 528, BookGenre.novel, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '345', languageCode: 'en')),
    _BookSpec('9780870216787', 'Twenty Thousand Leagues Under the Sea', 'Jules Verne', 416, BookGenre.sciFiFantasy, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '164', languageCode: 'en')),
    _BookSpec('9781774264614', 'The War of the Worlds', 'H. G. Wells', 185, BookGenre.sciFiFantasy, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '36', languageCode: 'en')),
    _BookSpec('9780452287846', 'Relativity: The Special and General Theory', 'Albert Einstein', 288, BookGenre.science, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '30155', languageCode: 'en'), owned: false),
    _BookSpec('9781453730416', 'The Voyage of the Beagle', 'Charles Darwin', 208, BookGenre.science, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '944', languageCode: 'en')),
    _BookSpec('9781545524138', 'The History of the Peloponnesian War', 'Thucydides', 308, BookGenre.history, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '7142', languageCode: 'en'), owned: false),
    _BookSpec('9781602069312', 'A Short History of the World', 'H. G. Wells', 476, BookGenre.history, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '35461', languageCode: 'en')),
    _BookSpec('9780521118767', 'The Republic', 'Plato', 364, BookGenre.philosophy, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '1497', languageCode: 'en'), owned: false),
    _BookSpec('9780497010195', 'The Autobiography of Benjamin Franklin', 'Benjamin Franklin', 276, BookGenre.biography, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '20203', languageCode: 'en')),
    _BookSpec('9781595400161', 'Poems by Emily Dickinson', 'Emily Dickinson', 120, BookGenre.poetry, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '12242', languageCode: 'en')),
    _BookSpec('9781480270251', 'Grimm\'s Fairy Tales', 'Jacob and Wilhelm Grimm', 283, BookGenre.children, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '2591', languageCode: 'en')),
    _BookSpec('9781604597820', 'The Elements of Style', 'William Strunk Jr.', 69, BookGenre.other, ReadingStatus.toRead, DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '37134', languageCode: 'en')),
  ];

  static const List<_QuoteSpec> _quotes = [
    _QuoteSpec('9780140817591', 'It is a truth universally acknowledged, that a single man in possession of a good fortune must be in want of a wife.', 14, favorite: true),
    _QuoteSpec('9781515338413', 'Call me Ishmael.', 14),
    _QuoteSpec('9781435136168', 'Beware, for I am fearless and therefore powerful.', 152),
    _QuoteSpec('9781435131828', 'Pain and suffering are always inevitable for a large intelligence and a deep heart.', 269),
    _QuoteSpec('9781979064927', '“Curiouser and curiouser!” cried Alice', 16),
    _QuoteSpec('9781631060663', 'All children, except one, grow up.', 1),
    _QuoteSpec('9781770832381', 'There is no place like home.', 25),
    _QuoteSpec('9780808509677', 'I celebrate myself, and sing myself,', 23),
    _QuoteSpec('9781595400161', 'Hope is the thing with feathers', 39),
    _QuoteSpec('9781495491184', 'All warfare is based on deception.', 19, favorite: true),
    _QuoteSpec('9780674637528', 'There is grandeur in this view of life, with its several powers, having been originally breathed into a few forms or into one;', 523),
    _QuoteSpec('9780312257378', 'You have seen how a man was made a slave; you shall see how a slave was made a man.', 108, favorite: true),
    _QuoteSpec('9780199537099', 'I tell you: one must still have chaos in one, to give birth to a dancing star.', 26, favorite: true),
    _QuoteSpec('9781557423603', '"As a man thinketh in his heart so is he,"', 2),
    _QuoteSpec('9780192801760', '“HEAVEN helps those who help themselves” is a well-tried maxim, embodying in a small compass the results of vast human experience.', 14),
    _QuoteSpec('9781561385157', '“Listen to them--the children of the night. What music they make!”', 26),
    _QuoteSpec('9780857088468', 'The best kind of revenge is, not to become like unto them.', 11),
    _QuoteSpec('9786051211879', '1335 senesi Mayıs’ının on dokuzuncu günü Samsun’a çıktım.', 1, favorite: true),
    _QuoteSpec('9786051211879', 'Ey Türk gençliği! Birinci vazifen, Türk istiklâlini, Türk cumhuriyetini, ilelebet muhafaza ve müdafaa etmektir.', 501),
    _QuoteSpec('9786058105973', 'Simdiye kadar tesadüf ettiğim insanlardan bir tanesi benim üzerimde belki en büyük tesiri yapmıştır.', 1, favorite: true),
  ];

  /// Fiziksel kopyası olan ve şu an ödünçte olmayan kitaplardan; biri geç iade edilmiş.
  static const List<_ReturnedLoanSpec> _returnedLoans = [
    _ReturnedLoanSpec('9781435136168', 'Selin', 120, 95, dueDaysAgo: 100),
    _ReturnedLoanSpec('9781435131828', 'Burak', 80, 62, dueDaysAgo: 60),
    _ReturnedLoanSpec('9780857088468', 'Elif', 40, 30),
    _ReturnedLoanSpec('9781561385157', 'Murat', 200, 190, dueDaysAgo: 186),
  ];

  static const List<_NoteSpec> _notes = [
    _NoteSpec('9781435131828', 'Raskolnikov\'un "olağanüstü insan" teorisi ile vicdanı arasındaki çatışma çok iyi işlenmiş. Porfiri ile konuşmaları ikinci kez okumak istiyorum.'),
    _NoteSpec('9786051211879', 'Vesikalar bölümü uzun; önce ana metni bitirip vesikalara sonra dönmeyi düşünüyorum.'),
    _NoteSpec('9780674637528', 'Son bölümdeki "endless forms most beautiful" cümlesini sınıfta paylaşmak için not aldım.'),
    _NoteSpec('9780192801760', 'Her bölümün sonundaki biyografi örneklerini kısa bir listeye çıkarıyorum.'),
  ];
}

class _BookSpec {
  const _BookSpec(
    this.isbn,
    this.title,
    this.author,
    this.pages,
    this.genre,
    this.status,
    this.edition, {
    this.month = 1,
    this.day = 1,
    this.rating = 4,
    this.review = '',
    this.percent = 0,
    this.owned = true,
    this.lendTo,
    this.lentDaysAgo = 0,
    this.dueInDays = 0,
  });

  final String isbn;
  final String title;
  final String author;
  final int pages;
  final BookGenre genre;
  final ReadingStatus status;
  final DigitalEditionModel edition;
  final int month;
  final int day;
  final int rating;
  final String review;
  final int percent;
  final bool owned;
  final String? lendTo;
  final int lentDaysAgo;
  final int dueInDays;
}

/// İadesi alınmış örnek ödünç: kime, kaç gün önce verildi / iade günüydü / geri alındı.
class _ReturnedLoanSpec {
  const _ReturnedLoanSpec(this.isbn, this.borrower, this.lentDaysAgo, this.returnedDaysAgo, {this.dueDaysAgo});

  final String isbn;
  final String borrower;
  final int lentDaysAgo;
  final int returnedDaysAgo;
  final int? dueDaysAgo;
}

class _QuoteSpec {
  const _QuoteSpec(this.isbn, this.text, this.page, {this.favorite = false});

  final String isbn;
  final String text;
  final int page;
  final bool favorite;
}

class _NoteSpec {
  const _NoteSpec(this.isbn, this.text);

  final String isbn;
  final String text;
}
