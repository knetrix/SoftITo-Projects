import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../extensions/genre_extensions.dart';
import '../models/book_genre.dart';
import '../models/custom_genre_model.dart';
import '../utils/cover_image_data.dart';

/// Ağ kapağı veya cihazdan seçilmiş kapak (`data:` URI); yüklenirken veya hata
/// (internet yok / 404 / bozuk resim) durumunda tür renginde, başlık yazılı bir
/// yer tutucu gösterir.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.title,
    required this.genre,
    this.custom,
    this.coverUrl,
    this.borderRadius = AppSizes.radiusS,
  });

  final String title;
  final BookGenre genre;

  /// Kullanıcı kategorisi; yer tutucu onun renginde çizilir.
  final CustomGenreModel? custom;
  final String? coverUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;
    final placeholder = _CoverPlaceholder(title: title, color: genre.colorWith(custom));
    return Semantics(
      image: true,
      label: title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: (url == null || url.isEmpty)
            ? placeholder
            : CoverImageData.isLocal(url)
            ? _LocalCover(url: url, placeholder: placeholder)
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

class _LocalCover extends StatelessWidget {
  const _LocalCover({required this.url, required this.placeholder});

  final String url;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final bytes = CoverImageData.bytesOf(url);
    if (bytes == null) return placeholder;
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
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
