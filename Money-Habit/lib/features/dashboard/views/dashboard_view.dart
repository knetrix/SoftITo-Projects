import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../../auth/models/user_model.dart';
import '../../budget/controllers/budget_controller.dart';
import '../../challenge/controllers/challenge_controller.dart';
import '../../expenses/controllers/expenses_controller.dart';
import '../../goals/controllers/goals_controller.dart';
import '../widgets/dashboard_budget_card.dart';
import '../widgets/dashboard_challenge_card.dart';
import '../widgets/dashboard_goal_card.dart';
import '../widgets/dashboard_recent_expenses.dart';
import '../widgets/dashboard_welcome_header.dart';

class DashboardView extends StatefulWidget {
  final LocalStorageService storage;
  final ValueChanged<int> onNavigateToTab;
  final UserModel? user;
  final BudgetController budgetController;
  final ChallengeController challengeController;
  final GoalsController goalsController;
  final ExpensesController expensesController;

  const DashboardView({
    super.key,
    required this.storage,
    required this.onNavigateToTab,
    this.user,
    required this.budgetController,
    required this.challengeController,
    required this.goalsController,
    required this.expensesController,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthKey = now.monthKey;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.l10n.navDashboard),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              widget.budgetController.refresh();
              widget.challengeController.refresh();
              widget.goalsController.refresh();
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
            children: [
              DashboardWelcomeHeader(
                user: widget.user,
                onAvatarTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ValueListenableBuilder(
                valueListenable: widget.budgetController.budgets,
                builder: (context, _, __) {
                  return ValueListenableBuilder(
                    valueListenable: widget.expensesController.expenses,
                    builder: (context, _, __) {
                      final limit = widget.budgetController.getLimitForMonth(monthKey);
                      final spent = widget.budgetController.getSpentForMonth(monthKey);
                      final remaining = widget.budgetController.getRemainingForMonth(monthKey);
                      final isOver = widget.budgetController.isOverBudget(monthKey);

                      return DashboardBudgetCard(
                        limit: limit,
                        spent: spent,
                        remaining: remaining,
                        isOver: isOver,
                        onTap: () => widget.onNavigateToTab(4),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ValueListenableBuilder(
                valueListenable: widget.challengeController.state,
                builder: (context, challenge, _) {
                  final todayTask = widget.challengeController.getTodayTask(now);
                  return DashboardChallengeCard(
                    challenge: challenge,
                    todayTask: todayTask,
                    onTap: () => widget.onNavigateToTab(1),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ValueListenableBuilder(
                valueListenable: widget.goalsController.goals,
                builder: (context, goals, _) {
                  final nearest = widget.goalsController.getNearestGoal();
                  return DashboardGoalCard(
                    goal: nearest,
                    onTap: () => widget.onNavigateToTab(2),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              ValueListenableBuilder(
                valueListenable: widget.expensesController.expenses,
                builder: (context, expenses, _) {
                  return DashboardRecentExpenses(
                    expenses: expenses,
                    onViewAll: () => widget.onNavigateToTab(3),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
