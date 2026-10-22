import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/models/genre_choice.dart';
import '../../../core/models/reading_status.dart';

/// Tür (yerleşik türler + kullanıcı kategorileri, yanında "Yeni kategori ekle")
/// ve okuma durumu seçimi. Menüler alana sığdırılır (`isExpanded`); dar
/// ekranda ve büyük yazıda uzun seçenekler üç noktayla kısaltılır.
class BookClassificationFieldsWidget extends StatelessWidget {
  const BookClassificationFieldsWidget({
    super.key,
    required this.genre,
    required this.customGenres,
    required this.status,
    required this.onGenreChanged,
    required this.onAddGenre,
    required this.onStatusChanged,
  });

  final GenreChoice genre;

  /// Kullanıcı kategorileri; yeni kategori eklenince menü kendiliğinden güncellenir.
  final ValueListenable<List<CustomGenreModel>> customGenres;
  final ReadingStatus status;
  final ValueChanged<GenreChoice> onGenreChanged;
  final VoidCallback onAddGenre;
  final ValueChanged<ReadingStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: AppSizes.spaceL,
      children: [
        Row(
          spacing: AppSizes.spaceS,
          children: [
            Expanded(
              child: ValueListenableBuilder<List<CustomGenreModel>>(
                valueListenable: customGenres,
                builder: (context, customs, _) =>
                    _GenreDropdown(genre: genre, customGenres: customs, onChanged: onGenreChanged),
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.genreAdd,
              onPressed: onAddGenre,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        DropdownButtonFormField<ReadingStatus>(
          initialValue: status,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.fieldBookStatus),
          items: [
            for (final s in ReadingStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label(l10n), overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (value) => onStatusChanged(value ?? status),
        ),
      ],
    );
  }
}

class _GenreDropdown extends StatelessWidget {
  const _GenreDropdown({required this.genre, required this.customGenres, required this.onChanged});

  final GenreChoice genre;
  final List<CustomGenreModel> customGenres;
  final ValueChanged<GenreChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonFormField<GenreChoice>(
      // Yeni eklenen kategori seçildiğinde alanın değeri yeniden kurulur.
      key: ValueKey(genre),
      initialValue: genre,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.fieldBookGenre),
      items: [
        for (final g in BookGenre.values)
          _item((genre: g, customGenreId: null), g.label(l10n), g.color),
        for (final c in customGenres)
          _item((genre: BookGenre.other, customGenreId: c.id), c.name, c.color),
      ],
      onChanged: (value) => onChanged(value ?? genre),
    );
  }

  DropdownMenuItem<GenreChoice> _item(GenreChoice value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        spacing: AppSizes.spaceS,
        children: [
          Icon(Icons.circle, size: AppSizes.iconS, color: color),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
