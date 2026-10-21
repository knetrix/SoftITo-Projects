import 'package:flutter/foundation.dart';

@immutable
class QuoteModel {
  final String id;
  final String bookId;
  final String text;
  final int? page;
  final bool isFavorite;
  final DateTime createdAt;

  const QuoteModel({
    required this.id,
    required this.bookId,
    required this.text,
    this.page,
    this.isFavorite = false,
    required this.createdAt,
  });

  QuoteModel copyWith({
    String? id,
    String? bookId,
    String? text,
    int? page,
    bool clearPage = false,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      text: text ?? this.text,
      page: clearPage ? null : (page ?? this.page),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      page: json['page'] as int?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'text': text,
      'page': page,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
