import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../extensions/genre_extensions.dart';
import '../models/book_genre.dart';
import '../models/custom_genre_model.dart';

/// Tür etiketi; kitabın kullanıcı kategorisi ([custom]) varsa onun adı ve rengi.
class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.genre, this.custom});

  final BookGenre genre;
  final CustomGenreModel? custom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: genre.colorWith(custom),
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXs,
        ),
        child: Text(
          genre.labelWith(custom, context.l10n),
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.onGenre,
          ),
        ),
      ),
    );
  }
}
