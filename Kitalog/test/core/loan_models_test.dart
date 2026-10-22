import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/loan_record_model.dart';

void main() {
  final lentAt = DateTime(2026, 10, 1, 18, 30);

  test('daysBetween saat farkını yok sayar, takvim günü sayar', () {
    expect(LoanModel.daysBetween(DateTime(2026, 10, 1, 23, 59), DateTime(2026, 10, 2, 0, 1)), 1);
    expect(LoanModel.daysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 1)), -4);
    // Yaz saati geçişi (Ekim sonu) gün sayısını bozmaz.
    expect(LoanModel.daysBetween(DateTime(2026, 10, 20), DateTime(2026, 11, 3)), 14);
  });

  test('iade günü gecikme sayılmaz, ertesi gün gecikmedir', () {
    final loan = LoanModel(borrowerName: 'Elif', lentAt: lentAt, dueAt: DateTime(2026, 10, 15));
    expect(loan.daysUntilDue(DateTime(2026, 10, 12, 9)), 3);
    expect(loan.daysUntilDue(DateTime(2026, 10, 15, 23)), 0);
    expect(loan.isOverdue(DateTime(2026, 10, 15, 23)), isFalse);
    expect(loan.isOverdue(DateTime(2026, 10, 16, 0, 1)), isTrue);
    expect(loan.daysUntilDue(DateTime(2026, 10, 18)), -3);
    expect(loan.daysOut(DateTime(2026, 10, 1, 20)), 0);
    expect(loan.daysOut(DateTime(2026, 10, 11)), 10);
  });

  test('iade tarihi olmayan ödünç hiç gecikmez', () {
    final loan = LoanModel(borrowerName: 'Can', lentAt: lentAt);
    expect(loan.daysUntilDue(DateTime(2030)), isNull);
    expect(loan.isOverdue(DateTime(2030)), isFalse);
  });

  test('LoanRecordModel ödünçten üretilir, süre ve geç iade hesaplanır, JSON gidiş-dönüşü', () {
    final loan = LoanModel(borrowerName: 'Selin', lentAt: lentAt, dueAt: DateTime(2026, 10, 10));
    final late = LoanRecordModel.fromLoan(id: 'r1', bookId: 'b1', loan: loan, returnedAt: DateTime(2026, 10, 12));
    expect(late.borrowerName, 'Selin');
    expect(late.daysOut, 11);
    expect(late.wasLate, isTrue);
    expect(late.copyWith(returnedAt: DateTime(2026, 10, 10, 22)).wasLate, isFalse, reason: 'iade günü zamanında sayılır');
    expect(late.copyWith(clearDueAt: true).wasLate, isFalse);

    final back = LoanRecordModel.fromJson(late.toJson());
    expect(back.id, 'r1');
    expect(back.bookId, 'b1');
    expect(back.lentAt, late.lentAt);
    expect(back.dueAt, late.dueAt);
    expect(back.returnedAt, late.returnedAt);

    final noDue = LoanRecordModel.fromJson({'id': 'r2', 'bookId': 'b2', 'borrowerName': 'A', 'lentAt': lentAt.toIso8601String()});
    expect(noDue.dueAt, isNull);
    expect(noDue.returnedAt, lentAt, reason: 'eksik iade tarihi veriliş tarihine düşer');
  });
}
