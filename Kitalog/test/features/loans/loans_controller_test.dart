import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/controllers/library_controller.dart';
import 'package:kitalog/core/data/seed_data.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/features/loans/controllers/loans_controller.dart';
import 'package:kitalog/features/loans/models/loans_model.dart';

import '../../helpers/test_dependencies.dart';

void main() {
  final now = DateTime(2026, 10, 22, 12);

  Future<(LoansController, LibraryController)> create() async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final controller = LoansController(library: deps.libraryController, clock: () => now);
    addTearDown(controller.dispose);
    return (controller, deps.libraryController);
  }

  test('ödünçteki kitaplar en acil iade başta sıralanır; sayımlar doğru', () async {
    final (controller, library) = await create();
    final state = controller.state.value;
    expect(state.active.length, library.lentBooks.length);
    expect(state.active.every((b) => b.isLent), isTrue);
    // Örnek veride Alice 15 gün önce iade edilmeliydi: en başta.
    expect(state.active.first.title, "Alice's Adventures in Wonderland");
    final dues = [for (final b in state.active) b.loan!.dueAt!];
    expect(dues, [...dues]..sort());
    expect(state.overdueCount, 1);
  });

  test('iade tarihi olmayanlar sona, en uzun süredir ödünçte olan önce', () async {
    final (controller, library) = await create();
    final free = library.books.value.where((b) => b.isOwned && !b.isLent).take(2).toList();
    await controller.lend(free[0].id, LoanModel(borrowerName: 'Yeni', lentAt: now));
    await controller.lend(free[1].id, LoanModel(borrowerName: 'Eski', lentAt: now.subtract(const Duration(days: 30))));
    final active = controller.state.value.active;
    expect(active[active.length - 2].loan!.borrowerName, 'Eski');
    expect(active.last.loan!.borrowerName, 'Yeni');
  });

  test('yaklaşan iade: bugün ile ${LoansModel.dueSoonDays} gün arası', () async {
    final (controller, library) = await create();
    final before = controller.state.value.dueSoonCount;
    final free = library.books.value.where((b) => b.isOwned && !b.isLent).take(3).toList();
    await controller.lend(free[0].id, LoanModel(borrowerName: 'A', lentAt: now, dueAt: now));
    await controller.lend(free[1].id, LoanModel(borrowerName: 'B', lentAt: now, dueAt: now.add(const Duration(days: 3))));
    await controller.lend(free[2].id, LoanModel(borrowerName: 'C', lentAt: now, dueAt: now.add(const Duration(days: 4))));
    expect(controller.state.value.dueSoonCount, before + 2);
  });

  test('ödünç verilebilecekler: fiziksel kopyası olan ve ödünçte olmayan kitaplar', () async {
    final (controller, library) = await create();
    final lendable = controller.state.value.lendable;
    expect(lendable, isNotEmpty);
    expect(lendable.every((b) => b.isOwned && !b.isLent), isTrue);
    expect(lendable.length, library.books.value.where((b) => b.isOwned && !b.isLent).length);

    await controller.lend(lendable.first.id, LoanModel(borrowerName: 'Deniz', lentAt: now));
    expect(controller.state.value.lendable.map((b) => b.id), isNot(contains(lendable.first.id)));
    expect(controller.state.value.active.map((b) => b.id), contains(lendable.first.id));
  });

  test('düzenleme kime ve iade tarihini değiştirir, veriliş tarihi ve geçmiş korunur', () async {
    final (controller, library) = await create();
    final book = controller.state.value.active.first;
    final historyBefore = controller.state.value.history.length;
    await controller.updateLoan(book.id, book.loan!.copyWith(borrowerName: 'Mert', dueAt: now.add(const Duration(days: 7))));
    final updated = library.bookById(book.id)!.loan!;
    expect(updated.borrowerName, 'Mert');
    expect(updated.lentAt, book.loan!.lentAt);
    expect(controller.state.value.history.length, historyBefore);
    expect(controller.state.value.overdueCount, 0);
  });

  test('iade alınan kitap listeden çıkar ve geçmişin başına eklenir', () async {
    final (controller, library) = await create();
    final book = controller.state.value.active.first;
    final borrower = book.loan!.borrowerName;
    final historyBefore = controller.state.value.history.length;
    await controller.markReturned(book.id);
    final state = controller.state.value;
    expect(state.active.map((b) => b.id), isNot(contains(book.id)));
    expect(state.history.length, historyBefore + 1);
    expect(state.history.first.book.id, book.id);
    expect(state.history.first.record.borrowerName, borrower);
    expect(state.lendable.map((b) => b.id), contains(book.id));
  });

  test('örnek geçmiş yüklenir, en son iade başta; kitabı silinen kayıt gösterilmez', () async {
    final (controller, library) = await create();
    final history = controller.state.value.history;
    expect(history.length, SeedData.build(now).loanHistory.length);
    final returned = [for (final h in history) h.record.returnedAt];
    expect(returned, [...returned]..sort((a, b) => b.compareTo(a)));
    expect(history.any((h) => h.record.wasLate), isTrue);

    await library.deleteBook(history.first.book.id);
    expect(controller.state.value.history.length, history.length - 1);
  });

  test('model JSON gidiş-dönüşü', () async {
    final (controller, _) = await create();
    final state = controller.state.value;
    final back = LoansModel.fromJson(state.toJson());
    expect(back.active.map((b) => b.id), state.active.map((b) => b.id));
    expect(back.history.map((h) => h.record.id), state.history.map((h) => h.record.id));
    expect(back.lendable.length, state.lendable.length);
    expect(back.overdueCount, state.overdueCount);
    expect(back.dueSoonCount, state.dueSoonCount);
  });
}
