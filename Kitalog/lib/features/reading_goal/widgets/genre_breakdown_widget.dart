import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';

/// Biten kitapların türlere göre dağılımı (tür renkleriyle).
class GenreBreakdownWidget extends StatelessWidget {
  const GenreBreakdownWidget({super.key, required this.counts});

  final Map<BookGenre, int> counts;

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.isEmpty ? 1 : entries.first.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.goalGenreTitle, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),
            if (entries.isEmpty)
              Text(context.l10n.goalGenreEmpty, style: context.textTheme.bodyMedium)
            else
              for (final entry in entries)
                _GenreRow(genre: entry.key, count: entry.value, max: max),
          ],
        ),
      ),
    );
  }
}

class _GenreRow extends StatelessWidget {
  const _GenreRow({required this.genre, required this.count, required this.max});

  final BookGenre genre;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              genre.label(context.l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusChip),
              child: LinearProgressIndicator(
                value: count / max,
                color: genre.color,
                minHeight: AppSizes.spaceM,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Text('$count', style: context.textTheme.labelLarge),
        ],
      ),
    );
  }
}
