import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/reading_status.dart';

/// Arama kutusu + tür ve okuma durumu filtre çipleri.
class LibraryFilterBarWidget extends StatefulWidget {
  const LibraryFilterBarWidget({
    super.key,
    required this.genre,
    required this.status,
    required this.onQueryChanged,
    required this.onGenreChanged,
    required this.onStatusChanged,
  });

  final BookGenre? genre;
  final ReadingStatus? status;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<BookGenre?> onGenreChanged;
  final ValueChanged<ReadingStatus?> onStatusChanged;

  @override
  State<LibraryFilterBarWidget> createState() => _LibraryFilterBarWidgetState();
}

class _LibraryFilterBarWidgetState extends State<LibraryFilterBarWidget> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceL,
            AppSizes.spaceS,
            AppSizes.spaceL,
            AppSizes.spaceS,
          ),
          child: TextField(
            controller: _search,
            onChanged: widget.onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.librarySearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        _StatusChips(selected: widget.status, onChanged: widget.onStatusChanged),
        _GenreChips(selected: widget.genre, onChanged: widget.onGenreChanged),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceL,
          vertical: AppSizes.spaceXs,
        ),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.spaceS),
        itemBuilder: (_, index) => Center(child: children[index]),
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.selected, required this.onChanged});

  final ReadingStatus? selected;
  final ValueChanged<ReadingStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ChipRow(
      children: [
        ChoiceChip(
          label: Text(l10n.libraryFilterAll),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final status in ReadingStatus.values)
          ChoiceChip(
            label: Text(status.label(l10n)),
            selected: selected == status,
            onSelected: (_) => onChanged(status),
          ),
      ],
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.selected, required this.onChanged});

  final BookGenre? selected;
  final ValueChanged<BookGenre?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ChipRow(
      children: [
        ChoiceChip(
          label: Text(l10n.libraryFilterAll),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final genre in BookGenre.values)
          ChoiceChip(
            avatar: Icon(Icons.circle, size: AppSizes.iconS, color: genre.color),
            label: Text(genre.label(l10n)),
            selected: selected == genre,
            onSelected: (_) => onChanged(genre),
          ),
      ],
    );
  }
}
