import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/library_controller.dart';
import 'package:kitalog/core/controllers/reading_reminder_controller.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/app_settings_model.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/reading_log_entry_model.dart';
import 'package:kitalog/core/models/reading_reminder_model.dart';
import 'package:kitalog/core/models/reading_status.dart';

import '../helpers/fake_reminder_engine.dart';
import '../helpers/test_dependencies.dart';

BookModel _book(String id, {ReadingStatus status = ReadingStatus.reading, DateTime? startedAt, int page = 10}) =>
    BookModel(
      id: id,
      title: 'Kitap $id',
      authors: const ['Yazar'],
      pageCount: 100,
      currentPage: page,
      genre: BookGenre.novel,
      status: status,
      isOwned: true,
      startedAt: startedAt ?? DateTime(2026, 10, 20),
      addedAt: DateTime(2026, 9, 1),
    );

ReadingLogEntryModel _read(String bookId, int month, int day) =>
    ReadingLogEntryModel(bookId: bookId, day: DateTime(2026, month, day), pages: 5);

void main() {
  // 22 Ekim 2026, öğlen; hatırlatma saati varsayılan 21:00.
  final now = DateTime(2026, 10, 22, 12);
  const daily = AppSettingsModel(readingRemindersEnabled: true);
  const stalled = AppSettingsModel(stalledBookRemindersEnabled: true);

  List<ReadingReminderModel> plan({
    List<BookModel>? books,
    List<ReadingLogEntryModel> log = const [],
    AppSettingsModel settings = daily,
    DateTime? at,
  }) => ReadingReminderController.plan(books: books ?? [_book('a')], log: log, settings: settings, now: at ?? now);

  group('plan', () {
    test('anahtarlar kapalıyken hiçbir şey planlanmaz', () {
      expect(plan(settings: const AppSettingsModel()), isEmpty);
    });

    test('günlük davet önümüzdeki 7 gün, seçilen saatte; konu en son okunan kitap', () {
      final reminders = plan(
        books: [_book('eski', startedAt: DateTime(2026, 10, 1)), _book('yeni'), _book('bitti', status: ReadingStatus.finished)],
        log: [_read('eski', 10, 21)],
      );
      expect(reminders.map((r) => r.scheduledAt), [for (var d = 22; d < 29; d++) DateTime(2026, 10, d, 21)]);
      expect(reminders.map((r) => r.bookId).toSet(), {'eski'}, reason: 'dün ilerlenen kitap, dün başlanan değil');
      expect(reminders.every((r) => r.kind == ReadingReminderKind.daily), isTrue);
    });

    test('saat geçtiyse bugün atlanır; özel saat kullanılır', () {
      expect(plan(at: DateTime(2026, 10, 22, 21, 30)).first.scheduledAt, DateTime(2026, 10, 23, 21));
      final early = plan(settings: daily.copyWith(readingReminderMinutes: 7 * 60 + 30));
      expect(early.first.scheduledAt, DateTime(2026, 10, 23, 7, 30));
      expect(early, hasLength(6));
    });

    test('bugün okunduysa bugünün daveti atlanır', () {
      final reminders = plan(log: [_read('a', 10, 22)]);
      expect(reminders.first.scheduledAt, DateTime(2026, 10, 23, 21));
      expect(reminders, hasLength(6));
    });

    test('dün ve öncesinde art arda en az 2 gün okunduysa davet seri metniyle gider', () {
      final notReadToday = plan(log: [_read('a', 10, 19), _read('a', 10, 20), _read('a', 10, 21)]);
      expect((notReadToday[0].kind, notReadToday[0].streakDays), (ReadingReminderKind.streak, 3));
      expect(notReadToday[1].kind, ReadingReminderKind.daily, reason: 'bugün okunmazsa seri yarın bozulur');

      final readToday = plan(log: [_read('a', 10, 21), _read('a', 10, 22)]);
      expect(readToday.first.scheduledAt, DateTime(2026, 10, 23, 21));
      expect((readToday[0].kind, readToday[0].streakDays), (ReadingReminderKind.streak, 2));
      expect(readToday.skip(1).every((r) => r.kind == ReadingReminderKind.daily), isTrue);

      final single = plan(log: [_read('a', 10, 21)]);
      expect(single.first.kind, ReadingReminderKind.daily, reason: 'tek gün seri sayılmaz');
    });

    test('okunan kitap yoksa davet kitapsız planlanır', () {
      final reminders = plan(books: [_book('x', status: ReadingStatus.toRead)]);
      expect(reminders, hasLength(7));
      expect(reminders.every((r) => r.bookId == null), isTrue);
    });

    test('yarım kalan kitap: son ilerlemeden 14 gün sonra bir kez; geçmişte kalan ve okunmayanlar planlanmaz', () {
      final reminders = plan(
        settings: stalled,
        books: [
          _book('kayitli', startedAt: DateTime(2026, 9, 1)),
          _book('baslangic', startedAt: DateTime(2026, 10, 12)),
          _book('gecmis', startedAt: DateTime(2026, 9, 1)),
          _book('okunacak', status: ReadingStatus.toRead, startedAt: DateTime(2026, 10, 12)),
        ],
        log: [_read('kayitli', 10, 15)],
      );
      expect(reminders.map((r) => (r.kind, r.bookId, r.scheduledAt)), [
        (ReadingReminderKind.stalled, 'baslangic', DateTime(2026, 10, 26, 21)),
        (ReadingReminderKind.stalled, 'kayitli', DateTime(2026, 10, 29, 21)),
      ]);
    });

    test('yarım kalan kitap hatırlatması o günün günlük davetinin yerini alır', () {
      final reminders = plan(
        settings: daily.copyWith(stalledBookRemindersEnabled: true),
        books: [_book('a', startedAt: DateTime(2026, 10, 10))],
      );
      expect(reminders, hasLength(7));
      final onDay = reminders.where((r) => r.scheduledAt == DateTime(2026, 10, 24, 21)).toList();
      expect(onDay.map((r) => r.kind), [ReadingReminderKind.stalled]);
    });
  });

  group('senkron', () {
    late AppDependencies deps;
    late FakeReminderEngine engine;
    late LibraryController library;
    late ReadingReminderController controller;

    Future<void> setUpWith(FakeReminderEngine fake) async {
      engine = fake;
      deps = await createTestDependencies({}, null, null, null, null, null, engine);
      // Günlük kayıt ve plan aynı saati görsün diye kitaplık da sabit saatle kurulur.
      library = LibraryController(
        bookRepository: deps.bookRepository,
        quoteRepository: deps.quoteRepository,
        noteRepository: deps.noteRepository,
        goalRepository: deps.goalRepository,
        genreRepository: deps.genreRepository,
        loanHistoryRepository: deps.loanHistoryRepository,
        readingLogRepository: deps.readingLogRepository,
        clock: () => now,
      );
      controller = ReadingReminderController(
        library: library,
        settings: deps.settingsController,
        engine: engine,
        clock: () => now,
      );
      addTearDown(controller.dispose);
      addTearDown(library.dispose);
    }

    test('açılışta kapalı: boş plan kurulur, izin istenmez; açılınca izin istenir ve 7 davet kurulur', () async {
      await setUpWith(FakeReminderEngine());
      await controller.start();
      await controller.idle;
      expect(engine.readingReplaceCalls, 0, reason: 'kitaplar henüz yüklenmedi');
      await library.load();
      await controller.idle;
      expect(engine.readingReplaceCalls, 1);
      expect(engine.readingScheduled, isEmpty);
      expect(engine.permissionRequests, 0);

      expect(await controller.setDailyEnabled(true), isTrue);
      await controller.idle;
      expect(engine.permissionRequests, 1);
      expect(engine.readingScheduled, hasLength(7));
      expect(engine.readingChannel?.name, 'Okuma hatırlatmaları');
      final first = engine.readingScheduled.first;
      expect(first.at, DateTime(2026, 10, 22, 21));
      expect(first.title, 'Okuma zamanı');
      final bookId = first.payload.substring('read:'.length);
      final book = library.bookById(bookId)!;
      expect(first.body, '“${book.title}” kitabında ${book.currentPage}. sayfadasın. 10 dakika okumaya ne dersin?');
      expect(engine.scheduled, isEmpty, reason: 'iade grubuna dokunulmaz');
    });

    test('bugün okununca bugünün daveti hemen kalkar; sayfa çevirmek metni bir kez yeniler', () async {
      await setUpWith(FakeReminderEngine());
      await library.load();
      await deps.settingsController.setReadingRemindersEnabled(true);
      await controller.start();
      await controller.idle;
      final bookId = engine.readingScheduled.first.payload.substring('read:'.length);
      final calls = engine.readingReplaceCalls;

      await library.changePage(bookId, 1);
      await controller.idle;
      expect(engine.readingScheduled.first.at, DateTime(2026, 10, 23, 21));
      expect(engine.readingScheduled, hasLength(6));
      expect(engine.readingReplaceCalls, calls + 1);

      await library.changePage(bookId, 1);
      await library.changePage(bookId, 1);
      await controller.idle;
      expect(engine.readingReplaceCalls, calls + 2, reason: 'yalnızca metin değişti; art arda sayfalar tek kurulum');
      expect(engine.readingScheduled.first.body, contains('${library.bookById(bookId)!.currentPage}. sayfa'));
    });

    test('dil değişince metinler yeni dilde kurulur; kapatınca hepsi silinir', () async {
      await setUpWith(FakeReminderEngine());
      await library.load();
      await deps.settingsController.setReadingRemindersEnabled(true);
      await controller.start();
      await controller.idle;
      await deps.settingsController.setLocaleCode('en');
      await controller.idle;
      expect(engine.readingChannel?.name, 'Reading reminders');
      expect(engine.readingScheduled.first.title, 'Time to read');

      expect(await controller.setDailyEnabled(false), isTrue);
      await controller.idle;
      expect(engine.readingScheduled, isEmpty);
      expect(engine.permissionRequests, 0);
    });

    test('yarım kalan kitap ve seri metinleri', () async {
      await setUpWith(FakeReminderEngine());
      await library.load();
      final reading = library.books.value.where((b) => b.status == ReadingStatus.reading).toList();
      // Bir kitap 10 gün önce başladı ve ilerlemedi: 4 gün sonra hatırlatılır.
      for (final b in reading) {
        await library.updateBook(b.copyWith(startedAt: DateTime(2026, 8, 1)));
      }
      final stale = reading.first;
      await library.updateBook(stale.copyWith(startedAt: DateTime(2026, 10, 12)));
      expect(await controller.setStalledEnabled(true), isTrue);
      await controller.start();
      await controller.idle;
      expect(engine.readingScheduled.map((n) => (n.at, n.title, n.payload)), [
        (DateTime(2026, 10, 26, 21), 'Yarım kalan kitap', 'read:${stale.id}'),
      ]);
      expect(engine.readingScheduled.single.body, contains('14 gündür ilerleme yok'));
    });

    test('desteklenmeyen platformda hiçbir şey kurulmaz', () async {
      await setUpWith(FakeReminderEngine(isSupported: false));
      await library.load();
      await controller.start();
      expect(await controller.setDailyEnabled(true), isTrue);
      await controller.idle;
      expect(engine.readingReplaceCalls, 0);
      expect(engine.permissionRequests, 0);
    });
  });

  test('okunan kitap yokken metin genel davettir ve Okuma Durumu\'na gider', () async {
    final engine = FakeReminderEngine();
    final deps = await createTestDependencies({}, null, null, null, null, null, engine);
    await deps.libraryController.load();
    for (final b in deps.libraryController.books.value.where((b) => b.status == ReadingStatus.reading)) {
      await deps.libraryController.setStatus(b.id, ReadingStatus.toRead);
    }
    await deps.settingsController.setReadingRemindersEnabled(true);
    final controller = ReadingReminderController(
      library: deps.libraryController,
      settings: deps.settingsController,
      engine: engine,
      clock: () => now,
    );
    addTearDown(controller.dispose);
    await controller.start();
    await controller.idle;
    expect(engine.readingScheduled.first.payload, 'readingStatus');
    expect(engine.readingScheduled.first.body, startsWith('Bugün birkaç sayfa okumaya ne dersin?'));
  });
}
