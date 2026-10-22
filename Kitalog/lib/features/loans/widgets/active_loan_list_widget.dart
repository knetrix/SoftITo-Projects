import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/loans_actions.dart';
import 'active_loan_card_widget.dart';

/// "Ödünçte" sekmesi: en acil iade başta (boşsa yönlendirici mesaj).
class ActiveLoanListWidget extends StatelessWidget {
  const ActiveLoanListWidget({super.key, required this.books, required this.now, required this.actions});

  final List<BookModel> books;
  final DateTime now;
  final LoansActions actions;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return EmptyStateView(
        icon: Icons.handshake_outlined,
        title: context.l10n.loansEmptyActiveTitle,
        message: context.l10n.loansEmptyActiveMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, AppSizes.spaceL, AppSizes.spaceL, AppSizes.fabClearance),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spaceM),
      itemBuilder: (context, index) => ActiveLoanCardWidget(book: books[index], now: now, actions: actions),
    );
  }
}
