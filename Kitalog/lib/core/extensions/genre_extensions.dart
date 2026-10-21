import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../constants/app_colors.dart';
import '../models/book_genre.dart';
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
