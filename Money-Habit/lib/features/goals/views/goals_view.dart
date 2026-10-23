import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../controllers/goals_controller.dart';
import '../models/goal_model.dart';
import '../widgets/add_goal_bottom_sheet.dart';
import '../widgets/add_money_bottom_sheet.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_detail_bottom_sheet.dart';

class GoalsView extends StatefulWidget {
  final LocalStorageService storage;
  final GoalsController? controller;

  const GoalsView({
    super.key,
    required this.storage,
    this.controller,
  });

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  late final GoalsController _controller;
  late final bool _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _internalController = false;
    } else {
      _controller = GoalsController(widget.storage);
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

  void _showAddGoal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddGoalBottomSheet(
        onGoalAdded: (title, target) {
          _controller.addGoal(title: title, targetAmount: target);
        },
      ),
    );
  }

  void _showAddMoney(GoalModel goal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddMoneyBottomSheet(
        goalTitle: goal.title,
        onMoneyAdded: (amount, note) {
          _controller.addStep(goal.id, amount: amount, note: note);
        },
      ),
    );
  }

  void _showGoalDetail(GoalModel goal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ValueListenableBuilder<List<GoalModel>>(
        valueListenable: _controller.goals,
        builder: (context, goals, _) {
          final current = goals.firstWhere(
            (g) => g.id == goal.id,
            orElse: () => goal,
          );
          return GoalDetailBottomSheet(
            goal: current,
            onAddMoney: () {
              Navigator.of(ctx).pop();
              _showAddMoney(current);
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: ctx,
                builder: (dialogCtx) => AlertDialog(
                  title: Text(context.l10n.goalsDelete),
                  content: Text(context.l10n.goalsDeleteConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(context.l10n.commonCancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(dialogCtx).colorScheme.error,
                        foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: Text(context.l10n.commonDelete),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _controller.deleteGoal(current.id);
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
          );
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
        title: Text(l10n.navGoals),
        actions: const [SettingsActionButton()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_goals',
        onPressed: _showAddGoal,
        tooltip: l10n.goalsAdd,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<GoalModel>>(
          valueListenable: _controller.goals,
          builder: (context, goals, _) {
            if (goals.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.flag_outlined,
                message: l10n.goalsEmpty,
                actionLabel: l10n.goalsAdd,
                onAction: _showAddGoal,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetail(goal),
                  onAddMoney: () => _showAddMoney(goal),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
