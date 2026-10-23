import '../constants/storage_keys.dart';
import '../extensions/date_extensions.dart';
import '../../features/budget/models/budget_model.dart';
import '../../features/challenge/controllers/challenge_controller.dart';
import '../../features/challenge/models/challenge_model.dart';
import '../../features/expenses/models/expense_model.dart';
import '../../features/goals/models/goal_model.dart';
import 'local_storage_service.dart';

abstract final class MockDataLoader {
  static Future<void> loadMockDataIfEmpty(LocalStorageService storage) async {
    final now = DateTime.now();
    final monthKey = now.monthKey;

    // 1. Harcamalar boşsa ekle
    final existingExpenses = storage.readJsonList(StorageKeys.expenses);
    if (existingExpenses.isEmpty) {
      final sampleExpenses = [
        ExpenseModel(
          id: 'mock_1',
          amount: 45000, // 450 TL
          category: ExpenseCategory.market,
          date: now.subtract(const Duration(hours: 3)),
          note: 'Haftalık mutfak alışverişi',
        ),
        ExpenseModel(
          id: 'mock_2',
          amount: 12000, // 120 TL
          category: ExpenseCategory.transport,
          date: now.subtract(const Duration(days: 1, hours: 2)),
          note: 'Toplu taşıma kart dolumu',
        ),
        ExpenseModel(
          id: 'mock_3',
          amount: 68000, // 680 TL
          category: ExpenseCategory.bills,
          date: now.subtract(const Duration(days: 2)),
          note: 'Elektrik & İnternet faturası',
        ),
        ExpenseModel(
          id: 'mock_4',
          amount: 35000, // 350 TL
          category: ExpenseCategory.entertainment,
          date: now.subtract(const Duration(days: 3)),
          note: 'Sinema ve kahve',
        ),
        ExpenseModel(
          id: 'mock_5',
          amount: 22000, // 220 TL
          category: ExpenseCategory.health,
          date: now.subtract(const Duration(days: 4)),
          note: 'Eczane gideri',
        ),
      ];

      await storage.writeJsonList(
        StorageKeys.expenses,
        sampleExpenses.map((e) => e.toJson()).toList(),
      );
    }

    // 2. Bütçe boşsa ekle
    final existingBudgets = storage.readJsonList(StorageKeys.budgets);
    if (existingBudgets.isEmpty) {
      final sampleBudget = BudgetModel(
        monthKey: monthKey,
        limitAmount: 1500000, // 15.000 TL
      );
      await storage.writeJsonList(StorageKeys.budgets, [sampleBudget.toJson()]);
    }

    // 3. Hedefler boşsa ekle
    final existingGoals = storage.readJsonList(StorageKeys.goals);
    if (existingGoals.isEmpty) {
      final sampleGoals = [
        GoalModel(
          id: 'goal_1',
          title: 'Acil Durum Fonu',
          targetAmount: 1000000, // 10.000 TL
          createdAt: now.subtract(const Duration(days: 15)),
          steps: [
            GoalStepModel(
              id: 'step_1',
              amount: 350000, // 3.500 TL
              date: now.subtract(const Duration(days: 10)),
              note: 'Maaş birikimi',
            ),
            GoalStepModel(
              id: 'step_2',
              amount: 150000, // 1.500 TL
              date: now.subtract(const Duration(days: 3)),
              note: 'Ek gelir birikimi',
            ),
          ],
        ),
        GoalModel(
          id: 'goal_2',
          title: 'Yeni Dizüstü Bilgisayar',
          targetAmount: 3000000, // 30.000 TL
          createdAt: now.subtract(const Duration(days: 5)),
          steps: [
            GoalStepModel(
              id: 'step_3',
              amount: 600000, // 6.000 TL
              date: now.subtract(const Duration(days: 2)),
              note: 'İlk peşinat birikimi',
            ),
          ],
        ),
      ];

      await storage.writeJsonList(
        StorageKeys.goals,
        sampleGoals.map((g) => g.toJson()).toList(),
      );
    }

    // 4. Challenge boşsa başlat
    final existingChallenge = storage.readJson(StorageKeys.activeChallenge);
    if (existingChallenge == null) {
      final start = now.subtract(const Duration(days: 1)).dateOnly;
      final tasks = ChallengeController.defaultTemplateTasks();
      final day1DoneTasks = [
        tasks[0].copyWith(completedAt: start),
        for (int i = 1; i < tasks.length; i++) tasks[i],
      ];

      final sampleChallenge = ChallengeModel(
        id: 'challenge_1',
        title: '10 Günlük Finansal Farkındalık',
        tasks: day1DoneTasks,
        startDate: start,
        currentStreak: 1,
        bestStreak: 1,
        isCompleted: false,
      );

      await storage.writeJson(
        StorageKeys.activeChallenge,
        sampleChallenge.toJson(),
      );
    }
  }
}
