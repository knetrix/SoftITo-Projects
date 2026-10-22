import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/loans_actions.dart';
import '../models/loans_model.dart';
import 'active_loan_list_widget.dart';
import 'loan_history_list_widget.dart';
import 'loan_summary_widget.dart';

/// Özet kutucukları + "Ödünçte" / "Geçmiş" sekmeleri.
class LoansBodyWidget extends StatelessWidget {
  const LoansBodyWidget({super.key, required this.state, required this.now, required this.actions});

  final LoansModel state;
  final DateTime now;
  final LoansActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          LoanSummaryWidget(state: state),
          TabBar(
            tabs: [
              Tab(text: l10n.readingTabLabel(l10n.loansTabActive, state.active.length)),
              Tab(text: l10n.readingTabLabel(l10n.loansTabHistory, state.history.length)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ActiveLoanListWidget(books: state.active, now: now, actions: actions),
                LoanHistoryListWidget(items: state.history, onBookTap: actions.openBook),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
