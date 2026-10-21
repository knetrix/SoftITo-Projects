import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/app_settings_model.dart';
import 'package:kitalog/core/models/avatar_type.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/core/models/note_model.dart';
import 'package:kitalog/core/models/quote_model.dart';
import 'package:kitalog/core/models/reading_goal_model.dart';
import 'package:kitalog/core/models/reading_status.dart';
import 'package:kitalog/core/models/user_model.dart';

void main() {
  final date = DateTime(2026, 3, 4, 5, 6);

  test('BookModel fromJson/toJson gidiş-dönüş', () {
    final book = BookModel(
      id: 'b1',
      isbn: '9786058105973',
      title: 'Kürk Mantolu Madonna',
      authors: const ['Sabahattin Ali'],
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9786058105973-L.jpg',
      pageCount: 176,
      currentPage: 44,
      genre: BookGenre.novel,
      status: ReadingStatus.reading,
      rating: 5,
      review: 'Güzel',
      isOwned: false,
      loan: LoanModel(borrowerName: 'Ayşe', lentAt: date, dueAt: date),
      startedAt: date,
      finishedAt: date,
      addedAt: date,
    );
    final json = book.toJson();
    final back = BookModel.fromJson(json);
    expect(back.toJson(), json);
    expect(back.loan?.borrowerName, 'Ayşe');
    expect(back.genre, BookGenre.novel);
    expect(back.isLent, isTrue);
  });

  test('BookModel progress hesaplanır ve sınırlanır', () {
    final book = BookModel(id: 'b', title: 'T', pageCount: 200, addedAt: date);
    expect(book.progress, 0);
    expect(book.copyWith(currentPage: 50).progress, 0.25);
    expect(book.copyWith(currentPage: 999).currentPage, 200);
    expect(book.copyWith(currentPage: -5).currentPage, 0);
    expect(BookModel(id: 'x', title: 'T', addedAt: date).progress, 0);
  });

  test('BookModel.copyWith alanları temizleyebilir', () {
    final book = BookModel(
      id: 'b',
      title: 'T',
      rating: 4,
      review: 'x',
      loan: LoanModel(borrowerName: 'A', lentAt: date),
      addedAt: date,
    );
    final cleared = book.copyWith(
      clearRating: true,
      clearReview: true,
      clearLoan: true,
    );
    expect(cleared.rating, isNull);
    expect(cleared.review, isNull);
    expect(cleared.loan, isNull);
  });

  test('BookModel.fromJson eksik/bozuk alanlarda varsayılan üretir', () {
    final book = BookModel.fromJson({'id': 'z', 'genre': 'bilinmeyen'});
    expect(book.genre, BookGenre.other);
    expect(book.status, ReadingStatus.toRead);
    expect(book.authors, isEmpty);
  });

  test('LoanModel gecikme hesabı', () {
    final loan = LoanModel(borrowerName: 'A', lentAt: date, dueAt: date);
    expect(loan.isOverdue(date.add(const Duration(days: 1))), isTrue);
    expect(loan.isOverdue(date.subtract(const Duration(days: 1))), isFalse);
    expect(LoanModel(borrowerName: 'A', lentAt: date).isOverdue(date), isFalse);
  });

  test('UserModel gidiş-dönüş ve avatar temizleme', () {
    final user = UserModel(
      id: 'u',
      email: 'a@b.com',
      phone: '05321234567',
      passwordHash: 'h',
      avatarType: AvatarType.preset,
      avatarValue: 'avatar_1',
      createdAt: date,
    );
    expect(UserModel.fromJson(user.toJson()).toJson(), user.toJson());
    final cleared = user.copyWith(avatarType: AvatarType.none, clearAvatarValue: true);
    expect(cleared.avatarValue, isNull);
  });

  test('QuoteModel, NoteModel, ReadingGoalModel gidiş-dönüş', () {
    final quote = QuoteModel(
      id: 'q',
      bookId: 'b',
      text: 'metin',
      page: 7,
      isFavorite: true,
      createdAt: date,
    );
    expect(QuoteModel.fromJson(quote.toJson()).toJson(), quote.toJson());
    expect(quote.copyWith(clearPage: true).page, isNull);

    final note = NoteModel(
      id: 'n',
      bookId: 'b',
      content: 'not',
      createdAt: date,
      updatedAt: date,
    );
    expect(NoteModel.fromJson(note.toJson()).toJson(), note.toJson());

    const goal = ReadingGoalModel(year: 2026, targetBookCount: 24);
    expect(ReadingGoalModel.fromJson(goal.toJson()).toJson(), goal.toJson());
  });

  test('AppSettingsModel varsayılanları koyu tema ve Türkçe', () {
    const settings = AppSettingsModel();
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.localeCode, 'tr');
    final back = AppSettingsModel.fromJson(
      settings.copyWith(themeMode: ThemeMode.light, localeCode: 'en').toJson(),
    );
    expect(back.themeMode, ThemeMode.light);
    expect(back.localeCode, 'en');
  });
}
