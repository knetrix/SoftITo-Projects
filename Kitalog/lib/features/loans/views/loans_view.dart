import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/loan_dialog.dart';
import '../controllers/loans_controller.dart';
import '../models/loans_actions.dart';
import '../models/loans_model.dart';
import '../widgets/lend_book_sheet.dart';
import '../widgets/loans_body_widget.dart';

/// Sekme 3: Ödünç Takibi. Ödünçteki fiziksel kitaplar, iade geçmişi ve
/// buradan ödünç verme. AppBar ana kabuktadır.
class LoansView extends StatefulWidget {
  const LoansView({super.key});

  @override
  State<LoansView> createState() => _LoansViewState();
}

class _LoansViewState extends State<LoansView> {
  LoansController? _controller;
  late final LoansActions _actions = LoansActions(openBook: _openBook, editLoan: _editLoan, markReturned: _markReturned);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= LoansController(library: AppScope.of(context).libraryController);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openBook(BookModel book) {
    Navigator.of(context).pushNamed(AppRoutes.bookDetail, arguments: book.id);
  }

  Future<void> _lend() async {
    final book = await LendBookSheet.show(context, books: _controller!.state.value.lendable);
    if (book == null || !mounted) return;
    final loan = await LoanDialog.show(context);
    if (loan != null) await _controller!.lend(book.id, loan);
  }

  Future<void> _editLoan(BookModel book) async {
    final loan = await LoanDialog.show(context, initial: book.loan);
    if (loan != null) await _controller!.updateLoan(book.id, loan);
  }

  Future<void> _markReturned(BookModel book) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      icon: Icons.assignment_return_outlined,
      title: l10n.loansReturnConfirmTitle,
      message: l10n.loansReturnConfirmMessage(book.title, book.loan!.borrowerName),
      confirmLabel: l10n.loanReturn,
    );
    if (confirmed) await _controller!.markReturned(book.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Kitaplığım'ın FAB'ı da IndexedStack'te ağaçta durduğu için Hero kapalı
        // (aynı varsayılan etiket sayfa geçişinde çakışırdı).
        heroTag: null,
        onPressed: _lend,
        icon: const Icon(Icons.outbox_outlined),
        label: Text(context.l10n.loanLend),
      ),
      body: ValueListenableBuilder<LoansModel>(
        valueListenable: _controller!.state,
        builder: (context, state, _) => LoansBodyWidget(state: state, now: _controller!.now(), actions: _actions),
      ),
    );
  }
}
