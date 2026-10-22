import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/finish_book_dialog.dart';
import 'section_card_widget.dart';

/// Okuma durumu: mevcut durum, tarihler ve yalnızca anlamlı bir sonraki adım.
/// Okunacak → "Okumaya başla" / "Bitti olarak işaretle"; Okunuyor → "Bitti olarak
/// işaretle"; Bitti → "Tekrar oku". Bitirme ve tekrar okuma onay ister.
class StatusSelectorWidget extends StatelessWidget {
  const StatusSelectorWidget({
    super.key,
    required this.book,
    required this.onChanged,
    required this.onReadAgain,
  });

  final BookModel book;
  final ValueChanged<ReadingStatus> onChanged;
  final VoidCallback onReadAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateStyle = context.textTheme.bodySmall;
    return SectionCardWidget(
      title: l10n.statusSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.spaceS,
        children: [
          _CurrentStatus(status: book.status),
          if (book.startedAt != null)
            Text(
              l10n.startedAtLabel(context.formatDate(book.startedAt!)),
              style: dateStyle,
              textAlign: TextAlign.center,
            ),
          if (book.finishedAt != null)
            Text(
              l10n.finishedAtLabel(context.formatDate(book.finishedAt!)),
              style: dateStyle,
              textAlign: TextAlign.center,
            ),
          _StatusActions(
            status: book.status,
            onChanged: onChanged,
            onReadAgain: onReadAgain,
          ),
        ],
      ),
    );
  }
}

class _CurrentStatus extends StatelessWidget {
  const _CurrentStatus({required this.status});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSizes.spaceS,
      children: [
        Icon(status.icon, color: context.colors.primary),
        Flexible(
          child: Text(
            context.l10n.statusCurrentLabel(status.label(context.l10n)),
            style: context.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({
    required this.status,
    required this.onChanged,
    required this.onReadAgain,
  });

  final ReadingStatus status;
  final ValueChanged<ReadingStatus> onChanged;
  final VoidCallback onReadAgain;

  Future<void> _finish(BuildContext context) async {
    final ok = await FinishBookDialog.show(context);
    if (ok) onChanged(ReadingStatus.finished);
  }

  Future<void> _readAgain(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await ConfirmDialog.show(
      context,
      icon: Icons.replay,
      title: l10n.readAgainConfirmTitle,
      message: l10n.readAgainConfirmMessage,
      confirmLabel: l10n.readAgain,
    );
    if (ok) onReadAgain();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.spaceS,
      children: switch (status) {
        ReadingStatus.toRead => [
          FilledButton.icon(
            onPressed: () => onChanged(ReadingStatus.reading),
            icon: Icon(ReadingStatus.reading.icon),
            label: Text(l10n.startReading),
          ),
          OutlinedButton.icon(
            onPressed: () => _finish(context),
            icon: Icon(ReadingStatus.finished.icon),
            label: Text(l10n.markFinished),
          ),
        ],
        ReadingStatus.reading => [
          FilledButton.icon(
            onPressed: () => _finish(context),
            icon: Icon(ReadingStatus.finished.icon),
            label: Text(l10n.markFinished),
          ),
        ],
        ReadingStatus.finished => [
          FilledButton.tonalIcon(
            onPressed: () => _readAgain(context),
            icon: const Icon(Icons.replay),
            label: Text(l10n.readAgain),
          ),
        ],
      },
    );
  }
}
