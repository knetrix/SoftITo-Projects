import 'package:flutter/foundation.dart';
import '../models/ai_insight_model.dart';
import '../../habits/models/habit_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_strings.dart';

class StatisticsController {
  final StorageService _storageService;
  final AIService _aiService;
  final ValueNotifier<AIInsightModel?> insightNotifier = ValueNotifier<AIInsightModel?>(null);
  final ValueNotifier<bool> isAnalyzingNotifier = ValueNotifier<bool>(false);

  StatisticsController(this._storageService, this._aiService) {
    showInsightFor(AppStrings.currentLanguage);
  }

  /// Seçili dilde üretilmiş en son analizi gösterir; o dilde analiz yoksa kart boş kalır.
  void showInsightFor(String language) {
    final insights = _storageService.loadAiInsights();
    insightNotifier.value = insights.where((i) => i.language == language).firstOrNull;
  }

  /// Son 7 günün tamamlama oranlarını (0.0 - 1.0) hesaplar
  List<double> calculateWeeklyRates(List<HabitModel> habits) {
    if (habits.isEmpty) return List.filled(7, 0.0);

    final days = AppDateUtils.lastDays(7);
    return days.map((dateStr) {
      int completedOnDay = 0;
      for (final h in habits) {
        if (h.completedDates.contains(dateStr)) {
          completedOnDay++;
        }
      }
      return (completedOnDay / habits.length).clamp(0.0, 1.0);
    }).toList();
  }

  int calculateTotalCompletions(List<HabitModel> habits) {
    int sum = 0;
    for (final h in habits) {
      sum += h.completedDates.length;
    }
    return sum;
  }

  int calculateHighestStreak(List<HabitModel> habits) {
    if (habits.isEmpty) return 0;
    int max = 0;
    for (final h in habits) {
      if (h.bestStreak > max) max = h.bestStreak;
      if (h.streakCount > max) max = h.streakCount;
    }
    return max;
  }

  Future<void> runAiAnalysis({
    required String userId,
    required List<HabitModel> habits,
  }) async {
    isAnalyzingNotifier.value = true;
    try {
      final newInsight = await _aiService.analyzeHabits(userId: userId, habits: habits);
      final currentList = _storageService.loadAiInsights();
      final updatedList = [newInsight, ...currentList];
      await _storageService.saveAiInsights(updatedList);
      insightNotifier.value = newInsight;
    } finally {
      isAnalyzingNotifier.value = false;
    }
  }

  void dispose() {
    insightNotifier.dispose();
    isAnalyzingNotifier.dispose();
  }
}
