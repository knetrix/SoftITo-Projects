import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/constants/storage_keys.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/budget/controllers/budget_controller.dart';
import 'package:money_habit_tracker/features/expenses/models/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late BudgetController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();

    // Populate mock expenses for October 2026
    final expenses = [
      ExpenseModel(
        id: '1',
        amount: 30000, // 300 TL
        category: ExpenseCategory.market,
        date: DateTime(2026, 10, 5),
      ),
      ExpenseModel(
        id: '2',
        amount: 20000, // 200 TL
        category: ExpenseCategory.bills,
        date: DateTime(2026, 10, 10),
      ),
      ExpenseModel(
        id: '3',
        amount: 10000, // 100 TL
        category: ExpenseCategory.transport,
        date: DateTime(2026, 11, 2),
      ),
    ];
    await storage.writeJsonList(
      StorageKeys.expenses,
      expenses.map((e) => e.toJson()).toList(),
    );

    controller = BudgetController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('başlangıçta belirlenen limit yoksa 0 döner', () {
    expect(controller.getLimitForMonth('2026-10'), 0);
    expect(controller.isOverBudget('2026-10'), isFalse);
  });

  test('setBudgetLimit limiti günceller ve depolamaya yazar', () async {
    await controller.setBudgetLimit('2026-10', 100000); // 1000 TL
    expect(controller.getLimitForMonth('2026-10'), 100000);

    final stored = storage.readJsonList(StorageKeys.budgets);
    expect(stored, hasLength(1));
    expect(stored.first['monthKey'], '2026-10');
    expect(stored.first['limitAmount'], 100000);
  });

  test('harcanan, kalan ve bütçe aşımı doğru hesaplanır', () async {
    await controller.setBudgetLimit('2026-10', 40000); // 400 TL limit

    final spent = controller.getSpentForMonth('2026-10');
    expect(spent, 50000); // 300 + 200 = 500 TL (50000 kuruş)

    final remaining = controller.getRemainingForMonth('2026-10');
    expect(remaining, -10000); // -100 TL

    final isOver = controller.isOverBudget('2026-10');
    expect(isOver, isTrue);

    // Limit artırılırsa bütçe aşımı false olmalı
    await controller.setBudgetLimit('2026-10', 60000);
    expect(controller.getRemainingForMonth('2026-10'), 10000);
    expect(controller.isOverBudget('2026-10'), isFalse);
  });

  test('kategori dağılımı doğru hesaplanır', () {
    final dist = controller.getCategoryDistribution('2026-10');
    expect(dist[ExpenseCategory.market], 30000);
    expect(dist[ExpenseCategory.bills], 20000);
    expect(dist[ExpenseCategory.transport], isNull);
  });
}
