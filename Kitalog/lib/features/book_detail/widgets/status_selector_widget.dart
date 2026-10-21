import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import 'section_card_widget.dart';

class StatusSelectorWidget extends StatelessWidget {
  const StatusSelectorWidget({
    super.key,
    required this.book,
    required this.onChanged,
  });

  final BookModel book;
  final ValueChanged<ReadingStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCardWidget(
      title: l10n.statusSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ReadingStatus>(
              showSelectedIcon: false,
              segments: [
                for (final status in ReadingStatus.values)
                  ButtonSegment(
                    value: status,
                    label: Text(status.label(l10n)),
                  ),
              ],
              selected: {book.status},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
          if (book.startedAt != null)
            Text(
              l10n.startedAtLabel(context.formatDate(book.startedAt!)),
              style: context.textTheme.bodySmall,
            ),
          if (book.finishedAt != null)
            Text(
              l10n.finishedAtLabel(context.formatDate(book.finishedAt!)),
              style: context.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
