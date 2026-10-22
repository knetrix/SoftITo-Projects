import 'package:flutter/foundation.dart';

import '../../../core/models/book_model.dart';
import '../../../core/models/loan_record_model.dart';

/// Geçmişteki bir ödünç kaydı ve ait olduğu kitap.
typedef LoanHistoryItem = ({LoanRecordModel record, BookModel book});

/// Ödünç Takibi sekmesinin durumu: ödünçteki kitaplar (en acil olan başta),
/// iade geçmişi (en son iade başta) ve ödünç verilebilecek fiziksel kitaplar.
@immutable
class LoansModel {
  /// İade gününe bu kadar (veya daha az) gün kalan ödünç "yaklaşan iade" sayılır.
  static const int dueSoonDays = 3;

  final List<BookModel> active;
  final List<LoanHistoryItem> history;

  /// Fiziksel kopyası olan ve şu an ödünçte olmayan kitaplar.
  final List<BookModel> lendable;
  final int overdueCount;
  final int dueSoonCount;

  const LoansModel({
    this.active = const [],
    this.history = const [],
    this.lendable = const [],
    this.overdueCount = 0,
    this.dueSoonCount = 0,
  });

  LoansModel copyWith({
    List<BookModel>? active,
    List<LoanHistoryItem>? history,
    List<BookModel>? lendable,
    int? overdueCount,
    int? dueSoonCount,
  }) {
    return LoansModel(
      active: active ?? this.active,
      history: history ?? this.history,
      lendable: lendable ?? this.lendable,
      overdueCount: overdueCount ?? this.overdueCount,
      dueSoonCount: dueSoonCount ?? this.dueSoonCount,
    );
  }

  factory LoansModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList();
    return LoansModel(
      active: list('active').map(BookModel.fromJson).toList(),
      history: [
        for (final item in list('history'))
          if (item['record'] is Map<String, dynamic> && item['book'] is Map<String, dynamic>)
            (
              record: LoanRecordModel.fromJson(item['record'] as Map<String, dynamic>),
              book: BookModel.fromJson(item['book'] as Map<String, dynamic>),
            ),
      ],
      lendable: list('lendable').map(BookModel.fromJson).toList(),
      overdueCount: json['overdueCount'] as int? ?? 0,
      dueSoonCount: json['dueSoonCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active.map((e) => e.toJson()).toList(),
      'history': [
        for (final item in history) {'record': item.record.toJson(), 'book': item.book.toJson()},
      ],
      'lendable': lendable.map((e) => e.toJson()).toList(),
      'overdueCount': overdueCount,
      'dueSoonCount': dueSoonCount,
    };
  }
}
