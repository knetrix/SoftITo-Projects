import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/genre_choice.dart';
import '../models/library_filter_actions.dart';
import '../models/library_shelf_model.dart';

/// Tek bir filtre seçeneği: etiket, (varsa) simge veya tür rengi, seçili mi.
typedef LibraryFilterOption = ({
  String label,
  IconData? icon,
  Color? color,
  bool selected,
  VoidCallback onToggle,
});

typedef LibraryFilterGroup = ({String title, List<LibraryFilterOption> options});

/// Filtre paneli ve seçili filtre çipleri aynı listeden üretilir; sıra:
/// biçim (fiziksel / dijital), tür (kullanıcı kategorileri dahil).
/// Okuma durumu ve ödünç burada yok: "Okuma Durumu" ve "Ödünç Takibi"
/// sekmeleri kitapları zaten bunlara göre ayırır.
List<LibraryFilterGroup> libraryFilterGroups(
  BuildContext context,
  LibraryShelfModel state,
  LibraryFilterActions actions,
) {
  final l10n = context.l10n;
  LibraryFilterOption genre(GenreChoice value, String label, Color color) => (
    label: label,
    icon: null,
    color: color,
    selected: state.genres.contains(value),
    onToggle: () => actions.toggleGenre(value),
  );
  return [
    (
      title: l10n.libraryFilterFormat,
      options: [
        for (final f in BookFormatFilter.values)
          (label: f.label(context), icon: f.icon, color: null, selected: state.formats.contains(f), onToggle: () => actions.toggleFormat(f)),
      ],
    ),
    (
      title: l10n.libraryFilterGenre,
      options: [
        for (final g in BookGenre.values) genre((genre: g, customGenreId: null), g.label(l10n), g.color),
        for (final c in state.customGenres) genre((genre: BookGenre.other, customGenreId: c.id), c.name, c.color),
      ],
    ),
  ];
}

extension BookFormatFilterX on BookFormatFilter {
  String label(BuildContext context) => switch (this) {
    BookFormatFilter.physical => context.l10n.physicalBadge,
    BookFormatFilter.digital => context.l10n.digitalBadge,
  };

  IconData get icon => switch (this) {
    BookFormatFilter.physical => Icons.menu_book_outlined,
    BookFormatFilter.digital => Icons.tablet_mac_outlined,
  };
}

/// Seçeneğin önündeki işaret: tür rengi noktası veya simge.
class LibraryFilterLeading extends StatelessWidget {
  const LibraryFilterLeading({super.key, required this.option});

  final LibraryFilterOption option;

  @override
  Widget build(BuildContext context) {
    final color = option.color;
    if (color != null) return Icon(Icons.circle, size: AppSizes.iconS, color: color);
    return Icon(option.icon, size: AppSizes.iconS);
  }
}
