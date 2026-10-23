import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../../expenses/widgets/expense_month_filter.dart';
import '../controllers/budget_controller.dart';
import '../models/budget_model.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/category_distribution_card.dart';
import '../widgets/set_budget_dialog.dart';
import '../widgets/weekly_chart_card.dart';

class BudgetView extends StatefulWidget {
  final LocalStorageService storage;
  final BudgetController? controller;

  const BudgetView({
    super.key,
    required this.storage,
    this.controller,
  });

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  late final BudgetController _controller;
  late final bool _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _internalController = false;
    } else {
      _controller = BudgetController(widget.storage);
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

  void _showSetBudgetDialog(String monthKey, int currentLimit) {
    showDialog<void>(
      context: context,
      builder: (_) => SetBudgetDialog(
        currentLimit: currentLimit,
        onSave: (newLimit) {
          _controller.setBudgetLimit(monthKey, newLimit);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navBudget),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<DateTime>(
          valueListenable: _controller.selectedMonth,
          builder: (context, currentMonth, _) {
            final monthKey = currentMonth.monthKey;

            return ValueListenableBuilder<List<BudgetModel>>(
              valueListenable: _controller.budgets,
              builder: (context, _, __) {
                final limit = _controller.getLimitForMonth(monthKey);
                final spent = _controller.getSpentForMonth(monthKey);
                final remaining = _controller.getRemainingForMonth(monthKey);
                final isOver = _controller.isOverBudget(monthKey);
                final distribution = _controller.getCategoryDistribution(monthKey);
                final weekly = _controller.getLast7DaysExpenses(DateTime.now());

                return ListView(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  children: [
                    ExpenseMonthFilter(
                      currentMonth: currentMonth,
                      totalAmount: spent,
                      onPrevious: _controller.previousMonth,
                      onNext: _controller.nextMonth,
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    BudgetSummaryCard(
                      limitAmount: limit,
                      spentAmount: spent,
                      remainingAmount: remaining,
                      isOver: isOver,
                      onEditLimit: () => _showSetBudgetDialog(monthKey, limit),
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    CategoryDistributionCard(categoryAmounts: distribution),
                    const SizedBox(height: AppSizes.spaceMd),
                    WeeklyChartCard(dailyExpenses: weekly),
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
