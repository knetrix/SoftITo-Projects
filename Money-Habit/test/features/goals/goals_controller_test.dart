import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/goals/controllers/goals_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late GoalsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    controller = GoalsController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('başlangıçta hedefler listesi boştur', () {
    expect(controller.goals.value, isEmpty);
    expect(controller.getNearestGoal(), isNull);
  });

  test('addGoal yeni hedef ekler ve kalıcı saklar', () async {
    await controller.addGoal(title: 'Sigarayı Bırak', targetAmount: 500000); // 5000 TL

    expect(controller.goals.value, hasLength(1));
    final goal = controller.goals.value.first;
    expect(goal.title, 'Sigarayı Bırak');
    expect(goal.targetAmount, 500000);
    expect(goal.savedAmount, 0);
    expect(goal.progress, 0.0);
    expect(goal.isReached, isFalse);

    final stored = storage.readJsonList(StorageKeys.goals);
    expect(stored, hasLength(1));
    expect(stored.first['title'], 'Sigarayı Bırak');
  });

  test('addStep hedefe para ekler, biriken tutarı ve ilerlemeyi artırır', () async {
    await controller.addGoal(title: 'Laptop', targetAmount: 2000000); // 20.000 TL
    final goalId = controller.goals.value.first.id;

    await controller.addStep(goalId, amount: 500000, note: 'Burs yattı'); // 5000 TL
    var goal = controller.goals.value.first;
    expect(goal.savedAmount, 500000);
    expect(goal.progress, 0.25);
    expect(goal.isReached, isFalse);
    expect(goal.steps, hasLength(1));
    expect(goal.steps.first.note, 'Burs yattı');

    // Hedefe tamamlama tutarı ekle
    await controller.addStep(goalId, amount: 1500000); // 15.000 TL daha
    goal = controller.goals.value.first;
    expect(goal.savedAmount, 2000000);
    expect(goal.progress, 1.0);
    expect(goal.isReached, isTrue);
  });

  test('deleteGoal hedefi siler', () async {
    await controller.addGoal(title: 'Tatil', targetAmount: 1000000);
    expect(controller.goals.value, hasLength(1));

    final id = controller.goals.value.first.id;
    await controller.deleteGoal(id);
    expect(controller.goals.value, isEmpty);

    final stored = storage.readJsonList(StorageKeys.goals);
    expect(stored, isEmpty);
  });

  test('getNearestGoal tamamlanmamış en yüksek ilerlemeli hedefi seçer', () async {
    await controller.addGoal(title: 'A', targetAmount: 100000);
    await controller.addGoal(title: 'B', targetAmount: 100000);

    final idA = controller.goals.value.firstWhere((g) => g.title == 'A').id;
    final idB = controller.goals.value.firstWhere((g) => g.title == 'B').id;

    await controller.addStep(idA, amount: 20000); // %20
    await controller.addStep(idB, amount: 70000); // %70

    final nearest = controller.getNearestGoal();
    expect(nearest?.title, 'B');
  });
}
