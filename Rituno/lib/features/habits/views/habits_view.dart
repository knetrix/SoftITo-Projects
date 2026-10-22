import 'package:flutter/material.dart';
import '../controllers/habits_controller.dart';
import '../models/habit_model.dart';
import '../widgets/habit_stats_banner_widget.dart';
import '../widgets/habit_filter_chips_widget.dart';
import '../widgets/habit_card_widget.dart';
import '../widgets/empty_habit_widget.dart';
import 'habit_form_view.dart';
import '../../../core/constants/app_strings.dart';

class HabitsView extends StatelessWidget {
  final HabitsController habitsController;
  final int totalUserPoints;

  const HabitsView({
    super.key,
    required this.habitsController,
    required this.totalUserPoints,
  });

  void _openAddHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitFormView(
          onSave: (title, desc, cat, freq, time) {
            habitsController.addHabit(
              title: title,
              description: desc,
              category: cat,
              frequency: freq,
              reminderTime: time,
            );
          },
        ),
      ),
    );
  }

  void _openEditHabit(BuildContext context, HabitModel habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitFormView(
          initialHabit: habit,
          onSave: (title, desc, cat, freq, time) {
            habitsController.updateHabit(
              habit.copyWith(
                title: title,
                description: desc,
                category: cat,
                frequency: freq,
                reminderTime: time,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.habitsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _openAddHabit(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddHabit(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderBanner(),
              const SizedBox(height: 12),
              _buildFilterSection(),
              const SizedBox(height: 12),
              Expanded(child: _buildHabitsList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return ValueListenableBuilder<List<HabitModel>>(
      valueListenable: habitsController.habitsNotifier,
      builder: (context, habits, _) {
        final total = habits.length;
        final completed = habits.where((h) => h.isCompletedToday).length;
        return HabitStatsBannerWidget(
          total: total,
          completed: completed,
          points: totalUserPoints,
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return ValueListenableBuilder<HabitFilter>(
      valueListenable: habitsController.filterNotifier,
      builder: (context, currentFilter, _) {
        return HabitFilterChipsWidget(
          currentFilter: currentFilter,
          onFilterSelected: habitsController.setFilter,
        );
      },
    );
  }

  Widget _buildHabitsList(BuildContext context) {
    return ValueListenableBuilder<HabitFilter>(
      valueListenable: habitsController.filterNotifier,
      builder: (context, filter, child) {
        return ValueListenableBuilder<List<HabitModel>>(
          valueListenable: habitsController.habitsNotifier,
          builder: (context, list, innerChild) {
            final habits = habitsController.filteredHabits;
            if (habits.isEmpty) {
              return EmptyHabitWidget(onAddPressed: () => _openAddHabit(context));
            }
            return ListView.separated(
              itemCount: habits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final habit = habits[index];
                return HabitCardWidget(
                  habit: habit,
                  onToggle: () => habitsController.toggleHabitCompletion(habit.id),
                  onEdit: () => _openEditHabit(context, habit),
                  onDelete: () => habitsController.deleteHabit(habit.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
