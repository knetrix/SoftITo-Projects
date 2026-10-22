import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';

enum HabitFilter { all, today, completed }

class HabitsController {
  final StorageService _storageService;
  final ValueNotifier<List<HabitModel>> habitsNotifier = ValueNotifier<List<HabitModel>>([]);
  final ValueNotifier<HabitFilter> filterNotifier = ValueNotifier<HabitFilter>(HabitFilter.today);
  final void Function(int pointsDiff)? onPointsChanged;

  HabitsController(this._storageService, {this.onPointsChanged}) {
    _loadHabits();
  }

  void _loadHabits() {
    final list = _storageService.loadHabits();
    final today = AppDateUtils.todayString();

    // Gün geçişi kontrolü: Bugün tamamlanma durumunu listeye göre senkronize et
    final synced = list.map((habit) {
      final isDoneToday = habit.completedDates.contains(today);
      return habit.copyWith(isCompletedToday: isDoneToday);
    }).toList();

    habitsNotifier.value = synced;
  }

  void setFilter(HabitFilter filter) {
    filterNotifier.value = filter;
  }

  List<HabitModel> get filteredHabits {
    final list = habitsNotifier.value;
    switch (filterNotifier.value) {
      case HabitFilter.all:
        return list;
      case HabitFilter.today:
        return list;
      case HabitFilter.completed:
        return list.where((h) => h.isCompletedToday).toList();
    }
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final today = AppDateUtils.todayString();
    int pointsDiff = 0;

    final updated = habitsNotifier.value.map((habit) {
      if (habit.id == habitId) {
        final willComplete = !habit.isCompletedToday;
        final newDates = List<String>.from(habit.completedDates);

        int newStreak = habit.streakCount;
        if (willComplete) {
          if (!newDates.contains(today)) newDates.add(today);
          newStreak += 1;
          pointsDiff += AppConstants.pointPerCompletion + (newStreak * AppConstants.streakBonusMultiplier);
        } else {
          newDates.remove(today);
          newStreak = (newStreak > 0) ? newStreak - 1 : 0;
          pointsDiff -= AppConstants.pointPerCompletion + ((newStreak + 1) * AppConstants.streakBonusMultiplier);
        }

        final best = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

        return habit.copyWith(
          isCompletedToday: willComplete,
          streakCount: newStreak,
          bestStreak: best,
          completedDates: newDates,
        );
      }
      return habit;
    }).toList();

    habitsNotifier.value = updated;
    await _storageService.saveHabits(updated);
    if (pointsDiff != 0 && onPointsChanged != null) {
      onPointsChanged!(pointsDiff);
    }
  }

  Future<void> addHabit({
    required String title,
    required String description,
    required String category,
    required String frequency,
    String? reminderTime,
  }) async {
    final newHabit = HabitModel(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      frequency: frequency,
      reminderTime: reminderTime,
      streakCount: 0,
      bestStreak: 0,
      isCompletedToday: false,
      completedDates: const [],
    );

    final list = [...habitsNotifier.value, newHabit];
    habitsNotifier.value = list;
    await _storageService.saveHabits(list);
  }

  Future<void> updateHabit(HabitModel updated) async {
    final list = habitsNotifier.value.map((h) => h.id == updated.id ? updated : h).toList();
    habitsNotifier.value = list;
    await _storageService.saveHabits(list);
  }

  Future<void> deleteHabit(String habitId) async {
    final list = habitsNotifier.value.where((h) => h.id != habitId).toList();
    habitsNotifier.value = list;
    await _storageService.saveHabits(list);
  }

  void dispose() {
    habitsNotifier.dispose();
    filterNotifier.dispose();
  }
}
