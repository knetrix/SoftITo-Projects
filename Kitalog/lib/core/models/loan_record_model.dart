import 'package:flutter/foundation.dart';

import 'loan_model.dart';

/// İadesi alınmış bir ödünç kaydı (ödünç geçmişi). Kitap iade alındığında
/// `BookModel.loan` bilgisi iade tarihiyle birlikte buraya taşınır.
@immutable
class LoanRecordModel {
  final String id;
  final String bookId;
  final String borrowerName;
  final DateTime lentAt;
  final DateTime? dueAt;
  final DateTime returnedAt;

  const LoanRecordModel({
    required this.id,
    required this.bookId,
    required this.borrowerName,
    required this.lentAt,
    this.dueAt,
    required this.returnedAt,
  });

  factory LoanRecordModel.fromLoan({
    required String id,
    required String bookId,
    required LoanModel loan,
    required DateTime returnedAt,
  }) {
    return LoanRecordModel(
      id: id,
      bookId: bookId,
      borrowerName: loan.borrowerName,
      lentAt: loan.lentAt,
      dueAt: loan.dueAt,
      returnedAt: returnedAt,
    );
  }

  /// Kitabın ödünçte kaldığı gün sayısı (aynı gün iade 0).
  int get daysOut => LoanModel.daysBetween(lentAt, returnedAt);

  /// İade tarihinden sonraki bir günde geri alındıysa geç iade sayılır.
  bool get wasLate => dueAt != null && LoanModel.daysBetween(dueAt!, returnedAt) > 0;

  LoanRecordModel copyWith({
    String? id,
    String? bookId,
    String? borrowerName,
    DateTime? lentAt,
    DateTime? dueAt,
    bool clearDueAt = false,
    DateTime? returnedAt,
  }) {
    return LoanRecordModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      borrowerName: borrowerName ?? this.borrowerName,
      lentAt: lentAt ?? this.lentAt,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }

  factory LoanRecordModel.fromJson(Map<String, dynamic> json) {
    final lentAt = DateTime.tryParse(json['lentAt'] as String? ?? '') ?? DateTime.now();
    return LoanRecordModel(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      borrowerName: json['borrowerName'] as String? ?? '',
      lentAt: lentAt,
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? ''),
      returnedAt: DateTime.tryParse(json['returnedAt'] as String? ?? '') ?? lentAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'borrowerName': borrowerName,
      'lentAt': lentAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
      'returnedAt': returnedAt.toIso8601String(),
    };
  }
}
