import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../constants/app_colors.dart';
import '../di/app_scope.dart';
import '../models/book_model.dart';
import '../models/book_genre.dart';
import '../models/custom_genre_model.dart';
import '../models/reading_status.dart';

extension BookGenreX on BookGenre {
  Color get color => switch (this) {
    BookGenre.novel => AppColors.genreNovel,
    BookGenre.science => AppColors.genreScience,
    BookGenre.history => AppColors.genreHistory,
    BookGenre.philosophy => AppColors.genrePhilosophy,
    BookGenre.personalDevelopment => AppColors.genrePersonalDevelopment,
    BookGenre.sciFiFantasy => AppColors.genreSciFiFantasy,
    BookGenre.biography => AppColors.genreBiography,
    BookGenre.poetry => AppColors.genrePoetry,
    BookGenre.children => AppColors.genreChildren,
    BookGenre.other => AppColors.genreOther,
  };

  String label(AppLocalizations l10n) => switch (this) {
    BookGenre.novel => l10n.genreNovel,
    BookGenre.science => l10n.genreScience,
    BookGenre.history => l10n.genreHistory,
    BookGenre.philosophy => l10n.genrePhilosophy,
    BookGenre.personalDevelopment => l10n.genrePersonalDevelopment,
    BookGenre.sciFiFantasy => l10n.genreSciFiFantasy,
    BookGenre.biography => l10n.genreBiography,
    BookGenre.poetry => l10n.genrePoetry,
    BookGenre.children => l10n.genreChildren,
    BookGenre.other => l10n.genreOther,
  };

  /// Kitabın kullanıcı kategorisi varsa onun rengi, yoksa türün rengi.
  Color colorWith(CustomGenreModel? custom) => custom?.color ?? color;

  /// Kitabın kullanıcı kategorisi varsa onun adı, yoksa türün etiketi.
  String labelWith(CustomGenreModel? custom, AppLocalizations l10n) => custom?.name ?? label(l10n);
}

extension CustomGenreX on CustomGenreModel {
  Color get color => AppColors.customGenrePalette[colorIndex % AppColors.customGenrePalette.length];
}

extension BookGenreContextX on BuildContext {
  /// Kitabın kullanıcı kategorisi (yoksa veya silindiyse `null`).
  CustomGenreModel? customGenreOf(BookModel book) =>
      AppScope.of(this).libraryController.customGenreById(book.customGenreId);
}

extension ReadingStatusX on ReadingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ReadingStatus.toRead => l10n.statusToRead,
    ReadingStatus.reading => l10n.statusReading,
    ReadingStatus.finished => l10n.statusFinished,
  };

  IconData get icon => switch (this) {
    ReadingStatus.toRead => Icons.bookmark_add_outlined,
    ReadingStatus.reading => Icons.auto_stories_outlined,
    ReadingStatus.finished => Icons.check_circle_outline,
  };
}
