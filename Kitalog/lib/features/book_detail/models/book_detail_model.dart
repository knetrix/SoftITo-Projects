import 'package:flutter/foundation.dart';

import '../../../core/models/book_model.dart';
import '../../../core/models/note_model.dart';
import '../../../core/models/quote_model.dart';

@immutable
class BookDetailModel {
  final BookModel? book;
  final List<QuoteModel> quotes;
  final List<NoteModel> notes;

  /// Son sayfaya ulaşıldığında "Bitti olarak işaretle" önerisini tetikler.
  final bool finishSuggested;

  const BookDetailModel({
    this.book,
    this.quotes = const [],
    this.notes = const [],
    this.finishSuggested = false,
  });

  bool get isMissing => book == null;

  BookDetailModel copyWith({
    BookModel? book,
    bool clearBook = false,
    List<QuoteModel>? quotes,
    List<NoteModel>? notes,
    bool? finishSuggested,
  }) {
    return BookDetailModel(
      book: clearBook ? null : (book ?? this.book),
      quotes: quotes ?? this.quotes,
      notes: notes ?? this.notes,
      finishSuggested: finishSuggested ?? this.finishSuggested,
    );
  }

  factory BookDetailModel.fromJson(Map<String, dynamic> json) {
    final bookJson = json['book'];
    return BookDetailModel(
      book: bookJson is Map<String, dynamic> ? BookModel.fromJson(bookJson) : null,
      quotes: (json['quotes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuoteModel.fromJson)
          .toList(),
      notes: (json['notes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(NoteModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book?.toJson(),
      'quotes': quotes.map((e) => e.toJson()).toList(),
      'notes': notes.map((e) => e.toJson()).toList(),
    };
  }
}
