import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/custom_genre_model.dart';

/// Biten kitapların türlere (kullanıcı kategorileri dahil) göre dağılımı, tür renkleriyle.
class GenreBreakdownWidget extends StatelessWidget {
  const GenreBreakdownWidget({
    super.key,
    required this.counts,
    this.customCounts = const {},
    this.customGenres = const [],
  });

  final Map<BookGenre, int> counts;
  final Map<String, int> customCounts;
  final List<CustomGenreModel> customGenres;

  List<({String label, Color color, int count})> _rows(BuildContext context) {
    final rows = [
      for (final e in counts.entries) (label: e.key.label(context.l10n), color: e.key.color, count: e.value),
      for (final g in customGenres)
        if ((customCounts[g.id] ?? 0) > 0) (label: g.name, color: g.color, count: customCounts[g.id]!),
    ];
    return rows..sort((a, b) => b.count.compareTo(a.count));
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows(context);
    final max = rows.isEmpty ? 1 : rows.first.count;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.goalGenreTitle, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),
            if (rows.isEmpty)
              Text(context.l10n.goalGenreEmpty, style: context.textTheme.bodyMedium)
            else
              for (final row in rows)
                _GenreRow(label: row.label, color: row.color, count: row.count, max: max),
          ],
        ),
      ),
    );
  }
}

class _GenreRow extends StatelessWidget {
  const _GenreRow({required this.label, required this.color, required this.count, required this.max});

  final String label;
  final Color color;
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
              label,
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
                color: color,
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
