import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutino/core/services/storage_service.dart';
import 'package:rutino/core/services/ai_service.dart';
import 'package:rutino/features/habits/controllers/habits_controller.dart';
import 'package:rutino/features/habits/models/habit_model.dart';
import 'package:rutino/features/statistics/controllers/statistics_controller.dart';
import 'package:rutino/core/utils/date_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rutino Habit Model & DateUtils Testleri', () {
    test('HabitModel immutability ve copyWith testi', () {
      const habit = HabitModel(
        id: '1',
        title: 'Kitap Oku',
        streakCount: 3,
        isCompletedToday: false,
      );

      final updated = habit.copyWith(streakCount: 4, isCompletedToday: true);

      expect(habit.streakCount, 3);
      expect(habit.isCompletedToday, false);
      expect(updated.streakCount, 4);
      expect(updated.isCompletedToday, true);
    });

    test('HabitModel json serileştirme testi', () {
      const habit = HabitModel(
        id: 'h-100',
        title: 'Su İç',
        description: 'Günde 2L',
        streakCount: 5,
        isCompletedToday: true,
        completedDates: ['2026-10-21', '2026-10-22'],
      );

      final json = habit.toJson();
      final fromJson = HabitModel.fromJson(json);

      expect(fromJson.id, 'h-100');
      expect(fromJson.title, 'Su İç');
      expect(fromJson.streakCount, 5);
      expect(fromJson.completedDates.length, 2);
    });

    test('AppDateUtils format ve gün kontrolü', () {
      final now = DateTime(2026, 10, 22);
      expect(AppDateUtils.formatDate(now), '2026-10-22');
      expect(AppDateUtils.lastDays(7).length, 7);
    });
  });

  group('Rutino Controller Testleri', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.getInstance();
    });

    test('HabitsController toggle ve streak artış testi', () async {
      int receivedPoints = 0;
      final controller = HabitsController(
        storageService,
        onPointsChanged: (pts) => receivedPoints += pts,
      );

      final initialHabits = controller.habitsNotifier.value;
      expect(initialHabits.isNotEmpty, true);

      final target = initialHabits.firstWhere((h) => !h.isCompletedToday);
      final initialStreak = target.streakCount;

      await controller.toggleHabitCompletion(target.id);

      final updated = controller.habitsNotifier.value.firstWhere((h) => h.id == target.id);
      expect(updated.isCompletedToday, true);
      expect(updated.streakCount, initialStreak + 1);
      expect(receivedPoints > 0, true);

      controller.dispose();
    });

    test('StatisticsController haftalık oran hesaplama testi', () {
      final statsController = StatisticsController(storageService, AIService());
      final today = AppDateUtils.todayString();

      final habits = [
        HabitModel(id: '1', title: 'H1', completedDates: [today]),
        HabitModel(id: '2', title: 'H2', completedDates: [today]),
      ];

      final rates = statsController.calculateWeeklyRates(habits);
      expect(rates.length, 7);
      expect(rates.last, 1.0); // Bugün %100

      statsController.dispose();
    });
  });
}
