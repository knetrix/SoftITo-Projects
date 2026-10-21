import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/widgets/book_cover_image.dart';
import '../../../core/widgets/genre_chip.dart';

class SearchResultTileWidget extends StatelessWidget {
  const SearchResultTileWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  final BookSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: AspectRatio(
                  aspectRatio: AppSizes.coverAspectRatio,
                  child: BookCoverImage(
                    title: result.title,
                    genre: result.genre,
                    coverUrl: result.coverUrl,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(child: _ResultInfo(result: result)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultInfo extends StatelessWidget {
  const _ResultInfo({required this.result});

  final BookSearchResult result;

  @override
  Widget build(BuildContext context) {
    final pages = result.pageCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium,
        ),
        Text(
          result.authors.isEmpty
              ? context.l10n.authorUnknown
              : result.authors.join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSizes.spaceS),
        Wrap(
          spacing: AppSizes.spaceS,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GenreChip(genre: result.genre),
            if (pages != null)
              Text(
                context.l10n.bookPageCount(pages),
                style: context.textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }
}
