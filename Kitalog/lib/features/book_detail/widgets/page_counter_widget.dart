import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/reading_progress_bar.dart';
import 'page_input_dialog.dart';
import 'section_card_widget.dart';

/// Sayfa sayacı: ilerleme çubuğu, ±1 / ±10 butonları ve doğrudan sayfa girişi.
class PageCounterWidget extends StatelessWidget {
  const PageCounterWidget({
    super.key,
    required this.book,
    required this.onChangePage,
    required this.onSetPage,
  });

  final BookModel book;
  final ValueChanged<int> onChangePage;
  final ValueChanged<int> onSetPage;

  static const int bigStep = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionCardWidget(
      title: l10n.pageCounterTitle,
      trailing: IconButton(
        tooltip: l10n.pageEditTooltip,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () async {
          final page = await PageInputDialog.show(context, book);
          if (page != null) onSetPage(page);
        },
      ),
      child: Column(
        children: [
          ReadingProgressBar(
            progress: book.progress,
            currentPage: book.currentPage,
            pageCount: book.pageCount,
          ),
          const SizedBox(height: AppSizes.spaceM),
          PageStepButtonsWidget(onChangePage: onChangePage, bigStep: bigStep),
        ],
      ),
    );
  }
}

class PageStepButtonsWidget extends StatelessWidget {
  const PageStepButtonsWidget({
    super.key,
    required this.onChangePage,
    required this.bigStep,
  });

  final ValueChanged<int> onChangePage;
  final int bigStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSizes.spaceS,
      children: [
        IconButton.outlined(
          tooltip: l10n.pageDecrementBig(bigStep),
          onPressed: () => onChangePage(-bigStep),
          icon: const Icon(Icons.keyboard_double_arrow_left),
        ),
        IconButton.outlined(
          tooltip: l10n.pageDecrement,
          onPressed: () => onChangePage(-1),
          icon: const Icon(Icons.remove),
        ),
        IconButton.filled(
          tooltip: l10n.pageIncrement,
          onPressed: () => onChangePage(1),
          icon: const Icon(Icons.add),
        ),
        IconButton.filled(
          tooltip: l10n.pageIncrementBig(bigStep),
          onPressed: () => onChangePage(bigStep),
          icon: const Icon(Icons.keyboard_double_arrow_right),
        ),
      ],
    );
  }
}
