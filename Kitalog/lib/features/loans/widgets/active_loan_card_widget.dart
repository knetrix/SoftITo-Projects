import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../models/loans_actions.dart';
import 'loan_cover_widget.dart';
import 'loan_due_status_widget.dart';

/// Ödünçteki bir kitap: kime, ne zamandır, iade durumu; "Düzenle" ve "İade alındı".
/// Karta dokunmak Kitap Detay'ı açar.
class ActiveLoanCardWidget extends StatelessWidget {
  const ActiveLoanCardWidget({super.key, required this.book, required this.now, required this.actions});

  final BookModel book;
  final DateTime now;
  final LoansActions actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => actions.openBook(book),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSizes.spaceM,
                children: [
                  LoanCoverWidget(book: book),
                  Expanded(child: _LoanInfo(book: book, now: now)),
                ],
              ),
              _LoanButtons(book: book, actions: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanInfo extends StatelessWidget {
  const _LoanInfo({required this.book, required this.now});

  final BookModel book;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loan = book.loan!;
    final secondary = context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.spaceXs,
      children: [
        Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.titleMedium),
        Text(l10n.loanLentTo(loan.borrowerName), style: context.textTheme.titleSmall),
        Text(
          '${l10n.loanLentAt(context.formatDate(loan.lentAt))} · ${l10n.loansDaysOut(loan.daysOut(now))}',
          style: secondary,
        ),
        if (loan.dueAt != null) Text(l10n.loanDueAt(context.formatDate(loan.dueAt!)), style: secondary),
        const SizedBox(height: AppSizes.spaceXs),
        LoanDueStatusWidget(loan: loan, now: now),
      ],
    );
  }
}

class _LoanButtons extends StatelessWidget {
  const _LoanButtons({required this.book, required this.actions});

  final BookModel book;
  final LoansActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSizes.spaceS,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.loansEdit),
          onPressed: () => actions.editLoan(book),
        ),
        FilledButton.tonalIcon(
          // Temadaki tam genişlik varsayılanı düğmeleri alt alta iterdi.
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          icon: const Icon(Icons.assignment_return_outlined),
          label: Text(l10n.loanReturn),
          onPressed: () => actions.markReturned(book),
        ),
      ],
    );
  }
}
