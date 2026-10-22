import '../utils/date_utils.dart';
import '../constants/app_strings.dart';
import '../../features/habits/models/habit_model.dart';
import '../../features/statistics/models/ai_insight_model.dart';

class AIService {
  /// Alışkanlık verilerini analiz ederek dinamik yapay zeka tavsiyeleri üretir
  Future<AIInsightModel> analyzeHabits({
    required String userId,
    required List<HabitModel> habits,
  }) async {
    // Gerçekçi analiz süresi simülasyonu
    await Future.delayed(const Duration(milliseconds: 900));

    final isEn = AppStrings.isEnglish;
    final total = habits.length;
    final completed = habits.where((h) => h.isCompletedToday).length;
    final maxStreakHabit = habits.isNotEmpty
        ? (habits.toList()..sort((a, b) => b.streakCount.compareTo(a.streakCount))).first
        : null;

    final ratio = total > 0 ? (completed / total * 100).round() : 0;

    String summary;
    List<String> suggestions = [];

    if (total == 0) {
      if (isEn) {
        summary = 'You don\'t have any active habits yet. Starting with 1 or 2 small routines is a great first step.';
        suggestions = [
          'Drink 1 glass of water after waking up.',
          'Set a goal to read 10 pages every day.',
        ];
      } else {
        summary = 'Henüz aktif bir alışkanlığın bulunmuyor. Başlangıç için günde 1 veya 2 küçük rutin belirlemek harika bir ilk adım olacaktır.';
        suggestions = [
          'Sabah uyanınca 1 bardak su içme alışkanlığı oluştur.',
          'Her gün 10 sayfa okuma hedefi belirle.',
        ];
      }
    } else if (ratio >= 75) {
      if (isEn) {
        summary = 'Awesome performance! You completed $ratio% of your routines today. ${maxStreakHabit != null ? 'You inspire with a ${maxStreakHabit.streakCount}-day streak in "${maxStreakHabit.title}".' : ''} Keeping this momentum will help you achieve your goals.';
        suggestions = [
          'Increase difficulty by 10% to push boundaries.',
          'Carry this discipline into the weekend to lead tournaments.',
          'Reward yourself after completing evening routines.',
        ];
      } else {
        summary = 'Harika bir performans sergiliyorsun! Bugün rutinlerinin %$ratio oranını tamamladın. ${maxStreakHabit != null ? '"${maxStreakHabit.title}" alışkanlığında ${maxStreakHabit.streakCount} günlük serinle ilham veriyorsun.' : ''} Bu ivmeyi korumak seni hedeflerine taşıyacak.';
        suggestions = [
          'Alışkanlık zorluk seviyeni %10 artırarak yeni sınırlara ulaşabilirsin.',
          'Topluluk turnuvalarında liderlik için bu disiplini hafta sonuna da taşı.',
          'Akşam rutinlerini tamamladıktan sonra kendini ödüllendir.',
        ];
      }
    } else if (ratio >= 40) {
      if (isEn) {
        summary = 'Steady progress! You achieved $ratio% of your goals today. Spread remaining habits into the evening to finish the day with full success.';
        suggestions = [
          'Set alarms for 20:00 and 21:00 for unfinished habits.',
          'Apply the 2-minute rule to beat procrastination.',
          'Tackle the most challenging habit in the morning.',
        ];
      } else {
        summary = 'Dengeli bir ilerleme kaydediyorsun. Bugün hedeflerinin %$ratio kadarını gerçekleştirdin. Kalan hedefleri akşam saatlerine yayarak günü tam başarıyla kapatabilirsin.';
        suggestions = [
          'Tamamlanmamış alışkanlıkların için 20:00 ve 21:00 saatlerine alarm kur.',
          'Ertelemeyi önlemek için 2 dakikalık mikro başlangıç taktiğini uygula.',
          'En çok zorlandığın alışkanlığı günün ilk saatlerine taşı.',
        ];
      }
    } else {
      if (isEn) {
        summary = 'You are just getting started today with a completion rate of $ratio%. Remember that lasting changes begin with small steps. Complete one habit now to ignite your streak!';
        suggestions = [
          'Start with the easiest habit right now and check it off.',
          'Focus on completing at least one routine to protect your streak.',
          'Set tomorrow\'s reminders to earlier hours.',
        ];
      } else {
        summary = 'Bugün henüz yolun başındasın, tamamlanma oranın %$ratio. Unutma ki en büyük değişimler küçük ve kararlı adımlarla başlar. Şimdi tek bir alışkanlığı tamamlayarak serini ateşle!';
        suggestions = [
          'En kolay olan alışkanlıkla hemen şimdi başla ve tik at.',
          'Bugün serini kaybetmemek için en az bir rutini tamamlamaya odaklan.',
          'Yarın için hatırlatıcı bildirimlerini daha erken saatlere ayarla.',
        ];
      }
    }

    return AIInsightModel(
      id: 'insight_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      generatedSummary: summary,
      suggestions: suggestions,
      createdAt: AppDateUtils.todayString(),
      language: AppStrings.currentLanguage,
    );
  }
}
