import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/rating_stars.dart';
import 'section_card_widget.dart';
import 'text_entry_dialog.dart';

/// Puan (1-5) ve şahsi inceleme.
class RatingReviewWidget extends StatelessWidget {
  const RatingReviewWidget({
    super.key,
    required this.book,
    required this.onRatingChanged,
    required this.onReviewSaved,
  });

  final BookModel book;
  final ValueChanged<int> onRatingChanged;
  final ValueChanged<String> onReviewSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final review = book.review;
    return SectionCardWidget(
      title: l10n.ratingSectionTitle,
      trailing: IconButton(
        tooltip: l10n.reviewEdit,
        icon: const Icon(Icons.rate_review_outlined),
        onPressed: () async {
          final text = await TextEntryDialog.show(
            context,
            title: l10n.reviewDialogTitle,
            label: l10n.reviewHint,
            initialText: review ?? '',
            allowEmpty: true,
          );
          if (text != null) onReviewSaved(text);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingStars(
            rating: book.rating,
            onChanged: onRatingChanged,
            size: AppSizes.iconL - 8,
          ),
          const SizedBox(height: AppSizes.spaceM),
          Text(
            review ?? l10n.reviewEmpty,
            style: review == null
                ? context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  )
                : context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
