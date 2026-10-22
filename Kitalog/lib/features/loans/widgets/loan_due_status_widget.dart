import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/loan_model.dart';
import '../models/loans_model.dart';
import 'loan_status_chip_widget.dart';

/// İade gününe göre durum: "3 gün gecikti", "Bugün iade edilmeli",
/// "5 gün kaldı" veya "İade tarihi yok".
class LoanDueStatusWidget extends StatelessWidget {
  const LoanDueStatusWidget({super.key, required this.loan, required this.now});

  final LoanModel loan;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = loan.daysUntilDue(now);
    return switch (days) {
      null => LoanStatusChipWidget(icon: Icons.event_busy_outlined, label: l10n.loansDueNone),
      < 0 => LoanStatusChipWidget(
        icon: Icons.warning_amber_rounded,
        label: l10n.loansOverdueBy(-days),
        tone: LoanStatusTone.danger,
      ),
      0 => LoanStatusChipWidget(icon: Icons.today_outlined, label: l10n.loansDueToday, tone: LoanStatusTone.warning),
      _ => LoanStatusChipWidget(
        icon: Icons.event_outlined,
        label: l10n.loansDueIn(days),
        tone: days <= LoansModel.dueSoonDays ? LoanStatusTone.warning : LoanStatusTone.neutral,
      ),
    };
  }
}
