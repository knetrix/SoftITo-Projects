import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/loan_model.dart';
import 'loan_dialog.dart';
import 'section_card_widget.dart';

/// Ödünç bilgisi: kime, ne zaman, iade tarihi; ödünç verme / iade alma.
class LoanSectionWidget extends StatelessWidget {
  const LoanSectionWidget({
    super.key,
    required this.loan,
    required this.onLend,
    required this.onReturn,
  });

  final LoanModel? loan;
  final ValueChanged<LoanModel> onLend;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = loan;
    return SectionCardWidget(
      title: l10n.loanSectionTitle,
      child: current == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loanNone, style: context.textTheme.bodyMedium),
                const SizedBox(height: AppSizes.spaceM),
                OutlinedButton.icon(
                  icon: const Icon(Icons.outbox_outlined),
                  label: Text(l10n.loanLend),
                  onPressed: () async {
                    final result = await LoanDialog.show(context);
                    if (result != null) onLend(result);
                  },
                ),
              ],
            )
          : _ActiveLoan(loan: current, onReturn: onReturn),
    );
  }
}

class _ActiveLoan extends StatelessWidget {
  const _ActiveLoan({required this.loan, required this.onReturn});

  final LoanModel loan;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overdue = loan.isOverdue(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loanLentTo(loan.borrowerName),
          style: context.textTheme.titleSmall,
        ),
        Text(
          l10n.loanLentAt(context.formatDate(loan.lentAt)),
          style: context.textTheme.bodyMedium,
        ),
        if (loan.dueAt != null)
          Text(
            l10n.loanDueAt(context.formatDate(loan.dueAt!)),
            style: context.textTheme.bodyMedium?.copyWith(
              color: overdue ? context.colors.error : null,
            ),
          ),
        if (overdue)
          Text(
            l10n.loanOverdue,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        const SizedBox(height: AppSizes.spaceM),
        FilledButton.icon(
          icon: const Icon(Icons.assignment_return_outlined),
          label: Text(l10n.loanReturn),
          onPressed: onReturn,
        ),
      ],
    );
  }
}
