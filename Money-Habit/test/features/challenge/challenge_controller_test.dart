import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/challenge/controllers/challenge_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late ChallengeController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    controller = ChallengeController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('başlangıçta aktif challenge boştur', () {
    expect(controller.state.value, isNull);
  });

  test('startChallenge 10 günlük şablonu başlatır ve kaydeder', () async {
    final now = DateTime(2026, 10, 20);
    await controller.startChallenge(startDate: now);

    final challenge = controller.state.value;
    expect(challenge, isNotNull);
    expect(challenge!.tasks, hasLength(10));
    expect(challenge.currentStreak, 0);
    expect(challenge.bestStreak, 0);
    expect(challenge.isCompleted, isFalse);

    final stored = storage.readJson(StorageKeys.activeChallenge);
    expect(stored, isNotNull);
  });

  test('todayDayNumber ve getTaskStatus görev durumlarını doğru belirler', () async {
    final start = DateTime(2026, 10, 20);
    await controller.startChallenge(startDate: start);

    final day1Now = DateTime(2026, 10, 20);
    expect(controller.todayDayNumber(day1Now), 1);

    final task1 = controller.state.value!.tasks[0];
    final task2 = controller.state.value!.tasks[1];

    expect(controller.getTaskStatus(task1, day1Now), TaskStatus.today);
    expect(controller.getTaskStatus(task2, day1Now), TaskStatus.locked);

    // 2 gün sonra (Gün 3)
    final day3Now = DateTime(2026, 10, 22);
    expect(controller.todayDayNumber(day3Now), 3);
    // Task 1 tamamlanmadıysa missed olmalı
    expect(controller.getTaskStatus(task1, day3Now), TaskStatus.missed);
  });

  test('completeToday streak artırır ve best streak günceller', () async {
    final start = DateTime(2026, 10, 20);
    await controller.startChallenge(startDate: start);

    // 1. gün tamamla
    final day1 = DateTime(2026, 10, 20);
    final res1 = await controller.completeToday(day1);
    expect(res1, isTrue);
    expect(controller.state.value!.currentStreak, 1);
    expect(controller.state.value!.bestStreak, 1);
    expect(controller.state.value!.tasks[0].isCompleted, isTrue);

    // Aynı gün tekrar tamamlanamaz
    final resRepeat = await controller.completeToday(day1);
    expect(resRepeat, isFalse);

    // 2. gün tamamla (seri devam eder)
    final day2 = DateTime(2026, 10, 21);
    final res2 = await controller.completeToday(day2);
    expect(res2, isTrue);
    expect(controller.state.value!.currentStreak, 2);
    expect(controller.state.value!.bestStreak, 2);
  });

  test('gün kaçırıldığında streak 1 e sıfırlanır ama best streak korunur', () async {
    final start = DateTime(2026, 10, 20);
    await controller.startChallenge(startDate: start);

    // 1. gün tamamlandı
    await controller.completeToday(DateTime(2026, 10, 20));
    expect(controller.state.value!.currentStreak, 1);

    // 2. gün atlandı (tamamlanmadı), 3. gün tamamlandı
    await controller.completeToday(DateTime(2026, 10, 22));
    expect(controller.state.value!.currentStreak, 1); // 2. gün tamamlanmadığı için seri 1'e döner
    expect(controller.state.value!.bestStreak, 1);
  });

  test('restartChallenge best streak i koruyarak yeni challenge başlatır', () async {
    final start = DateTime(2026, 10, 20);
    await controller.startChallenge(startDate: start);
    await controller.completeToday(DateTime(2026, 10, 20));

    expect(controller.state.value!.bestStreak, 1);

    await controller.restartChallenge();
    expect(controller.state.value!.currentStreak, 0);
    expect(controller.state.value!.bestStreak, 1);
    expect(controller.state.value!.tasks.every((t) => !t.isCompleted), isTrue);
  });
}
