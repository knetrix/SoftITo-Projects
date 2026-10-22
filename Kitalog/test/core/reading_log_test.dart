import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/library_controller.dart';
import 'package:kitalog/core/models/reading_log_entry_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/repositories/book_repository.dart';
import 'package:kitalog/core/repositories/genre_repository.dart';
import 'package:kitalog/core/repositories/goal_repository.dart';
import 'package:kitalog/core/repositories/loan_history_repository.dart';
import 'package:kitalog/core/repositories/note_repository.dart';
import 'package:kitalog/core/repositories/quote_repository.dart';
import 'package:kitalog/core/repositories/reading_log_repository.dart';
import 'package:kitalog/core/storage/local_storage_service.dart';

import '../helpers/test_dependencies.dart';

LibraryController _library(LocalStorageService storage, DateTime Function() clock) => LibraryController(
  bookRepository: BookRepository(storage),
  quoteRepository: QuoteRepository(storage),
  noteRepository: NoteRepository(storage),
  goalRepository: GoalRepository(storage),
  genreRepository: GenreRepository(storage),
  loanHistoryRepository: LoanHistoryRepository(storage),
  readingLogRepository: ReadingLogRepository(storage),
  clock: clock,
);

void main() {
  late LocalStorageService storage;
  late DateTime now;
  late LibraryController library;

  setUp(() async {
    storage = await testStorage();
    now = DateTime(2026, 10, 22, 9);
    library = _library(storage, () => now);
    await library.load();
  });

  tearDown(() => library.dispose());

  String readingBookId() => library.books.value.firstWhere((b) => b.status == ReadingStatus.reading).id;

  test('sayfa ilerleyince bugünün kaydına eklenir; aynı gün birleşir, geri gitmek sayılmaz', () async {
    final id = readingBookId();
    final start = library.bookById(id)!.currentPage;
    expect(library.readingLog.value, isEmpty);

    await library.setCurrentPage(id, start + 5);
    now = DateTime(2026, 10, 22, 20);
    await library.changePage(id, 3);
    await library.changePage(id, -4);
    expect(library.readingLog.value, [ReadingLogEntryModel(bookId: id, day: DateTime(2026, 10, 22), pages: 8)]);

    now = DateTime(2026, 10, 23, 8);
    await library.changePage(id, 2);
    expect(library.readingLog.value.map((e) => (e.day, e.pages)), [(DateTime(2026, 10, 22), 8), (DateTime(2026, 10, 23), 2)]);
  });

  test('biten kitapta sayaç değişmediği için kayıt düşmez', () async {
    final finished = library.books.value.firstWhere((b) => b.status == ReadingStatus.finished);
    await library.setCurrentPage(finished.id, 1);
    expect(library.readingLog.value, isEmpty);
  });

  test('kayıt kalıcıdır, saklama süresini aşan günler silinir, kitap silinince korunur', () async {
    final id = readingBookId();
    await library.changePage(id, 1);
    now = DateTime(2026, 10, 22).add(const Duration(days: LibraryController.readingLogRetentionDays + 1));
    await library.changePage(id, 1);
    expect(library.readingLog.value.map((e) => e.day), [ReadingLogEntryModel.dayOf(now)]);

    await library.deleteBook(id);
    expect(library.readingLog.value, hasLength(1), reason: 'okuma serisi o gün okunmuş sayılmaya devam eder');

    final reloaded = _library(storage, () => now);
    await reloaded.load();
    expect(reloaded.readingLog.value, library.readingLog.value);
    reloaded.dispose();
  });
}
