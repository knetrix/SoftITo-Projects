import '../models/book_genre.dart';
import '../models/book_model.dart';
import '../models/loan_model.dart';
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
  });

  final List<BookModel> books;
  final List<QuoteModel> quotes;
  final List<NoteModel> notes;
  final ReadingGoalModel goal;
}

/// İlk açılışta (`kitalog.seeded` false iken) bir kez yüklenen örnek veriler.
///
/// Tüm ISBN'ler, baskı başlıkları, sayfa sayıları ve kapak adresleri Open Library
/// API'si üzerinden doğrulanmıştır (`/isbn/<ISBN>.json` ve `covers.../isbn/<ISBN>-L.jpg`).
abstract final class SeedData {
  static const String _coverBase = 'https://covers.openlibrary.org/b/isbn';

  static String coverUrl(String isbn) => '$_coverBase/$isbn-L.jpg';

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
          id: 'seed-quote-$i',
          bookId: 'seed-${_quotes[i].isbn}',
          text: _quotes[i].text,
          page: _quotes[i].page,
          isFavorite: _quotes[i].favorite,
          createdAt: now.subtract(Duration(days: 3 + i * 4)),
        ),
    ];

    final notes = <NoteModel>[
      for (var i = 0; i < _notes.length; i++)
        NoteModel(
          id: 'seed-note-$i',
          bookId: 'seed-${_notes[i].isbn}',
          content: _notes[i].text,
          createdAt: now.subtract(Duration(days: 5 + i * 9)),
          updatedAt: now.subtract(Duration(days: 5 + i * 9)),
        ),
    ];

    return SeedBundle(
      books: books,
      quotes: quotes,
      notes: notes,
      goal: ReadingGoalModel(year: year, targetBookCount: 24),
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
      id: 'seed-${s.isbn}',
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
    );
  }

  static const List<_BookSpec> _specs = [
    // ---- Okundu ----
    _BookSpec('9786058105973', 'Kürk Mantolu Madonna', 'Sabahattin Ali', 176, BookGenre.novel, ReadingStatus.finished, month: 1, day: 12, rating: 5, review: 'Sade anlatımıyla insanı derinden etkileyen, bir oturuşta bitirdiğim bir aşk hikâyesi.'),
    _BookSpec('9786058105959', 'İçimizdeki Şeytan', 'Sabahattin Ali', 288, BookGenre.novel, ReadingStatus.finished, month: 2, day: 20, rating: 4, review: 'Ömer\'in iç hesaplaşması bugün bile çok yerinde.'),
    _BookSpec('9780452284241', 'Animal Farm', 'George Orwell', 128, BookGenre.novel, ReadingStatus.finished, month: 3, day: 8, rating: 4, review: 'Kısa ama çok keskin bir alegori. Sonu insanı düşündürüyor.'),
    _BookSpec('9780048231260', 'The Hobbit', 'J.R.R. Tolkien', 255, BookGenre.sciFiFantasy, ReadingStatus.finished, month: 4, day: 3, rating: 5, review: 'Bilbo\'nun yolculuğu tam bir macera klasiği.', lendTo: 'Murat', lentDaysAgo: 45, dueInDays: -15),
    _BookSpec('9788496822962', 'Fahrenheit 451', 'Ray Bradbury', 150, BookGenre.sciFiFantasy, ReadingStatus.finished, month: 4, day: 22, rating: 4, review: 'Kitapların yasaklandığı bir dünya; bugünün ekran bağımlılığıyla şaşırtıcı bir benzerlik taşıyor.'),
    _BookSpec('9780575074842', 'The Hitchhiker\'s Guide to the Galaxy', 'Douglas Adams', 178, BookGenre.sciFiFantasy, ReadingStatus.finished, month: 5, day: 14, rating: 4, review: 'Absürt mizahı çok eğlenceliydi.', lendTo: 'Elif', lentDaysAgo: 12, dueInDays: 18),
    _BookSpec('9780375508325', 'Cosmos', 'Carl Sagan', 365, BookGenre.science, ReadingStatus.finished, month: 6, day: 2, rating: 5, review: 'Evrene bakışımı değiştiren kitap. Sagan\'ın dili bilimi şiire dönüştürüyor.'),
    _BookSpec('9780593189641', 'Atomic Habits', 'James Clear', 320, BookGenre.personalDevelopment, ReadingStatus.finished, month: 6, day: 25, rating: 4, review: 'Küçük alışkanlıklar üzerine pratik ve uygulanabilir bir rehber.', lendTo: 'Zeynep', lentDaysAgo: 20, dueInDays: 10),
    _BookSpec('9789352782772', 'The Diary of a Young Girl', 'Anne Frank', 242, BookGenre.biography, ReadingStatus.finished, month: 7, day: 17, rating: 5, review: 'Savaşın gölgesinde bir gencin umudu. Çok etkileyici.'),
    _BookSpec('9786254050657', 'Küçük Prens', 'Antoine de Saint-Exupéry', 96, BookGenre.children, ReadingStatus.finished, month: 8, day: 9, rating: 5, review: 'Her yaşta başka bir şey söyleyen bir kitap.'),
    _BookSpec('9780425287675', 'Matilda', 'Roald Dahl', 256, BookGenre.children, ReadingStatus.finished, month: 9, day: 5, rating: 4, review: 'Kitap sevgisini anlatan neşeli bir hikâye.'),
    _BookSpec('9786257077798', 'Orhan Veli Bütün Şiirleri', 'Orhan Veli Kanık', 264, BookGenre.poetry, ReadingStatus.finished, month: 9, day: 21, rating: 5, review: 'Garip akımının sadeliği hâlâ taze.', lendTo: 'Can', lentDaysAgo: 8, dueInDays: 22),
    _BookSpec('9786051211879', 'Nutuk', 'Mustafa Kemal Atatürk', 589, BookGenre.history, ReadingStatus.finished, month: 10, day: 10, rating: 5, review: 'Kurtuluş Savaşı\'nı birinci ağızdan okumak değerliydi.'),
    // ---- Okunuyor ----
    _BookSpec('9780340839935', 'Dune', 'Frank Herbert', 608, BookGenre.sciFiFantasy, ReadingStatus.reading, percent: 52),
    _BookSpec('9789754589023', 'Suç ve Ceza', 'Fyodor Dostoyevski', 704, BookGenre.novel, ReadingStatus.reading, percent: 30),
    _BookSpec('9780679764861', 'Pale Blue Dot', 'Carl Sagan', 427, BookGenre.science, ReadingStatus.reading, percent: 21),
    _BookSpec('9780224038096', 'Guns, Germs and Steel', 'Jared Diamond', 480, BookGenre.history, ReadingStatus.reading, percent: 31),
    _BookSpec('9780368886317', 'Thus Spoke Zarathustra', 'Friedrich Nietzsche', 252, BookGenre.philosophy, ReadingStatus.reading, percent: 16),
    _BookSpec('9780316323543', 'Long Walk to Freedom', 'Nelson Mandela', 656, BookGenre.biography, ReadingStatus.reading, percent: 46),
    _BookSpec('9789754700114', 'Tutunamayanlar', 'Oğuz Atay', 736, BookGenre.novel, ReadingStatus.reading, percent: 68),
    _BookSpec('9786054054206', 'İnsanın Anlam Arayışı', 'Viktor E. Frankl', 166, BookGenre.personalDevelopment, ReadingStatus.reading, percent: 60),
    // ---- Okunacak ----
    _BookSpec('9789759955748', 'Huzur', 'Ahmet Hamdi Tanpınar', 391, BookGenre.novel, ReadingStatus.toRead),
    _BookSpec('9789750506093', 'Masumiyet Müzesi', 'Orhan Pamuk', 592, BookGenre.novel, ReadingStatus.toRead),
    _BookSpec('9780571218318', 'Snow', 'Orhan Pamuk', 440, BookGenre.novel, ReadingStatus.toRead, owned: false),
    _BookSpec('9781590171394', 'Memed, My Hawk', 'Yaşar Kemal', 392, BookGenre.novel, ReadingStatus.toRead, owned: false),
    _BookSpec('9780857501004', 'A Brief History of Time', 'Stephen Hawking', 256, BookGenre.science, ReadingStatus.toRead),
    _BookSpec('9781784703936', 'Homo Deus', 'Yuval Noah Harari', 513, BookGenre.history, ReadingStatus.toRead),
    _BookSpec('9780525512172', '21 Lessons for the 21st Century', 'Yuval Noah Harari', 372, BookGenre.philosophy, ReadingStatus.toRead),
    _BookSpec('9780857088468', 'Meditations', 'Marcus Aurelius', 192, BookGenre.philosophy, ReadingStatus.toRead),
    _BookSpec('9780743269513', 'The 7 Habits of Highly Effective People', 'Stephen R. Covey', 384, BookGenre.personalDevelopment, ReadingStatus.toRead),
    _BookSpec('9780349139593', 'Steve Jobs', 'Walter Isaacson', 568, BookGenre.biography, ReadingStatus.toRead, owned: false),
    _BookSpec('9789750803772', 'Memleketimden İnsan Manzaraları', 'Nâzım Hikmet', 544, BookGenre.poetry, ReadingStatus.toRead),
    _BookSpec('9780808509677', 'Leaves of Grass', 'Walt Whitman', 490, BookGenre.poetry, ReadingStatus.toRead),
    _BookSpec('9781979064927', 'Alice\'s Adventures in Wonderland', 'Lewis Carroll', 190, BookGenre.children, ReadingStatus.toRead),
    _BookSpec('9780688002305', 'Zen and the Art of Motorcycle Maintenance', 'Robert M. Pirsig', 418, BookGenre.other, ReadingStatus.toRead),
    _BookSpec('9781604597820', 'The Elements of Style', 'William Strunk Jr.', 69, BookGenre.other, ReadingStatus.toRead),
  ];

  // Metinler yayımlanmış eserlerden birebir alınmıştır. Sayfa numaraları yaygın
  // baskılara göre verilmiştir ve baskıya göre değişebilir.
  static const List<_QuoteSpec> _quotes = [
    _QuoteSpec('9780340839935', 'I must not fear. Fear is the mind-killer.', 8, favorite: true),
    _QuoteSpec('9780340839935', 'A beginning is the time for taking the most delicate care that the balances are correct.', 3),
    _QuoteSpec('9788496822962', 'It was a pleasure to burn.', 3),
    _QuoteSpec('9788496822962', 'There must be something in books, things we can\'t imagine, to make a woman stay in a burning house; there must be something there.', 48),
    _QuoteSpec('9780575074842', 'Space is big. You just won\'t believe how vastly, hugely, mind-bogglingly big it is.', 57, favorite: true),
    _QuoteSpec('9780048231260', 'In a hole in the ground there lived a hobbit.', 1),
    _QuoteSpec('9780375508325', 'The Cosmos is all that is or ever was or ever will be.', 1, favorite: true),
    _QuoteSpec('9780375508325', 'We are a way for the cosmos to know itself.', 345),
    _QuoteSpec('9780679764861', 'Look again at that dot. That\'s here. That\'s home. That\'s us.', 6, favorite: true),
    _QuoteSpec('9780452284241', 'All animals are equal, but some animals are more equal than others.', 112),
    _QuoteSpec('9780593189641', 'You do not rise to the level of your goals. You fall to the level of your systems.', 27, favorite: true),
    _QuoteSpec('9780593189641', 'Every action you take is a vote for the type of person you wish to become.', 38),
    _QuoteSpec('9780316323543', 'I learned that courage was not the absence of fear, but the triumph over it.', 622),
    _QuoteSpec('9789352782772', 'In spite of everything I still believe that people are really good at heart.', 237, favorite: true),
    _QuoteSpec('9780368886317', 'One must still have chaos in oneself to be able to give birth to a dancing star.', 17),
    _QuoteSpec('9781979064927', 'Curiouser and curiouser!', 14),
    _QuoteSpec('9780425287675', 'So Matilda\'s strong young mind continued to grow, nurtured by the voices of all those authors who had sent their books out into the world like bottles on the sea.', 20),
    _QuoteSpec('9780808509677', 'Do I contradict myself? Very well then I contradict myself, (I am large, I contain multitudes.)', 88),
    _QuoteSpec('9780743269513', 'Begin with the end in mind.', 95),
    _QuoteSpec('9780688002305', 'The only Zen you find on the tops of mountains is the Zen you bring up there.', 19),
    _QuoteSpec('9780224038096', 'History followed different courses for different peoples because of differences among peoples\' environments, not because of biological differences among peoples themselves.', 25),
    _QuoteSpec('9786051211879', '1919 yılı Mayıs\'ının 19\'uncu günü Samsun\'a çıktım.', 1),
    _QuoteSpec('9786257077798', 'İstanbul\'u dinliyorum, gözlerim kapalı', 20),
  ];

  static const List<_NoteSpec> _notes = [
    _NoteSpec('9780340839935', 'Paul\'un kaderi ile Arrakis\'in ekolojisi birbirine çok iyi bağlanmış. İkinci bölümü bitirince Fremen kültürünü tekrar okumak istiyorum.'),
    _NoteSpec('9789754589023', 'Raskolnikov\'un monoloğu çok yoğun; bölümleri kısa aralıklarla okumak daha iyi gidiyor.'),
    _NoteSpec('9780375508325', 'Sagan\'ın "kozmik takvim" benzetmesini arkadaşlarla paylaşmak için sakla.'),
    _NoteSpec('9780593189641', 'Alışkanlık yığma yöntemini sabah rutinime ekledim: kahve sonrası 10 sayfa okuma.'),
  ];
}

class _BookSpec {
  const _BookSpec(
    this.isbn,
    this.title,
    this.author,
    this.pages,
    this.genre,
    this.status, {
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
