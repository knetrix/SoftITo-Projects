import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/reading_goal_controller.dart';
import '../models/reading_goal_state.dart';
import '../widgets/genre_breakdown_widget.dart';
import '../widgets/goal_progress_card_widget.dart';
import '../widgets/goal_stat_card_widget.dart';
import '../widgets/goal_target_stepper_widget.dart';
import '../widgets/monthly_chart_widget.dart';

/// Sekme 3: Yıllık Okuma Hedefi Paneli. AppBar ana kabuktadır.
class ReadingGoalView extends StatefulWidget {
  const ReadingGoalView({super.key});

  @override
  State<ReadingGoalView> createState() => _ReadingGoalViewState();
}

class _ReadingGoalViewState extends State<ReadingGoalView> {
  ReadingGoalController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= ReadingGoalController(
      library: AppScope.of(context).libraryController,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ValueListenableBuilder<ReadingGoalState>(
      valueListenable: controller.state,
      builder: (context, goal, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceL),
          child: Column(
            spacing: AppSizes.spaceM,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoalProgressCardWidget(
                year: goal.year,
                finished: goal.finishedCount,
                target: goal.targetBookCount,
                remaining: goal.remaining,
                progress: goal.progress,
              ),
              GoalTargetStepperWidget(
                target: goal.targetBookCount,
                onIncrement: () => controller.changeTarget(1),
                onDecrement: () => controller.changeTarget(-1),
              ),
              GoalStatCardWidget(
                icon: Icons.menu_book_outlined,
                label: context.l10n.goalTotalPages,
                value: '${goal.totalPagesRead}',
              ),
              MonthlyChartWidget(
                monthly: goal.monthlyFinished,
                maxValue: goal.maxMonthly,
              ),
              GenreBreakdownWidget(counts: goal.genreCounts),
            ],
          ),
        );
      },
    );
  }
}
