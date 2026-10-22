import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/loans_model.dart';
import 'loan_cover_widget.dart';
import 'loan_status_chip_widget.dart';

/// "Geçmiş" sekmesi: iadesi alınmış ödünçler, en son iade başta.
class LoanHistoryListWidget extends StatelessWidget {
  const LoanHistoryListWidget({super.key, required this.items, required this.onBookTap});

  final List<LoanHistoryItem> items;
  final ValueChanged<BookModel> onBookTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.history,
        title: context.l10n.loansEmptyHistoryTitle,
        message: context.l10n.loansEmptyHistoryMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, AppSizes.spaceL, AppSizes.spaceL, AppSizes.fabClearance),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spaceS),
      itemBuilder: (context, index) => _HistoryTile(item: items[index], onTap: () => onBookTap(items[index].book)),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onTap});

  final LoanHistoryItem item;
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
            spacing: AppSizes.spaceM,
            children: [
              LoanCoverWidget(book: item.book, width: AppSizes.loanHistoryCoverWidth),
              Expanded(child: _HistoryInfo(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryInfo extends StatelessWidget {
  const _HistoryInfo({required this.item});

  final LoanHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final record = item.record;
    final period = l10n.loansHistoryPeriod(context.formatDate(record.lentAt), context.formatDate(record.returnedAt));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.spaceXs,
      children: [
        Text(item.book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall),
        Text(l10n.loanLentTo(record.borrowerName), style: context.textTheme.bodyMedium),
        Text('$period · ${l10n.loansHistoryDuration(record.daysOut)}', style: context.textTheme.bodySmall),
        if (record.wasLate)
          LoanStatusChipWidget(icon: Icons.schedule, label: l10n.loansReturnedLate, tone: LoanStatusTone.danger),
      ],
    );
  }
}
