import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../controllers/expenses_controller.dart';
import '../models/expense_model.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/expense_month_filter.dart';
import '../widgets/expense_tile.dart';

class ExpensesView extends StatefulWidget {
  final LocalStorageService storage;
  final ExpensesController? controller;

  const ExpensesView({
    super.key,
    required this.storage,
    this.controller,
  });

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  late final ExpensesController _controller;
  late final bool _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _internalController = false;
    } else {
      _controller = ExpensesController(widget.storage);
      _internalController = true;
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showAddExpense() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseBottomSheet(
        onExpenseAdded: _controller.addExpense,
      ),
    );
  }

  void _onDismissExpense(ExpenseModel expense, int index) {
    _controller.removeExpense(expense.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.expensesDeletedMessage),
        action: SnackBarAction(
          label: context.l10n.expensesUndo,
          onPressed: () => _controller.restoreExpense(expense, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navExpenses),
        actions: const [SettingsActionButton()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_expenses',
        onPressed: _showAddExpense,
        tooltip: l10n.expensesAdd,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<DateTime>(
          valueListenable: _controller.selectedMonth,
          builder: (context, currentMonth, _) {
            return ValueListenableBuilder<List<ExpenseModel>>(
              valueListenable: _controller.expenses,
              builder: (context, allExpenses, _) {
                final filtered = _controller.filteredExpenses(currentMonth);
                final total = _controller.totalForMonth(currentMonth);
                final grouped = _controller.groupedByDate(currentMonth);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: ExpenseMonthFilter(
                        currentMonth: currentMonth,
                        totalAmount: total,
                        onPrevious: _controller.previousMonth,
                        onNext: _controller.nextMonth,
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.receipt_long_outlined,
                              message: l10n.expensesEmpty,
                              actionLabel: l10n.expensesAdd,
                              onAction: _showAddExpense,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p16,
                                vertical: AppSizes.p8,
                              ),
                              itemCount: grouped.keys.length,
                              itemBuilder: (context, index) {
                                final date = grouped.keys.elementAt(index);
                                final items = grouped[date]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSizes.p8,
                                        bottom: AppSizes.p4,
                                        left: AppSizes.p4,
                                      ),
                                      child: Text(
                                        date.formatDate(Localizations.localeOf(context).languageCode),
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    for (final expense in items)
                                      ExpenseTile(
                                        expense: expense,
                                        onDismissed: () => _onDismissExpense(
                                          expense,
                                          allExpenses.indexOf(expense),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
