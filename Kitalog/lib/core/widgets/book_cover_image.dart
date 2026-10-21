import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../extensions/genre_extensions.dart';
import '../models/book_genre.dart';

/// Ağ kapağı; yüklenirken veya hata (internet yok / 404) durumunda tür renginde,
/// başlık yazılı bir yer tutucu gösterir.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.title,
    required this.genre,
    this.coverUrl,
    this.borderRadius = AppSizes.radiusS,
  });

  final String title;
  final BookGenre genre;
  final String? coverUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;
    final placeholder = _CoverPlaceholder(title: title, genre: genre);
    return Semantics(
      image: true,
      label: title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: (url == null || url.isEmpty)
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                excludeFromSemantics: true,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.title, required this.genre});

  final String title;
  final BookGenre genre;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: genre.color,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceS),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.onGenre,
            ),
          ),
        ),
      ),
    );
  }
}
