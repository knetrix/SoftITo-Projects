import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/reading_status.dart';

/// Tür ve okuma durumu seçimi.
class BookClassificationFieldsWidget extends StatelessWidget {
  const BookClassificationFieldsWidget({
    super.key,
    required this.genre,
    required this.status,
    required this.onGenreChanged,
    required this.onStatusChanged,
  });

  final BookGenre genre;
  final ReadingStatus status;
  final ValueChanged<BookGenre> onGenreChanged;
  final ValueChanged<ReadingStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: AppSizes.spaceL,
      children: [
        DropdownButtonFormField<BookGenre>(
          initialValue: genre,
          decoration: InputDecoration(labelText: l10n.fieldBookGenre),
          items: [
            for (final g in BookGenre.values)
              DropdownMenuItem(value: g, child: Text(g.label(l10n))),
          ],
          onChanged: (value) => onGenreChanged(value ?? genre),
        ),
        DropdownButtonFormField<ReadingStatus>(
          initialValue: status,
          decoration: InputDecoration(labelText: l10n.fieldBookStatus),
          items: [
            for (final s in ReadingStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label(l10n))),
          ],
          onChanged: (value) => onStatusChanged(value ?? status),
        ),
      ],
    );
  }
}
