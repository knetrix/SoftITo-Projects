import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../budget/controllers/budget_controller.dart';
import '../../budget/views/budget_view.dart';
import '../../challenge/controllers/challenge_controller.dart';
import '../../challenge/views/challenge_view.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../expenses/controllers/expenses_controller.dart';
import '../../expenses/views/expenses_view.dart';
import '../../goals/controllers/goals_controller.dart';
import '../../goals/views/goals_view.dart';
import '../../settings/controllers/settings_controller.dart';

class HomeShellView extends StatefulWidget {
  final LocalStorageService storage;
  final SettingsController settingsController;
  final int initialIndex;

  const HomeShellView({
    super.key,
    required this.storage,
    required this.settingsController,
    this.initialIndex = 0,
  });

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  late int _selectedIndex = widget.initialIndex;

  late final BudgetController _budgetController;
  late final ChallengeController _challengeController;
  late final GoalsController _goalsController;
  late final ExpensesController _expensesController;

  @override
  void initState() {
    super.initState();
    _budgetController = BudgetController(widget.storage);
    _challengeController = ChallengeController(widget.storage);
    _goalsController = GoalsController(widget.storage);
    _expensesController = ExpensesController(widget.storage);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _challengeController.dispose();
    _goalsController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Refresh data on tab change
      _budgetController.refresh();
      _challengeController.refresh();
      _goalsController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardView(
            storage: widget.storage,
            onNavigateToTab: _onTabSelected,
            user: widget.settingsController.currentUser.value,
            budgetController: _budgetController,
            challengeController: _challengeController,
            goalsController: _goalsController,
            expensesController: _expensesController,
          ),
          ChallengeView(
            storage: widget.storage,
            controller: _challengeController,
          ),
          GoalsView(
            storage: widget.storage,
            controller: _goalsController,
          ),
          ExpensesView(
            storage: widget.storage,
            controller: _expensesController,
          ),
          BudgetView(
            storage: widget.storage,
            controller: _budgetController,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: l10n.navChallenge,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l10n.navGoals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.navBudget,
          ),
        ],
      ),
    );
  }
}
