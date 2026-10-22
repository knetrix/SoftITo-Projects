import 'package:flutter/material.dart';
import '../controllers/statistics_controller.dart';
import '../models/ai_insight_model.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../habits/models/habit_model.dart';
import '../widgets/stats_summary_cards_widget.dart';
import '../widgets/weekly_bar_chart_widget.dart';
import '../widgets/streak_milestone_widget.dart';
import '../widgets/ai_insight_card_widget.dart';
import '../../../core/constants/app_strings.dart';

class StatisticsView extends StatelessWidget {
  final StatisticsController statsController;
  final HabitsController habitsController;
  final String userId;
  final int totalPoints;

  const StatisticsView({
    super.key,
    required this.statsController,
    required this.habitsController,
    required this.userId,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.statsTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<HabitModel>>(
          valueListenable: habitsController.habitsNotifier,
          builder: (context, habits, _) {
            final weeklyRates = statsController.calculateWeeklyRates(habits);
            final totalCompletions = statsController.calculateTotalCompletions(habits);
            final highestStreak = statsController.calculateHighestStreak(habits);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatsSummaryCardsWidget(
                    totalHabits: habits.length,
                    highestStreak: highestStreak,
                    totalCompletions: totalCompletions,
                    totalPoints: totalPoints,
                  ),
                  const SizedBox(height: 16),
                  WeeklyBarChartWidget(weeklyRates: weeklyRates),
                  const SizedBox(height: 16),
                  StreakMilestoneWidget(streak: highestStreak),
                  const SizedBox(height: 16),
                  _buildAiSection(habits),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiSection(List<HabitModel> habits) {
    return ValueListenableBuilder<bool>(
      valueListenable: statsController.isAnalyzingNotifier,
      builder: (context, isAnalyzing, _) {
        return ValueListenableBuilder<AIInsightModel?>(
          valueListenable: statsController.insightNotifier,
          builder: (context, insight, _) {
            return AIInsightCardWidget(
              insight: insight,
              isAnalyzing: isAnalyzing,
              onAnalyzePressed: () => statsController.runAiAnalysis(
                userId: userId,
                habits: habits,
              ),
            );
          },
        );
      },
    );
  }
}
