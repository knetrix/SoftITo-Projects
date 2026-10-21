import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/widgets/empty_state_view.dart';

/// Bir durum sekmesi boşken gösterilen mesaj.
class StatusEmptyWidget extends StatelessWidget {
  const StatusEmptyWidget({super.key, required this.status});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (status) {
      ReadingStatus.reading => EmptyStateView(
        icon: Icons.auto_stories_outlined,
        title: l10n.readingEmptyReadingTitle,
        message: l10n.readingEmptyReadingMessage,
      ),
      ReadingStatus.toRead => EmptyStateView(
        icon: Icons.bookmark_add_outlined,
        title: l10n.readingEmptyToReadTitle,
        message: l10n.readingEmptyToReadMessage,
      ),
      ReadingStatus.finished => EmptyStateView(
        icon: Icons.check_circle_outline,
        title: l10n.readingEmptyFinishedTitle,
        message: l10n.readingEmptyFinishedMessage,
      ),
    };
  }
}
