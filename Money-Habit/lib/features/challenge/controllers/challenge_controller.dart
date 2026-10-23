import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/challenge_model.dart';

enum TaskStatus {
  completed,
  today,
  locked,
  missed,
}

class ChallengeController {
  final LocalStorageService _storage;
  final ValueNotifier<ChallengeModel?> state;

  ChallengeController(this._storage)
      : state = ValueNotifier<ChallengeModel?>(_loadChallenge(_storage));

  static ChallengeModel? _loadChallenge(LocalStorageService storage) {
    final json = storage.readJson(StorageKeys.activeChallenge);
    if (json == null) return null;
    return ChallengeModel.fromJson(json);
  }

  static List<ChallengeTaskModel> defaultTemplateTasks() => const [
        ChallengeTaskModel(
          dayNumber: 1,
          title: 'İsteğe Bağlı Bir Harcamayı Ertele',
          description: 'Bugün planlanmamış veya zorunlu olmayan bir harcamadan vazgeç.',
        ),
        ChallengeTaskModel(
          dayNumber: 2,
          title: 'Harcama Kaydı Yap',
          description: 'Bugünkü tüm harcamalarını kuruşu kuruşuna uygulamaya kaydet.',
        ),
        ChallengeTaskModel(
          dayNumber: 3,
          title: 'Aboneliklerini Denetle',
          description: 'Kullanmadığın veya unutulmuş bir dijital aboneliği kontrol et.',
        ),
        ChallengeTaskModel(
          dayNumber: 4,
          title: 'Alışveriş Listesi Hazırla',
          description: 'Markete gitmeden önce liste hazırla ve listeye sadık kal.',
        ),
        ChallengeTaskModel(
          dayNumber: 5,
          title: 'Hedefe Sembolik Para Ekle',
          description: 'Finansal hedeflerinden birine küçük de olsa bir miktar ekle.',
        ),
        ChallengeTaskModel(
          dayNumber: 6,
          title: 'Sabit Giderlerini Karşılaştır',
          description: 'İnternet, elektrik veya telefon faturanı optimize etme fırsatlarını ara.',
        ),
        ChallengeTaskModel(
          dayNumber: 7,
          title: 'Sıfır Ekstra Harcama Günü',
          description: 'Zorunlu temel ihtiyaçlar dışında hiçbir harcama yapma.',
        ),
        ChallengeTaskModel(
          dayNumber: 8,
          title: 'Finansal Hedeflerini İncele',
          description: 'Kısa ve orta vadeli tasarruf hedeflerinin durumunu gözden geçir.',
        ),
        ChallengeTaskModel(
          dayNumber: 9,
          title: 'Kategori Dağılımına Bak',
          description: 'Bütçe panelindeki grafikte en çok nereye harcadığını incele.',
        ),
        ChallengeTaskModel(
          dayNumber: 10,
          title: '10 Günlük Tasarruf Değerlendirmesi',
          description: 'Bu 10 günde kazandığın finansal farkındalığı ve birikimini kutla!',
        ),
      ];

  Future<void> startChallenge({DateTime? startDate}) async {
    final start = (startDate ?? DateTime.now()).dateOnly;
    final newChallenge = ChallengeModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: '10 Günlük Finansal Farkındalık',
      tasks: defaultTemplateTasks(),
      startDate: start,
      currentStreak: 0,
      bestStreak: state.value?.bestStreak ?? 0,
      isCompleted: false,
    );

    state.value = newChallenge;
    await _persist();
  }

  Future<void> restartChallenge() async {
    final best = state.value?.bestStreak ?? 0;
    final newChallenge = ChallengeModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: '10 Günlük Finansal Farkındalık',
      tasks: defaultTemplateTasks(),
      startDate: DateTime.now().dateOnly,
      currentStreak: 0,
      bestStreak: best,
      isCompleted: false,
    );

    state.value = newChallenge;
    await _persist();
  }

  int? todayDayNumber(DateTime now) {
    final challenge = state.value;
    if (challenge == null) return null;
    final start = challenge.startDate.dateOnly;
    final current = now.dateOnly;
    final diff = current.difference(start).inDays + 1;
    return diff;
  }

  TaskStatus getTaskStatus(ChallengeTaskModel task, DateTime now) {
    if (task.isCompleted) return TaskStatus.completed;

    final currentDay = todayDayNumber(now);
    if (currentDay == null) return TaskStatus.locked;

    if (task.dayNumber < currentDay) return TaskStatus.missed;
    if (task.dayNumber == currentDay) return TaskStatus.today;
    return TaskStatus.locked;
  }

  ChallengeTaskModel? getTodayTask(DateTime now) {
    final challenge = state.value;
    final day = todayDayNumber(now);
    if (challenge == null || day == null || day < 1 || day > challenge.tasks.length) {
      return null;
    }
    return challenge.tasks[day - 1];
  }

  Future<bool> completeToday(DateTime now) async {
    final challenge = state.value;
    final day = todayDayNumber(now);
    if (challenge == null || day == null) return false;
    if (day < 1 || day > challenge.tasks.length) return false;

    final currentTask = challenge.tasks[day - 1];
    if (currentTask.isCompleted) return false;

    final previousDone = day > 1 && challenge.tasks[day - 2].isCompleted;
    final streak = previousDone ? challenge.currentStreak + 1 : 1;
    final best = math.max(challenge.bestStreak, streak);

    final updatedTasks = [
      for (final t in challenge.tasks)
        t.dayNumber == day ? t.copyWith(completedAt: now) : t,
    ];

    final isAllFinished = day == challenge.tasks.length ||
        updatedTasks.every((t) => t.isCompleted);

    state.value = challenge.copyWith(
      tasks: updatedTasks,
      currentStreak: streak,
      bestStreak: best,
      isCompleted: isAllFinished,
    );

    await _persist();
    return true;
  }

  Future<void> _persist() async {
    if (state.value != null) {
      await _storage.writeJson(
        StorageKeys.activeChallenge,
        state.value!.toJson(),
      );
    }
  }

  void refresh() {
    state.value = _loadChallenge(_storage);
  }

  void dispose() {
    state.dispose();
  }
}
