import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/loan_reminder_controller.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/loan_reminder_model.dart';
import 'package:kitalog/core/models/reading_status.dart';

import '../helpers/fake_reminder_engine.dart';
import '../helpers/test_dependencies.dart';

BookModel _book(String id, {LoanModel? loan, bool owned = true}) => BookModel(
  id: id,
  title: 'Kitap $id',
  authors: const ['Yazar'],
  pageCount: 100,
  genre: BookGenre.novel,
  status: ReadingStatus.toRead,
  isOwned: owned,
  loan: loan,
  addedAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 10, 22, 12);

  group('plan', () {
    test('iade gününden bir gün önce ve iade günü saat 10:00; zamana göre sıralı', () {
      final plan = LoanReminderController.plan([
        _book('b', loan: LoanModel(borrowerName: 'B', lentAt: DateTime(2026, 10, 1), dueAt: DateTime(2026, 10, 30))),
        _book('a', loan: LoanModel(borrowerName: 'A', lentAt: DateTime(2026, 10, 1), dueAt: DateTime(2026, 10, 25, 18))),
      ], now);
      expect(plan.map((r) => (r.bookId, r.kind, r.scheduledAt)), [
        ('a', LoanReminderKind.dueTomorrow, DateTime(2026, 10, 24, 10)),
        ('a', LoanReminderKind.dueToday, DateTime(2026, 10, 25, 10)),
        ('b', LoanReminderKind.dueTomorrow, DateTime(2026, 10, 29, 10)),
        ('b', LoanReminderKind.dueToday, DateTime(2026, 10, 30, 10)),
      ]);
    });

    test('geçmişte kalan hatırlatma, tarihsiz, iade alınmış ve fiziksel olmayan kitap planlanmaz', () {
      final plan = LoanReminderController.plan([
        // Yarın iade: "yarın" hatırlatması bugün 10:00'da geçti, yalnızca iade günü kalır.
        _book('tomorrow', loan: LoanModel(borrowerName: 'A', lentAt: DateTime(2026, 10, 1), dueAt: DateTime(2026, 10, 23))),
        _book('overdue', loan: LoanModel(borrowerName: 'B', lentAt: DateTime(2026, 9, 1), dueAt: DateTime(2026, 10, 1))),
        _book('nodue', loan: LoanModel(borrowerName: 'C', lentAt: DateTime(2026, 10, 1))),
        _book('digital', owned: false, loan: LoanModel(borrowerName: 'D', lentAt: DateTime(2026, 10, 1), dueAt: DateTime(2026, 11, 1))),
        _book('free'),
      ], now);
      expect(plan.map((r) => (r.bookId, r.kind)), [('tomorrow', LoanReminderKind.dueToday)]);
    });

    test('ödünç verildiği gün "yarın iade" hatırlatması kurulmaz', () {
      final lentToday = DateTime(2026, 10, 22, 8);
      final plan = LoanReminderController.plan([
        _book('a', loan: LoanModel(borrowerName: 'A', lentAt: lentToday, dueAt: DateTime(2026, 10, 23))),
      ], DateTime(2026, 10, 22, 9));
      expect(plan.map((r) => r.kind), [LoanReminderKind.dueToday]);
    });

    test('LoanReminderModel JSON gidiş-dönüşü', () {
      final model = LoanReminderModel(bookId: 'x', kind: LoanReminderKind.dueTomorrow, scheduledAt: DateTime(2026, 10, 24, 10));
      expect(LoanReminderModel.fromJson(model.toJson()), model);
      expect(model.copyWith(kind: LoanReminderKind.dueToday).kind, LoanReminderKind.dueToday);
    });
  });

  group('senkron', () {
    late AppDependencies deps;
    late FakeReminderEngine engine;
    late LoanReminderController controller;

    Future<void> setUpWith(FakeReminderEngine fake) async {
      engine = fake;
      deps = await createTestDependencies({}, null, null, null, null, null, engine);
      controller = LoanReminderController(
        library: deps.libraryController,
        settings: deps.settingsController,
        engine: engine,
        clock: () => now,
      );
      addTearDown(controller.dispose);
    }

    test('açılışta kitaplar yüklenince plan kurulur, izin istenmez', () async {
      await setUpWith(FakeReminderEngine());
      await controller.start();
      await controller.idle;
      expect(engine.initializeCalls, 0, reason: 'motoru NotificationController hazırlar');
      expect(engine.replaceCalls, 0, reason: 'kitaplar henüz yüklenmedi');

      await deps.libraryController.load();
      await controller.idle;
      expect(engine.replaceCalls, 1);
      expect(engine.permissionRequests, 0);
      expect(engine.scheduled, isNotEmpty, reason: 'örnek veride iade tarihi gelecekte olan ödünçler var');
      expect(engine.channel?.name, 'Ödünç hatırlatmaları');
    });

    test('yeni iade tarihli ödünç kaydedilince izin istenir ve hatırlatma eklenir', () async {
      await setUpWith(FakeReminderEngine());
      await deps.libraryController.load();
      await controller.start();
      await controller.idle;
      final before = engine.scheduled.length;
      final book = deps.libraryController.books.value.firstWhere((b) => b.isOwned && !b.isLent);
      await deps.libraryController.lendBook(
        book.id,
        LoanModel(borrowerName: 'Deniz', lentAt: now, dueAt: DateTime(2026, 11, 5)),
      );
      await controller.idle;
      expect(engine.permissionRequests, 1);
      expect(engine.scheduled.length, before + 2);
      final mine = engine.scheduled.where((n) => n.payload == 'book:${book.id}').toList();
      expect(mine.map((n) => n.title), ['Yarın iade günü', 'Bugün iade günü']);
      expect(mine.first.body, 'Deniz, “${book.title}” kitabını geri getirmeli.');
      expect(mine.first.at, DateTime(2026, 11, 4, 10));
    });

    test('plan değişmezse (ör. okuma ilerlemesi) bildirimlere dokunulmaz; iade alınınca izin istenmeden kaldırılır', () async {
      await setUpWith(FakeReminderEngine());
      await deps.libraryController.load();
      await controller.start();
      await controller.idle;
      final calls = engine.replaceCalls;
      final reading = deps.libraryController.books.value.first;
      await deps.libraryController.setCurrentPage(reading.id, 5);
      await controller.idle;
      expect(engine.replaceCalls, calls);

      final lent = deps.libraryController.lentBooks.firstWhere((b) => engine.scheduled.any((n) => n.payload == 'book:${b.id}'));
      await deps.libraryController.returnBook(lent.id);
      await controller.idle;
      expect(engine.replaceCalls, calls + 1);
      expect(engine.scheduled.any((n) => n.payload == 'book:${lent.id}'), isFalse);
      expect(engine.permissionRequests, 0);
    });

    test('dil değişince metinler yeni dilde yeniden kurulur', () async {
      await setUpWith(FakeReminderEngine());
      await deps.libraryController.load();
      await controller.start();
      await controller.idle;
      await deps.settingsController.setLocaleCode('en');
      await controller.idle;
      expect(engine.channel?.name, 'Loan reminders');
      expect(engine.scheduled.first.title, anyOf('Due back tomorrow', 'Due back today'));
      expect(engine.permissionRequests, 0);

      final calls = engine.replaceCalls;
      await deps.settingsController.setThemeMode(ThemeMode.light);
      await controller.idle;
      expect(engine.replaceCalls, calls, reason: 'tema değişikliği bildirimleri etkilemez');
    });

    test('anahtar kapatılınca tüm hatırlatmalar silinir, açılınca izin istenip yeniden kurulur', () async {
      await setUpWith(FakeReminderEngine());
      await deps.libraryController.load();
      await controller.start();
      await controller.idle;
      final planned = engine.scheduled.length;
      expect(planned, greaterThan(0));

      expect(await controller.setEnabled(false), isTrue);
      await controller.idle;
      expect(deps.settingsController.state.value.loanRemindersEnabled, isFalse);
      expect(engine.scheduled, isEmpty);
      expect(engine.permissionRequests, 0);

      // Kapalıyken ödünç verilen kitap için ne bildirim kurulur ne izin istenir.
      final book = deps.libraryController.books.value.firstWhere((b) => b.isOwned && !b.isLent);
      await deps.libraryController.lendBook(book.id, LoanModel(borrowerName: 'Ece', lentAt: now, dueAt: DateTime(2026, 11, 5)));
      await controller.idle;
      expect(engine.scheduled, isEmpty);
      expect(engine.permissionRequests, 0);

      expect(await controller.setEnabled(true), isTrue);
      await controller.idle;
      expect(engine.permissionRequests, 1, reason: 'yalnızca anahtar açılırken');
      expect(engine.scheduled.length, planned + 2);
    });

    test('izin verilmezse setEnabled false döner, ayar yine açık kalır', () async {
      await setUpWith(FakeReminderEngine(grantPermission: false));
      await deps.settingsController.setLoanRemindersEnabled(false);
      expect(await controller.setEnabled(true), isFalse);
      expect(deps.settingsController.state.value.loanRemindersEnabled, isTrue);
    });

    test('desteklenmeyen platformda hiçbir şey kurulmaz', () async {
      await setUpWith(FakeReminderEngine(isSupported: false));
      await deps.libraryController.load();
      await controller.start();
      await controller.idle;
      expect(engine.replaceCalls, 0);
    });
  });
}
