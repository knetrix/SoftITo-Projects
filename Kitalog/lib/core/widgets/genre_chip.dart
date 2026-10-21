import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../extensions/genre_extensions.dart';
import '../models/book_genre.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.genre});

  final BookGenre genre;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: genre.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXs,
        ),
        child: Text(
          genre.label(context.l10n),
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.onGenre,
          ),
        ),
      ),
    );
  }
}
